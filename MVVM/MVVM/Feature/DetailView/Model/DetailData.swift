//
//  DetailData.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import Foundation

struct DetailData {
    let idAndName: String
    let type: String
    let height: String
    let weight: String
    var imageData: Data?
}

extension DetailData {
    static var defaultData: DetailData {
        return DetailData(
            idAndName: "No.알 수 없음",
            type: "타입: 알 수 없음",
            height: "키: 알 수 없음",
            weight: "몸무게: 알 수 없음",
            imageData: nil
        )
    }
}
