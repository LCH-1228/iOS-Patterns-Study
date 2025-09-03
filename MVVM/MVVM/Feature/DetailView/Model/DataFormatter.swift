//
//  DataFormatter.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import Foundation

struct DataFormatter {
    static func detailFormat(response: DetailResponse) -> DetailData {
        let detailData = DetailData(
            idAndName: "No.\(response.id)  \(PokemonName.translate(name: response.name))",
            type: "타입: \(response.types[0].type.name.translatedType)",
            height: "키: \(Float(response.height) / 10) m",
            weight: "몸무게: \(Float(response.weight) / 10) kg",
            imageData: nil
        )
        return detailData
    }
}
