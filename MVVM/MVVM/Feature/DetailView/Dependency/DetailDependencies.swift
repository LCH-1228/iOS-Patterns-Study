//
//  DetailDependencies.swift
//  MVVM
//
//  Created by LCH on 8/26/25.
//

import Foundation

struct DetailDependencies {
    let detailRepository: DetailRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol
    let imageCacheManager: ImageCacheManager
}
