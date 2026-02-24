//
//  Array+Safe.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
