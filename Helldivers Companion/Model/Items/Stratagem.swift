//
//  Stratagem.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct Stratagem: Equatable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
    var sequence: [StratagemInput] // arrow key sequence
    var type: StratagemType
    var imageUrl: String?
    var videoUrl: String?
}

enum StratagemInput: String, Codable {
    case up = "up"
    case down = "down"
    case left = "left"
    case right = "right"
}


enum StratagemType: String, Codable, CaseIterable {
    case admin = "admin"
    case orbital = "orbital"
    case hangar = "hangar"
    case bridge = "bridge"
    case engineering = "engineering"
    case workshop = "workshop"
    case mission = "mission"
    
    var title: String {
        switch self {
        case .admin:
            return "Patriotic Administration Center"
        case .orbital:
            return "Orbital Cannons"
        case .hangar:
            return "Hangar"
        case .bridge:
            return "Bridge"
        case .engineering:
            return "Engineering Bay"
        case .workshop:
            return "Robotics Workshop"
        case .mission:
            return "Mission Stratagems"
        }
    }
}

// for stratagems displayed from hellhub api
struct DecodedStratagemData: Codable {
    let data: [DecodedStratagem]
}


struct DecodedStratagem: Codable {
    let id: Int
    let codename: String?
    let name: String
    let keys: [String]
    let uses: String
    let cooldown: Int?
    let activation: Int?
    let groupId: Int

}
