//
//  NetworkManager.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import Foundation

final class NetworkManager {
    
    static var shared = NetworkManager()
    
    private init() {}
    
    func fetchPokemonList(offset: Int) async throws -> PokemonListResponse {
        try await fetchJSON(urlString: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)")
    }
    
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailResponse {
        try await fetchJSON(urlString: "https://pokeapi.co/api/v2/pokemon/\(id)")
    }
    
    func fetchImage(id: Int) async throws -> Data? {
        let normal = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        let fallback = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
        
        do {
            return try await fetchData(urlString: normal)
        } catch NetworkError.statusCodeError(let code) where code == 404 {
            do {
                return try await fetchData(urlString: fallback)
            } catch NetworkError.statusCodeError(let fallbackCode) where fallbackCode == 404 {
                return nil
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
}

private extension NetworkManager {
    
    private func fetchData(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCodeError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    private func fetchJSON<T: Decodable>(urlString: String) async throws -> T {
        let data = try await fetchData(urlString: urlString)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingfailed
        }
    }
}
