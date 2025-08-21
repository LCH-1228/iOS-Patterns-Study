//
//  PokemonDetailResponse.swift
//  MVC
//
//  Created by LCH on 8/18/25.
//

import Foundation

struct PokemonDetailResponse: Decodable {
    let name: String
    let height: Int
    let weight: Int
    let types: [TypeElements]
    let id: Int
}

struct TypeElements: Decodable {
    let type: TypeElement
}

struct TypeElement: Decodable {
    let name: PokemonType
}
