//
//  PlanetStructs.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation

struct WarStatusResponse: Decodable {
    let planetStatus: [PlanetStatus]
    let snapshotAt: String
    let warId: Int
}


struct PlanetStatus: Decodable, Hashable {
    static func == (lhs: PlanetStatus, rhs: PlanetStatus) -> Bool {
        return lhs.planet.index == rhs.planet.index
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(planet.index)
        }
    
    
    let health: Int
    let liberation: Double
    let owner: String
    let planet: Planet
    let players: Int
    let regenPerSecond: Double
}

struct Planet: Decodable {
    let disabled: Bool
    let hash: UInt32
    let index: Int
    let initialOwner: String
    let maxHealth: Int
    let name: String
    let position: Position
    let sector: String
    let waypoints: [Int]
}

struct Position: Decodable {
    let x: Double
    let y: Double
}

struct WarSeason: Decodable {
    
    let current: String
    
    
}

struct MajorOrderResponse: Decodable {
    let assignmentId32: Int
    let effects: [String]
    let flag: Int
    let id: Int
    let id32: Int
    let message: Message
    let messageId32: Int
    let planets: [String]
    let portraitId32: Int
    let race: String
    let title: String
    let title32: Int
    
 
    
}

struct Message: Decodable {
    
    let en: String
    
    
    
}
