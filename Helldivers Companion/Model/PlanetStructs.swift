//
//  PlanetStructs.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation
import SwiftUI

struct WarStatusResponse: Decodable {
    let planetStatus: [PlanetStatus]
    var planetEvents: [PlanetEvent]
    let snapshotAt: String
    let warId: Int
}

struct PlanetDataPoint {
    let timestamp: Date
    var status: PlanetStatus?
    var event: PlanetEvent?
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
    var defensePercentage: Double?
    
}

struct PlanetEvent: Decodable {
    let planet: Planet
    let health: Int
    let maxHealth: Int
    let race: String
    var planetStatus: PlanetStatus?
    
    // computed property, calcs defense percent
   var defensePercentage: Double {
            maxHealth > 0 ? (1 - (Double(health) / Double(maxHealth))) * 100 : 0
        }

        enum CodingKeys: String, CodingKey {
            case planet
            case health
            case maxHealth
            case race
        }
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


struct MajorOrder: Decodable {
    let id32: Int
    let progress: [Int]
    let expiresIn: Int
    let setting: Setting

    struct Setting: Decodable {
        let type: Int
        let overrideTitle: String
        let overrideBrief: String
        let taskDescription: String
        let tasks: [Task]
        let reward: Reward
        let flags: Int

        struct Task: Decodable {
            let type: Int
            let values: [Int]
            let valueTypes: [Int]
        }

        struct Reward: Decodable {
            let type: Int
            let id32: Int
            let amount: Int
        }
    }
}

struct Message: Decodable {
    let de, en, es, fr, it, pl, ru, zh: String?
}

struct NewsFeed: Decodable {
    let id: Int
    let message: Message?
    let published: String?
    let tagIds: [Int]
    let type: Int
}

struct GitHubFile: Decodable {
    let name: String
    let downloadUrl: String

}

struct RemoteConfigDetails: Decodable {
    let terminidRate: String
    let automatonRate: String
    let alert: String?
}

#if os(iOS)
let smallFont: CGFloat = 16
let mediumFont: CGFloat = 18
let largeFont: CGFloat = 24
#elseif os(watchOS)
let smallFont: CGFloat = 12
let mediumFont: CGFloat = 12
let largeFont: CGFloat = 16
#endif

