//
//  ListDependency.swift
//  MVVM
//
//  Created by LCH on 8/25/25.
//

import Foundation

struct ListDependencies {
    let listRepository: ListRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol
    let imageCacheManager: ImageCacheManager
}
