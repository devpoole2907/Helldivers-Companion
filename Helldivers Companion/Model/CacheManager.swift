//
//  CacheManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/04/2024.
//

import Foundation
import SwiftUI

// to cache stratagems

class CacheManager {
    static let fileManager = FileManager.default
    static let cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory

    static func cache(image: UIImage, for key: String) {
        let filePath = cacheDirectory.appendingPathComponent("\(key).png")
        if let data = image.pngData() {
            try? data.write(to: filePath)
        }
    }

    static func getImage(for key: String) -> UIImage? {
        let filePath = cacheDirectory.appendingPathComponent("\(key).png")
        return UIImage(contentsOfFile: filePath.path)
    }
}
