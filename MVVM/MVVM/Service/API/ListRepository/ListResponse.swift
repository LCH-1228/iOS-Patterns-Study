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
    let results: [ListResult]
}

struct ListResult: Decodable, Hashable {
    let name: String
    let url: URL
}
