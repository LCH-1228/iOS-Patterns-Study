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
    var image: Data?
    let id: Int
    var isLoading: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(image)
        hasher.combine(isLoading)
    }
    
    static func == (lhs: ListData, rhs: ListData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.image == rhs.image &&
        lhs.isLoading == rhs.isLoading
    }
}
