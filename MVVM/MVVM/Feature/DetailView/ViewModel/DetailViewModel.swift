//
//  DetailViewModel.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import Foundation

final class DetailViewModel {
    private let detailRepository: DetailRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private let imageCacheManager: ImageCacheManager
    private let id: Int
    
    init(dependencies: DetailDependencies, id: Int) {
        self.detailRepository = dependencies.detailRepository
        self.imageRepository = dependencies.imageRepository
        self.imageCacheManager = dependencies.imageCacheManager
        self.id = id
    }
    
    func fetchDetail() async throws -> DetailData {
        let response = try await detailRepository.fetchDetail(id: id)
        return DataFormatter.detailFormat(response: response)
        
    }
    
    func fetchImage() async throws -> Data? {
        if let cached = imageCacheManager.getImage(forKey: id) { return cached }
        
        guard let data = try await imageRepository.fetchImage(id: id) else { return nil }
        imageCacheManager.setImage(data, forKey: id)
        return data
    }
}
