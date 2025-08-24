//
//  ImageRepository.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

protocol ImageRepositoryProtocol {
    func fetchImage(id: Int) async throws -> Data?
}

final class ImageRepository: ImageRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchImage(id: Int) async throws -> Data? {
        let normal = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        let fallback = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
        
        do {
            return try await networkService.fetchData(urlString: normal)
        } catch NetworkServiceError.statusCodeError(let code) where code == 404 {
            do {
                return try await networkService.fetchData(urlString: fallback)
            } catch NetworkServiceError.statusCodeError(let fallbackCode) where fallbackCode == 404 {
                return nil
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
}
