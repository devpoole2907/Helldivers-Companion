//
//  PlanetStructs.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation
import SwiftUI

enum EnemyType: String {
    
    case terminid
    case automaton
    case illuminate
    
}

enum Faction: String {
    
    case terminid
    case automaton
    case human
    case illuminate
    
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
            let id32: Int
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
    var alert: String?
    var prominentAlert: String?
    var season: String
    var showIlluminate: Bool
    var apiAddress: String
    var startedAt: String // temporarily we will now store the start date statically
    
    
    func convertStartedAtToDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        print("Attempting to convert date: \(startedAt)")
        return dateFormatter.date(from: startedAt)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case alert, prominentAlert, season, showIlluminate, apiAddress, startedAt
    }
    // default init
    init(alert: String, prominentAlert: String?, season: String, showIlluminate: Bool, apiAddress: String, startedAt: String) {
        self.alert = alert
        self.prominentAlert = prominentAlert
        self.season = season
        self.showIlluminate = showIlluminate
        self.apiAddress = apiAddress
        self.startedAt = startedAt
    }
    
    // set prominent alert to nil if its empty
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alert = try container.decode(String.self, forKey: .alert)
        
        let prominentAlertValue = try container.decode(String.self, forKey: .prominentAlert)
        prominentAlert = prominentAlertValue.isEmpty ? nil : prominentAlertValue
        season = try container.decode(String.self, forKey: .season)
        showIlluminate = try container.decode(Bool.self, forKey: .showIlluminate)
        apiAddress = try container.decode(String.self, forKey: .apiAddress)
        startedAt = try container.decode(String.self, forKey: .startedAt)
    }
    
}

#if os(iOS)
let smallFont: CGFloat = 16
let mediumFont: CGFloat = 18
let largeFont: CGFloat = 24
let weatherIconSize: CGFloat = 16
#elseif os(watchOS)
let smallFont: CGFloat = 12
let mediumFont: CGFloat = 12
let largeFont: CGFloat = 16
let weatherIconSize: CGFloat = 8

#endif

// for weather effects, data comes from helldiverstrainingmanual api
struct Environmental: Decodable {
    var name: String
    var description: String
}
// for biomes, data comes from helldiverstrainingmanual api
struct Biome: Decodable {
    var slug: String?
    var description: String?
}
// for planets containing the data above, this additional data comes from helldiverstrainingmanual api
struct PlanetAdditionalInfo: Decodable {
    var name: String
    var sector: String
    var biome: Biome?
    var environmentals: [Environmental]
}

struct AdditionalPlanetsInfoResponse: Decodable {
    var planets: [String: PlanetAdditionalInfo]
}
// for galaxy statistics reponse
struct GalaxyStats: Decodable {
    let missionsWon: Int64
    let missionsLost: Int64
    let missionTime: Int64
    let bugKills: Int64
    let automatonKills: Int64
    let illuminateKills: Int64
    let bulletsFired: Int64
    let bulletsHit: Int64
    let timePlayed: Int64
    let deaths: Int64
    let revives: Int64
    let friendlies: Int64
    let missionSuccessRate: Int64
    let accuracy: Int
    
    // manual coding keys because accurracy is spelt wrong in the json response!
    enum CodingKeys: String, CodingKey {
        case missionsWon, missionsLost, missionTime, bugKills, automatonKills, illuminateKills,
             bulletsFired, bulletsHit, timePlayed, deaths, revives, friendlies, missionSuccessRate
        case accuracy = "accurracy" // Mapping the struct property to the actual JSON key
    }
    
}
// for planet stats in the galaxy stats response
struct PlanetStats: Decodable {
    let planetIndex: Int
    let missionsWon: Int64
    let missionsLost: Int64
    let missionTime: Int64
    let bugKills: Int64
    let automatonKills: Int64
    let illuminateKills: Int64
    let bulletsFired: Int64
    let bulletsHit: Int64
    let timePlayed: Int64
    let deaths: Int64
    let revives: Int64
    let friendlies: Int64
    let missionSuccessRate: Int64
    let accuracy: Int
    
    
    // again, accuracy is spelt wrong in the json response
    enum CodingKeys: String, CodingKey {
        case planetIndex, missionsWon, missionsLost, missionTime, bugKills, automatonKills, illuminateKills,
             bulletsFired, bulletsHit, timePlayed, deaths, revives, friendlies, missionSuccessRate, accuracy = "accurracy"
    }
    
}

