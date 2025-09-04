//
//  ListViewModel.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation
import Combine

final class ListViewModel: ViewModelProtocol {
    
    private let listRepository: ListRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private let imageCacheManager: ImageCacheManager
    private let navigateToDetail: (Int) -> Void
    
    private var offsetValue = 0
    private var offsetStep = 20
    
    private let listDataSubject = CurrentValueSubject<[ListData], Never>([])
    private let errorSubject = PassthroughSubject<Error, Never>()
    private let isFetchingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isEndSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellable = Set<AnyCancellable>()
    
    struct Input {
        let fetchTriggered: AnyPublisher<Void, Never>
        let itemSelected: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let listDataPublisher: AnyPublisher<[ListData], Never>
        let isEndPublisher: AnyPublisher<Bool, Never>
        let errorPublisher: AnyPublisher<Error, Never>
    }
    
    init(dependencies: ListDependencies, navigateToDetail: @escaping (Int) -> Void) {
        self.listRepository = dependencies.listRepository
        self.imageRepository = dependencies.imageRepository
        self.imageCacheManager = dependencies.imageCacheManager
        self.navigateToDetail = navigateToDetail
    }
    
    func transform(_ input: Input) -> Output {
        // TODO: loadingIndicator 관련 로직 구현 필요
        // fetchList 후 값 우선 방출(startLoading = true, imageData = nil)
        // fetchImage 후 값 최종 방출(startLoading = false, imageData = fetchImage 결과 Data)
        input.fetchTriggered
            .filter { [weak self] _ in
                guard let self else { return false }
                return !self.isFetchingSubject.value && !self.isEndSubject.value
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self else { return }
                self.isFetchingSubject.send(true)
            })
            .flatMap { [weak self] _ -> AnyPublisher<[ListData], Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return Future<ListResponse, Error> { future in
                    Task {
                        do {
                            let response = try await self.listRepository.fetchList(offset: self.offsetValue)
                            self.offsetValue += self.offsetStep
                            future(.success(response))
                        } catch {
                            future(.failure(error))
                        }
                    }
                }
                .eraseToAnyPublisher()
                .handleEvents(receiveOutput: { [weak self] response in
                    guard let self else { return }
                    self.isEndSubject.send(response.next == nil)
                })
                .map { $0.results }
                .flatMap { [weak self] results -> AnyPublisher<[ListData], Error> in
                    guard let self else {
                        return Empty<[ListData],Error>()
                            .eraseToAnyPublisher()
                    }
                    
                    return Future<[ListData], Error> { future in
                        Task {
                            do {
                                let listDataArray = try await withThrowingTaskGroup(of: (Int, ListData).self) { group in
                                    for (index, data) in results.enumerated() {
                                        group.addTask {
                                            //TODO: 별도 에러로 정의 필요.
                                            guard let id = Int(data.url.lastPathComponent) else { throw NSError(domain: "아이디 사용 불가", code: -1) }
                                            let imageData = try await self.imageRepository.fetchImage(id: id)
                                            let listData = ListData(name: data.name, url: data.url, imageData: imageData, id: id)
                                            return (index, listData)
                                        }
                                    }
                                    
                                    var tempArray = Array<ListData?>(repeating: nil, count: results.count)
                                    for try await (index, listData) in group {
                                        tempArray[index] = listData
                                    }
                                    return tempArray.compactMap { $0 }
                                }
                                future(.success(listDataArray))
                            } catch {
                                future(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
                .catch { [weak self] error -> AnyPublisher<[ListData], Never> in
                    guard let self else { return Empty().eraseToAnyPublisher() }
                    self.errorSubject.send(error)
                    self.isFetchingSubject.send(false)
                    self.offsetValue -= self.offsetStep
                    return Empty().eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self else { return }
                self.isFetchingSubject.send(false)
            })
            .sink(receiveValue: { [weak self] listData in
                guard let self else { return }
                var currentData = self.listDataSubject.value
                let newData = listData.filter { newItem in
                    !currentData.contains(where: { $0.id == newItem.id })
                }
                currentData.append(contentsOf: newData)
                self.listDataSubject.send(currentData)
            })
            .store(in: &cancellable)

        input.itemSelected
            .sink { [weak self] id in
                self?.navigateToDetail(id)
            }
            .store(in: &cancellable)
        
        
        return Output(
            listDataPublisher: listDataSubject.eraseToAnyPublisher(),
            isEndPublisher: isEndSubject.eraseToAnyPublisher(),
            errorPublisher: errorSubject.eraseToAnyPublisher()
        )
    }
}
