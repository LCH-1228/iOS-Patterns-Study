//
//  DIContainer.swift
//  MVVM
//
//  Created by LCH on 8/25/25.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()
    
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    private lazy var listRepository: ListRepositoryProtocol = ListRepository(networkService: self.networkService)
    private lazy var detailRepository: DetailRepositoryProtocol = DetailRepository(networkService: self.networkService)
    private lazy var imageRepository: ImageRepositoryProtocol = ImageRepository(networkService: self.networkService)
    private lazy var imageCacheManager = ImageCacheManager.shared
    
    private init() {}
    
    func makeListDependencies() -> ListDependencies {
        return ListDependencies(
            listRepository: listRepository,
            imageRepository: imageRepository,
            imageCacheManager: imageCacheManager
        )
    }
    
    func makeDetailDependencies() -> DetailDependencies {
        return DetailDependencies(
            detailRepository: detailRepository,
            imageRepository: imageRepository,
            imageCacheManager: imageCacheManager
        )
    }
}