// for helldiverstrainingmanual api

struct GalaxyStatsResponseData: Decodable {
    let galaxyStats: GalaxyStats
    let planetsStats: [PlanetStats]
}

// also comes from helldivers training manual api, eventually i will migrate all of this to its own api but to at least get the feature (defense time remaining) out the door here we go, fetches from a github cache tho:

struct PlanetExpiration: Decodable {
    let planetIndex: Int
    let name: String
    let expireDateTime: Double?
}

struct PlanetPosition {
    let name: String
    let index: Int
    let xMultiplier: Double
    let yMultiplier: Double
}

struct UpdatedPlanet: Decodable, Hashable {
    
    static func == (lhs: UpdatedPlanet, rhs: UpdatedPlanet) -> Bool {
        return lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
    
    var index: Int
    var name: String
    var sector: String
    var hash: Int64
    var position: Position
    var waypoints: [Int]
    var maxHealth: Int64
    var health: Int64
    var disabled: Bool
    var initialOwner: String
    var currentOwner: String
    var regenPerSecond: Double
    var event: UpdatedPlanetEvent?
    var statistics: UpdatedPlanetStatistics
    
    var environmentals: [Environmental]? // data comes from helldiverstrainingmanual api
    var biome: Biome? // data comes from helldiverstrainingmanual api
    
    
    // computed prop for liberation
    var percentage: Double {
        maxHealth > 0 ? (1 - (Double(health) / Double(maxHealth))) * 100 : 0
    }
    // if its associated with major order, put its task progress here
    var taskProgress: Int? = nil
    
}

struct UpdatedPlanetEvent: Decodable {
    
    var id: Int
    var eventType: Int64
    var faction: String
    var health: Int64
    var maxHealth: Int64
    var startTime: String
    var endTime: String
    var campaignId: Int64
    var jointOperationIds: [Int64]
    
    // computed prop for defense
    var percentage: Double {
        maxHealth > 0 ? (1 - (Double(health) / Double(maxHealth))) * 100 : 0
    }
    // computed prop to get event duration
    var totalDuration: Double? {
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        if let startTime = dateFormatter.date(from: startTime), let endTime = dateFormatter.date(from: endTime) {
            return endTime.timeIntervalSince(startTime)
        }
        
      return nil
        
        
    }
    
    // TODO: USE ACTUAL EXPIRY TIME FROM DEALLOCS NEW API INSTEAD OF TRAINING MANUAL
    var expireTimeDate: Date?
    
    
}

struct UpdatedPlanetStatistics: Decodable {
    var missionsWon: Int64
    var missionsLost: Int64
    var missionTime: Int64
    var terminidKills: Int64
    var automatonKills: Int64
    var illuminateKills: Int64
    var bulletsFired: Int64
    var bulletsHit: Int64
    var timePlayed: Int64
    var deaths: Int64
    var revives: Int64
    var friendlies: Int64
    var missionSuccessRate: Int64
    var accuracy: Int64
    var playerCount: Int64
}

struct UpdatedCampaign: Decodable, Hashable {
    
    static func == (lhs: UpdatedCampaign, rhs: UpdatedCampaign) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
    var id: Int
    var planet: UpdatedPlanet
    var type: Int64
    var count: Int64
}

struct UpdatedPlanetDataPoint {
    let timestamp: Date
    var planet: UpdatedPlanet?
}
