//
//  DetailRepository.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

protocol DetailRepositoryProtocol {
    func fetchDetail(id: Int) async throws -> DetailResponse
}

final class DetailRepository: DetailRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchDetail(id: Int) async throws -> DetailResponse {
        do {
            let data = try await networkService.fetchData(urlString: "https://pokeapi.co/api/v2/pokemon/\(id)")
            return try JSONDecoder().decode(DetailResponse.self, from: data)
        } catch {
            throw DetailRepositoryError.decodingFailed
        }
    }
}
