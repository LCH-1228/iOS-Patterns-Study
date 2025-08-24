//
//  NetworkService.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchData(urlString: String) async throws -> Data
}

class NetworkService: NetworkServiceProtocol {
    func fetchData(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkServiceError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkServiceError.statusCodeError(statusCode: httpResponse.statusCode)
        }
        return data
    }
}
