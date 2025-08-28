//
//  ListData.swift
//  MVVM
//
//  Created by LCH on 8/28/25.
//

import Foundation

struct ListData: Hashable {
    let name: String
    let url: URL
    let imageData: Data?
    var id: Int
    // TODO: loadingIndicator 관련 isLoading Bool 추가 필요
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ListData, rhs: ListData) -> Bool {
        return lhs.id == rhs.id
    }
}
