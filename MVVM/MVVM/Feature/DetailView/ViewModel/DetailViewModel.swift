//
//  DetailViewModel.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import Foundation
import Combine

final class DetailViewModel: ViewModelProtocol {
    private let detailRepository: DetailRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private let imageCacheManager: ImageCacheManager
    private let id: Int
    
    private lazy var detailDataSubject = PassthroughSubject<DetailData, Never>()
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = PassthroughSubject<Error, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    struct Input {
        let initialFetch: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let detailDataPublisher: AnyPublisher<DetailData ,Never>
        let isLoadingPublisher: AnyPublisher<Bool, Never>
        let errorPublisher: AnyPublisher<Error, Never>
    }
    
    init(dependencies: DetailDependencies, id: Int) {
        self.detailRepository = dependencies.detailRepository
        self.imageRepository = dependencies.imageRepository
        self.imageCacheManager = dependencies.imageCacheManager
        self.id = id
    }
    
    func transform(_ input: Input) -> Output {
        
        input.initialFetch
            .filter{ [weak self] _ in
                guard let self else { return false }
                return !self.isLoadingSubject.value
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self else { return }
                self.isLoadingSubject.send(true)
            })
            .flatMap { [weak self] _ -> AnyPublisher<DetailData, Error> in
                guard let self else {
                    return Empty<DetailData, Error>()
                        .eraseToAnyPublisher()
                }
                
                return Future<DetailData, Error> { future in
                    Task {
                        do {
                            let response = try await self.fetchDetail()
                            future(.success(response))
                        } catch {
                            future(.failure(error))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .flatMap { [weak self] info in
                guard let self else {
                    return Empty<DetailData, Error>()
                        .eraseToAnyPublisher()
                }
                
                return Future<DetailData, Error> { future in
                    Task {
                        do {
                            let imageData = try await self.fetchImage()
                            var data = info
                            data.imageData = imageData
                            future(.success(data))
                        } catch {
                            future(.failure(error))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .catch({ [weak self] error in
                self?.errorSubject.send(error)
                self?.isLoadingSubject.send(false)
                return Just(DetailData.defaultData)
            })
            .handleEvents(receiveOutput: { _ in
                self.isLoadingSubject.send(false)
            })
            .sink { [weak self] detailData in
                guard let self else { return }
                detailDataSubject.send(detailData)
            }
            .store(in: &cancellable)
                
        return Output(
            detailDataPublisher: detailDataSubject.eraseToAnyPublisher(),
            isLoadingPublisher: isLoadingSubject.eraseToAnyPublisher(),
            errorPublisher: errorSubject.eraseToAnyPublisher()
        )
    }
    
    private func fetchDetail() async throws -> DetailData {
        let response = try await detailRepository.fetchDetail(id: id)
        return DataFormatter.detailFormat(response: response)
        
    }
    
    private func fetchImage() async throws -> Data? {
        if let cached = imageCacheManager.getImage(forKey: id) { return cached }
        
        guard let data = try await imageRepository.fetchImage(id: id) else { return nil }
        imageCacheManager.setImage(data, forKey: id)
        return data
    }
}
