//
//  NetworkError.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestfailed
    case invalidResponse
    case statusCodeError(statusCode: Int)
    case noData
    case decodingfailed
    case InvalidImageData
    
    var message: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .requestfailed:
            return "네트워크 요청이 실패했습니다."
        case .invalidResponse:
            return "응답 에러 발생"
        case .statusCodeError(let statusCode):
            return "statusCode 에러 발생: \(statusCode)"
        case .noData:
            return "응답받은 데이터가 없습니다."
        case .decodingfailed:
            return "디코딩에 실패했습니다."
        case .InvalidImageData:
                    return "유효하지 않은 이미지 데이터 입니다."
        }
    }
}
