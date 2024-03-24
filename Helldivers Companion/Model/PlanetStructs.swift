//
//  PlanetStructs.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation
import SwiftUI

struct WarStatusResponse: Decodable {
    let campaigns: [Campaign]
    let planetStatus: [PlanetStatus]
    var planetEvents: [PlanetEvent]
    let snapshotAt: String
    let warId: Int
}

struct Campaign: Decodable {
    let count: Int
    let id: Int
    let planet: Planet
    let type: Int
}

struct PlanetDataPoint {
    let timestamp: Date
    var status: PlanetStatus?
    var event: PlanetEvent?
    var liberationRate: Double?
    
}

struct PlanetStatus: Decodable, Hashable {
    static func == (lhs: PlanetStatus, rhs: PlanetStatus) -> Bool {
        return lhs.planet.index == rhs.planet.index
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(planet.index)
        }
    
    
    let health: Int
    var liberation: Double
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
    let hash: UInt
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
    let id32: Int64 // this must be int64 to run on watchOS!
    let progress: [Int]
    let expiresIn: Int64 // this must be int64 to run on watchOS!
    let setting: Setting
    
    enum CodingKeys: String, CodingKey {
        case id32
        case progress
        case expiresIn
        case setting
    }

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
            let id32: Int // this must be int64 to run on watchOS!
            let amount: Int
        }
    }
    
    
}

struct Message: Decodable {
    let de, en, es, fr, it, pl, ru, zh: String?
}

struct NewsFeed: Decodable, Hashable {
    let id: Int
    var message: String?
    var title: String?
    let published: UInt32?
    let tagIds: [Int]
    let type: Int
    
    private enum CodingKeys: String, CodingKey {
            case id, message, published, tagIds, type
        }
    
    // custom init handles decoding/processing of message to seperate to title/message if possible
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            published = try container.decodeIfPresent(UInt32.self, forKey: .published)
            tagIds = try container.decode([Int].self, forKey: .tagIds)
            type = try container.decode(Int.self, forKey: .type)
            message = try container.decode(String.self, forKey: .message)
            
       // processing into title/message
            if let msg = message {
                // check for new line in message
                if let newlineIndex = msg.firstIndex(of: "\n") {
                   // if we find a new line in the message then seperate to title/message
                    title = String(msg[..<newlineIndex])
                    message = String(msg[msg.index(after: newlineIndex)...])
                }
            }
        }
}

struct GitHubFile: Decodable {
    let name: String
    let downloadUrl: String

}

struct RemoteConfigDetails: Decodable {
    var terminidRate: String
    var automatonRate: String
    var alert: String?
    var prominentAlert: String?
    
    private enum CodingKeys: String, CodingKey {
            case terminidRate, automatonRate, alert, prominentAlert
        }
    // default init
    init(terminidRate: String, automatonRate: String, alert: String, prominentAlert: String?) {
            self.terminidRate = terminidRate
            self.automatonRate = automatonRate
            self.alert = alert
            self.prominentAlert = prominentAlert
        }
    
    // set prominent alert to nil if its empty
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            terminidRate = try container.decode(String.self, forKey: .terminidRate)
            automatonRate = try container.decode(String.self, forKey: .automatonRate)
            alert = try container.decode(String.self, forKey: .alert)
            
            let prominentAlertValue = try container.decode(String.self, forKey: .prominentAlert)
            prominentAlert = prominentAlertValue.isEmpty ? nil : prominentAlertValue
        }
    
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

