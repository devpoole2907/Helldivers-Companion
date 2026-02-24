//
//  PlayerDistributionItem.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import SwiftUI


struct PlayerDistributionItem: Identifiable {
    var id: String { faction }
    let faction: String
    let count: Int64
    let color: Color
    let imageName: String
}
