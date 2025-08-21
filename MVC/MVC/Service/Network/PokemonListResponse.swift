//
//  PokemonListResponse.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import Foundation

struct PokemonListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListData]
}

struct PokemonListData: Decodable, Hashable {
    let name: String
    let url: URL
    var id: Int? {
        return Int(url.lastPathComponent)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static func == (lhs: PokemonListData, rhs: PokemonListData) -> Bool {
        return lhs.url == rhs.url &&
        lhs.name == rhs.name &&
        lhs.id == rhs.id
    }
}
