//
//  PokemonDetailFormatter.swift
//  MVC
//
//  Created by LCH on 8/21/25.
//

import Foundation

struct PokemonDataFormatter {
    
    static func detailFormat(response: PokemonDetailResponse) -> PokemonDetailData {
        let pokemonData = PokemonDetailData(
            idAndName: "No.\(response.id)  \(PokemonName.translate(name: response.name))",
            type: "타입: \(response.types[0].type.name.translatedType)",
            height: "키: \(Float(response.height) / 10) m",
            weight: "몸무게: \(Float(response.weight) / 10) kg")
        return pokemonData
    }
}
