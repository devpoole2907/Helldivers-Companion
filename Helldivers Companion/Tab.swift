//
//  Tab.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import Foundation

enum Tab: String, CaseIterable {
    case home = "War"
    case news = "News"
    case game = "Game"
    case about = "About"
    case orders = "Orders"
    
    var systemImage: String? {
        switch self {
        case .home:
            return "globe.americas.fill"
        case .game:
            return "scope"
        case .news:
            return "newspaper.fill"
        case .about:
            return "info.circle.fill"
        case .orders:
            return "target"
        }
    }
}
