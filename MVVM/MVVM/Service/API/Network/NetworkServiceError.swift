//
//  NetworkError.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

enum NetworkServiceError: APIErrorProtocol {
    case invalidURL
    case invalidResponse
    case statusCodeError(statusCode: Int)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .invalidResponse:
            return "응답 에러 발생"
        case .statusCodeError(let statusCode):
            return "statusCode 에러 발생: \(statusCode)"
        }
    }
}
