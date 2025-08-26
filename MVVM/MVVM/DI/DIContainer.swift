//
//  DIContainer.swift
//  MVVM
//
//  Created by LCH on 8/25/25.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()
    private let imageCacheManager = ImageCacheManager.shared
    
    private init() {}
    
    func makeListDependencies() -> ListDependencies {
        let networkService = NetworkService()
        let listRepository = ListRepository(networkService: networkService)
        let imageRepository = ImageRepository(networkService: networkService)
        
        return ListDependencies(
            listRepository: listRepository,
            imageRepository: imageRepository,
            imageCacheManager: imageCacheManager
        )
    }
    
    func makeDetailDependencies() -> DetailDependencies {
        let networkService = NetworkService()
        let detailRepository = DetailRepository(networkService: networkService)
        let imageRepository = ImageRepository(networkService: networkService)
        
        return DetailDependencies(
            detailRepository: detailRepository,
            imageRepository: imageRepository,
            imageCacheManager: imageCacheManager
        )
    }
}
