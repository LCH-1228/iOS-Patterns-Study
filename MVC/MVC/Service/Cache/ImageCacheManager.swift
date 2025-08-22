
//
//  ImageCacheManager.swift
//  MVC
//
//  Created by LCH on 8/21/25.
//

import Foundation

final class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSNumber, NSData>()
    
    private init() {}
    
    func setImage(_ data: Data, forKey key: Int) {
        let nsData = NSData(data: data)
        let nsKey = NSNumber(value: key)
        cache.setObject(nsData, forKey: nsKey)
    }
    
    func getImage(forKey key: Int) -> Data? {
        let nsKey = NSNumber(value: key)
        if let nsData = cache.object(forKey: nsKey) {
            return Data(referencing: nsData)
        }
        return nil
    }
}
