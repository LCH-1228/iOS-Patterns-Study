//
//  ListRepositoryError.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

enum ListRepositoryError: APIErrorProtocol {
    case decodingFailed
    
    var message: String {
        switch self {
        case .decodingFailed:
            return "디코딩에 실패했습니다."
        }
    }
}
