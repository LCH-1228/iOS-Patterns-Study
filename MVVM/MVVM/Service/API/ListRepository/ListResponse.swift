//
//  ListResponse.swift
//  MVVM
//
//  Created by LCH on 8/23/25.
//

import Foundation

struct ListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [ListData]
}

struct ListData: Decodable, Hashable {
    let name: String
    let url: URL
    var id: Int? {
        return Int(url.lastPathComponent)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        if let id {
            hasher.combine(id)
        }
        hasher.combine(name)
    }
    
    static func == (lhs: ListData, rhs: ListData) -> Bool {
        return lhs.url == rhs.url &&
        lhs.name == rhs.name &&
        lhs.id == rhs.id
    }
}
