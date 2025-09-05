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
        input.fetchTriggered
            .receive(on: DispatchQueue.global())
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
                
                let subject = PassthroughSubject<[ListData], Error>()
                let task = Task {
                    let stream = AsyncThrowingStream<[ListData], Error> { continuation in
                        Task {
                            do {
                                let response = try await self.listRepository.fetchList(offset: self.offsetValue)
                                self.offsetValue += self.offsetStep
                                self.isEndSubject.send(response.next == nil)
                                
                                let initialListData = response.results.compactMap { result -> ListData? in
                                    guard let id = Int(result.url.lastPathComponent) else { return nil }
                                    return ListData(name: result.name, url: result.url, image: nil, id: id, isLoading: true)
                                }
                                continuation.yield(initialListData)
                                
                                let finalListData = try await withThrowingTaskGroup(of: ListData.self, returning: [ListData].self) { group in
                                    for item in initialListData {
                                        group.addTask {
                                            var mutableItem = item
                                            let imageData = try await self.imageRepository.fetchImage(id: item.id)
                                            mutableItem.image = imageData
                                            mutableItem.isLoading = false
                                            return mutableItem
                                        }
                                    }
                                    var collected = [ListData]()
                                    collected.reserveCapacity(initialListData.count)
                                    for try await anItem in group {
                                        collected.append(anItem)
                                    }
                                    return collected
                                }
                                continuation.yield(finalListData)
                                continuation.finish()
                            } catch {
                                continuation.finish(throwing: error)
                            }
                        }
                    }
                    
                    do {
                        for try await value in stream {
                            subject.send(value)
                        }
                        subject.send(completion: .finished)
                    } catch {
                        subject.send(completion: .failure(error))
                    }
                }

                return subject
                    .handleEvents(receiveCompletion: { [weak self] completion in
                        if case .finished = completion {
                            self?.isFetchingSubject.send(false)
                        }
                    }, receiveCancel: { task.cancel() })
                    .catch { [weak self] error -> AnyPublisher<[ListData], Never> in
                        guard let self else { return Empty().eraseToAnyPublisher() }
                        self.errorSubject.send(error)
                        self.isFetchingSubject.send(false)
                        self.offsetValue -= self.offsetStep
                        return Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: { [weak self] listData in
                guard let self else { return }
                var currentData = self.listDataSubject.value
                
                listData.forEach { newItem in
                    if let index = currentData.firstIndex(where: { $0.id == newItem.id }) {
                        currentData[index] = newItem
                    } else {
                        currentData.append(newItem)
                    }
                }
                self.listDataSubject.send(currentData.sorted{ $0.id < $1.id })
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
