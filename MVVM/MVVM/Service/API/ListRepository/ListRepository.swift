//
//  ListRepository.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

protocol ListRepositoryProtocol {
    func fetchList(offset: Int) async throws -> ListResponse
}

final class ListRepository: ListRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchList(offset: Int) async throws -> ListResponse {
        do {
            let data = try await networkService.fetchData(urlString: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)")
            return try JSONDecoder().decode(ListResponse.self, from: data)
        } catch {
            throw ListRepositoryError.decodingFailed
        }
    }
}
