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
    
    // tired, this will do for type 3 major orders for now i need to get this feat out the door
    var isEradicateType: Bool {
            setting.tasks.first?.type == 3
        }
    // defense x number of planets types
    var isDefenseType: Bool {
        setting.tasks.first?.type == 12
    }
    
    // if an eradication type major order
    
    var eradicationProgress: Double? {
            guard isEradicateType,
                  let currentProgress = progress.first,
                  let totalGoal = setting.tasks.first?.values[2] else {
                return nil
            }
            return Double(currentProgress) / Double(totalGoal)
        }
    
    var defenseProgress: Double? {
        
        guard isDefenseType, let currentProgress = progress.first, let totalGoal = setting.tasks.first?.values.first else {
            return nil
        }
        
        return Double(currentProgress) / Double(totalGoal)
        
        
    }
    
    
        
    // for the eradicate/defend major orders overlay
        var progressString: String? {
            
            if isEradicateType, let eradicationProgress = eradicationProgress {
                let percentage = eradicationProgress * 100
                return "\(progress.first!)/\(setting.tasks.first!.values[2]) (\(String(format: "%.1f", percentage))%)"
            } else if isDefenseType, let defenseProgress = defenseProgress {
                let percentage = defenseProgress * 100
                return "\(progress.first!)/\(setting.tasks.first!.values.first!) (\(String(format: "%.1f", percentage))%)"
            }
            
            return nil
            
        }
    
    var faction: Faction? {
            guard isEradicateType, let factionIndex = setting.tasks.first?.values[0] else {
                return nil
            }
            return Faction(rawValue: factionIndex) ?? .unknown
        }
    
    // this could become global, but most of our api responses come from the dealloc endpoints not the official. for now the MO comes from the official endpoint, in hopes/possibility that deallocs major order endpoint may be upgraded
    enum Faction: Int {
            case human = 1
            case terminid = 2
            case automaton = 3
            case illuminate = 4
            case unknown

            var color: Color {
                switch self {
                case .human:
                    return Color.cyan
                case .terminid:
                    return Color.yellow
                case .automaton:
                    return Color.red
                case .illuminate:
                    return Color.purple
                case .unknown:
                    return Color.white
                }
            }
        }
    
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
    
    func removeHTMLTags(from string: String) -> String? {
        let pattern = "<[^>]*>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        return regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
    }
    
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
        
        // processing into title/message, sanitise html tags
        if let msg = message, let sanitisedMessage = removeHTMLTags(from: msg) {
            // check for new line in message
            if let newlineIndex = sanitisedMessage.firstIndex(of: "\n") {
                // if we find a new line in the message then seperate to title/message
                title = String(sanitisedMessage[..<newlineIndex])
                message = String(sanitisedMessage[sanitisedMessage.index(after: newlineIndex)...])
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

struct Environmental: Decodable {
    var name: String
    var description: String
}

struct Biome: Decodable {
    var name: String
    var description: String
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
    var biome: Biome
    var hazards: [Environmental]
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
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let startTime = dateFormatter.date(from: startTime), let endTime = dateFormatter.date(from: endTime) {
            return endTime.timeIntervalSince(startTime)
        } else {
            // try parsing without fractional seconds if first attempt fails
            dateFormatter.formatOptions = [.withInternetDateTime]
            if let startTime = dateFormatter.date(from: startTime),
               let endTime = dateFormatter.date(from: endTime) {
                return endTime.timeIntervalSince(startTime)
            }
            
        }
        
      return nil
        
        
    }
    
    var expireTimeDate: Date? {
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let endTime = dateFormatter.date(from: endTime) {
            return endTime
            
        } else {
            // same as above
            dateFormatter.formatOptions = [.withInternetDateTime]
            if let endTime = dateFormatter.date(from: endTime) {
                return endTime
            }
        }
        
        return nil
        
        
    }
    
    
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
