//
//  NetworkManager.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import Foundation

class NetworkManager {
    
    static var shared = NetworkManager()
    
    private init() {}
    
    func fetchPokemonList(offset: Int, completion: @escaping (Result<PokemonListResponse, Error>) -> Void) {
        fetchJSON(urlString: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=\(offset)") { result in
            completion(result)
        }
    }
    
    func fetchPokemonDetail(id: Int, completion: @escaping (Result<PokemonDetailResponse, Error>) -> Void) {
        fetchJSON(urlString: "https://pokeapi.co/api/v2/pokemon/\(id)") { result in
            completion(result)
        }
    }
    
    func fetchImage(id: Int, completion: @escaping (Result<Data?, Error>) -> Void) {
        let normal = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        let fallback = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
        
        fetchData(urlString: normal) { [weak self] result in
            switch result {
            case .success(let data):
                completion(.success(data))
                
            case .failure(NetworkError.statusCodeError(let code)) where code == 404:
                self?.fetchData(urlString: fallback) { fallbackResult in
                    switch fallbackResult {
                    case .success(let fallbackData):
                        completion(.success(fallbackData))
                    case .failure(NetworkError.statusCodeError(statusCode: let fallbackCode)) where fallbackCode == 404:
                        completion(.success(nil))
                    case .failure(let fallbackError):
                        completion(.failure(fallbackError))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension NetworkManager {
    
    private func fetchData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.statusCodeError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    private func fetchJSON<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        fetchData(urlString: urlString) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(NetworkError.decodingfailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
