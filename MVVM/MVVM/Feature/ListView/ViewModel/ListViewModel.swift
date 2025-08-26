//
//  ListViewModel.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

final class ListViewModel {
    private let listRepository: ListRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private let imageCacheManager: ImageCacheManager
    private let navigateToDetail: (Int) -> Void
    
    private var isFetching = false
    private var offset = 0
    private(set) var listData = [ListData]()
    private(set) var isEnd = false
    private var imageFetchTasks = [Int: Task<Data?, Error>]()
    private let imageFetchQueue = DispatchQueue(label: "imageFetchQueue")
    
    init(dependencies: ListDependencies, navigateToDetail: @escaping (Int) -> Void) {
        self.listRepository = dependencies.listRepository
        self.imageRepository = dependencies.imageRepository
        self.imageCacheManager = dependencies.imageCacheManager
        self.navigateToDetail = navigateToDetail
    }
    
    private func fetchList() async throws -> ListResponse {
        isFetching = true
        defer { isFetching = false }
        let response = try await listRepository.fetchList(offset: offset)
        
        return response
    }
    
    func fetchCellData() async throws {
        guard !isFetching else { return }
        isFetching = true
        
        let response = try await fetchList()
        listData.append(contentsOf: response.results)
        isEnd = response.next == nil ? true : false
        offset += 20
    }
    
    func fetchImage(id: Int) async throws -> Data? {
        if let cached = imageCacheManager.getImage(forKey: id) {
            return cached
        }
        
        imageFetchQueue.sync {
            imageFetchTasks[id]?.cancel()
        }
        
        let task = Task { [weak self] () -> Data? in
            guard let self else { return nil }
            if let data = try await self.imageRepository.fetchImage(id: id) {
                self.imageCacheManager.setImage(data, forKey: id)
                return data
            }
            return nil
        }
        
        imageFetchQueue.sync {
            imageFetchTasks[id] = task
        }
        
        let result = try await task.value
        imageFetchQueue.sync {
            imageFetchTasks[id] = nil
        }
        return result
    }
    
    func cancelImageFetch(id: Int) {
        imageFetchQueue.sync {
            imageFetchTasks[id]?.cancel()
            imageFetchTasks[id] = nil
        }
    }
    
    func showDetail(id: Int) {
        navigateToDetail(id)
    }
}
