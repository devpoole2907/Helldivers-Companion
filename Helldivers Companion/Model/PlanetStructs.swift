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

struct PersonalOrder: Decodable {
    let id32: Int64
    let progress: [Int64]? // optional progress
    let expiresIn: Int64 // time in seconds until expiration
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
        let rewards: [Reward]
        let reward: Reward?
        let flags: Int

        struct Task: Decodable, Equatable {
            let type: Int
            let values: [Int64]
            let valueTypes: [Int]
        }

        struct Reward: Decodable {
            let type: Int
            let id32: Int
            let amount: Int
        }
    }
}


struct MajorOrder: Decodable {
    let id32: Int64 // this must be int64 to run on watchOS!
    let progress: [Int64]
    let expiresIn: Int64 // this must be int64 to run on watchOS!
    let setting: Setting
    
    var eradicateTasks: [Setting.Task] {
        setting.tasks.filter { $0.type == 3 }
    }
    var defenseTasks: [Setting.Task] {
        setting.tasks.filter { $0.type == 12 }
    }
    var netQuantityTasks: [Setting.Task] {
        setting.tasks.filter { $0.type == 15 }
    }
    var liberationTasks: [Setting.Task] {
        setting.tasks.filter { $0.type == 11 || $0.type == 13 }
    }
    
    var isEradicateType: Bool { !eradicateTasks.isEmpty }
    var isDefenseType: Bool    { !defenseTasks.isEmpty }
    var isNetQuantityType: Bool { !netQuantityTasks.isEmpty }
    var isLiberationType: Bool  { !liberationTasks.isEmpty }
    
    // if an eradication type major order
    
    var eradicationProgress: [(progress: Double, progressString: String)]? {
        guard isEradicateType else { return nil }
        return eradicateTasks.compactMap { task in
            // find the index of this task in `setting.tasks` to match against `progress`
            guard let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex],
                  let totalGoal = task.values[safe: 2]
            else {
                return nil
            }
            
            let progressValue = Double(currentProgress) / Double(totalGoal)
            let progressString = "\(currentProgress)/\(totalGoal) (\(String(format: "%.1f", progressValue * 100))%)"
            return (progressValue, progressString)
        }
    }
    
    var defenseProgress: [(progress: Double, progressString: String)]? {
        guard isDefenseType else { return nil }
        return defenseTasks.compactMap { task in
            guard let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex],
                  let totalGoal = task.values.first
            else {
                return nil
            }
            
            let progressValue = Double(currentProgress) / Double(totalGoal)
            let progressString = "\(currentProgress)/\(totalGoal) (\(String(format: "%.1f", progressValue * 100))%)"
            return (progressValue, progressString)
        }
    }
    
    var netQuantityProgress: [(progress: Double, progressString: String)]? {
        guard isNetQuantityType else { return nil }
        return netQuantityTasks.compactMap { task in
            guard let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex]
            else {
                return nil
            }
            
            let maxProgressValue: Double = 10
            let normalizedProgress = 1 - (Double(currentProgress) + maxProgressValue) / (2 * maxProgressValue)
            
            let progressString = "\(currentProgress) (normalized: \(String(format: "%.1f", normalizedProgress * 100))%)"
            return (normalizedProgress, progressString)
        }
    }
    
    
    var faction: Faction? {
        if isEradicateType, let factionIndex = eradicateTasks.first?.values[safe: 0] {
            return Faction(rawValue: factionIndex) ?? .unknown
        } else if isDefenseType, let factionIndex = defenseTasks.first?.values[safe: 1] {
            return Faction(rawValue: factionIndex) ?? .unknown
        } else {
            return nil
        }
    }
    
    // if multiple rewards, return both, otherwise return the singular
    var allRewards: [Setting.Reward] {
            return setting.rewards.isEmpty ? [setting.reward] : setting.rewards
        }
    
    // this could become global, but most of our api responses come from the dealloc endpoints not the official. for now the MO comes from the official endpoint, in hopes/possibility that deallocs major order endpoint may be upgraded
    enum Faction: Int64 { // must be int64 due to the possible massive task value
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
        let rewards: [Reward]
        let reward: Reward
        let flags: Int
        
        struct Task: Decodable, Equatable {
            let type: Int
            let values: [Int64]
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
    var taskProgress: Int64? = nil
    
}

struct WarStatusResponse: Decodable {
    let time: Int64
}

struct SpaceStation: Decodable {
    let id32: Int64
    let planet: UpdatedPlanet
    let electionEnd: String
    let flags: Int
    
    var electionEndDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // try parse w fractional seconds
        if let parsedDate = dateFormatter.date(from: electionEnd) {
            return parsedDate
        } else {
            // fallback no fractional secs
            dateFormatter.formatOptions = [.withInternetDateTime]
            return dateFormatter.date(from: electionEnd)
        }
    }
    
}

struct SpaceStationDetails: Decodable {
    let id32: Int64
    let planetIndex: Int
    let lastElectionId: String
    let currentElectionId: String
    let nextElectionId: String
    let currentElectionEndWarTime: Int
    let flags: Int
    let tacticalActions: [TacticalAction]
}

struct TacticalAction: Decodable {
    let id32: Int64
    let mediaId32: Int64
    let name: String
    let description: String
    let strategicDescription: String
    let status: Int
    let statusExpireAtWarTimeSeconds: Int
    let cost: [ActionCost]
    let effectIds: [Int]
    let activeEffectIds: [Int]
}

struct ActionCost: Decodable {
    let id: String
    let itemMixId: Int64
    let targetValue: Double
    let currentValue: Double
    let deltaPerSecond: Double
    let maxDonationAmount: Int
    let maxDonationPeriodSeconds: Int
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

struct DecodedStratagemData: Codable {
    let data: [DecodedStratagem]
}

// for stratagems displayed from hellhub api
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


struct Weapon: Codable, Hashable, DetailItem {
    let id: String
    var name: String
    var description: String
    var type: Int? // only for primaries-
    var damage: Int
    var capacity: Int
    var recoil: Int
    var fireRate: Int
    var fireMode: [Int]
    var traits: [Int]
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idKey = container.codingPath.last!.stringValue
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        damage = try container.decode(Int.self, forKey: .damage)
        capacity = try container.decode(Int.self, forKey: .capacity)
        recoil = try container.decode(Int.self, forKey: .recoil)
        fireRate = try container.decode(Int.self, forKey: .fireRate)
        fireMode = try container.decode([Int].self, forKey: .fireMode)
        traits = try container.decode([Int].self, forKey: .traits)
    }
}

struct Grenade: Codable, Hashable, DetailItem {
    let id: String
    var name: String
    var description: String
    var damage: Int
    var penetration: Int?
    var outerRadius: Int?
    var fuseTime: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idKey = container.codingPath.last!.stringValue
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        damage = try container.decode(Int.self, forKey: .damage)
        penetration = try container.decode(Int.self, forKey: .penetration)
        outerRadius = try container.decode(Int.self, forKey: .outerRadius)
        fuseTime = try container.decode(Double.self, forKey: .fuseTime)
    }
    
}

protocol DetailItem {
    var id: String { get }
    var name: String { get }
}


struct WeaponType: Codable {
    var id: Int
    var name: String
}

struct Trait: Codable {
    var id: Int
    var description: String
}

struct FireMode: Codable {
    var id: Int
    var mode: String
}

struct Booster: Codable, DetailItem {
    let id: String
    var name: String
    var description: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idKey = container.codingPath.last!.stringValue
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description
    }
    
}

struct Armour: Codable, Hashable, DetailItem {
    let id: String
    let name: String
    var description: String? = nil
    let type: Int
    let slot: Int
    let armourRating: Int
    let speed: Int
    let staminaRegen: Int
    let passive: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idKey = container.codingPath.last!.stringValue
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        type = try container.decode(Int.self, forKey: .type)
        slot = try container.decode(Int.self, forKey: .slot)
        armourRating = try container.decode(Int.self, forKey: .armourRating)
        speed = try container.decode(Int.self, forKey: .speed)
        staminaRegen = try container.decode(Int.self, forKey: .staminaRegen)
        passive = try container.decode(Int.self, forKey: .passive)
    }
    
    init(id: String, name: String, description: String? = nil, type: Int, slot: Int, armourRating: Int, speed: Int, staminaRegen: Int, passive: Int) {
            self.id = id
            self.name = name
            self.description = description
            self.type = type
            self.slot = slot
            self.armourRating = armourRating
            self.speed = speed
            self.staminaRegen = staminaRegen
            self.passive = passive
        }
    
    enum CodingKeys: String, CodingKey {
        // NOTE: everything gets decoded from snake case, in the data the armour rating is actually armor_rating/stamina_regen etc
        case name, description, type, slot, armourRating = "armorRating", speed, staminaRegen = "staminaRegen", passive
    }
}

struct ArmourSlot: Codable {
    
    var id: Int
    var name: String
    
}

struct Passive: Codable, Identifiable {
    var id: Int
    let name: String
    let description: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let idKey = container.codingPath.last!.stringValue
        
        guard let id = Int(idKey) else {
                    throw DecodingError.dataCorruptedError(forKey: .id,
                      in: container,
                      debugDescription: "ID not an int")
                }
                self.id = id
        
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
    }
    
    enum CodingKeys: String, CodingKey {
            case id, name, description
        }
    
}

struct WarBond: Hashable {
    static func == (lhs: WarBond, rhs: WarBond) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var name: String
    var medalsToUnlock: Int
    var items: [WarBondItem]
    
}

struct WarBondSection: Hashable {
    var sectionId: Int
    var medalsToUnlock: Int
    var items: [WarBondItem]
}

struct WarBondDetails: Decodable {
    var medalsToUnlock: Int
    var items: [WarBondItem]
}

struct WarBondItem: Decodable, Hashable {
    var itemId: Int
    var medalCost: Int
}

struct FixedWarBond: Hashable {
    
    var id = UUID()
    var warbondPages: [WarBond]
    
    
}

struct SuperStoreResponse: Decodable {
    var expireTime: Date?
    var items: [StoreItem]
}

struct StoreItem: Codable, Identifiable {
    static func == (lhs: StoreItem, rhs: StoreItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UUID
    var name: String
    var description: String
    var type: String
    var slot: String
    var armorRating: Int
    var speed: Int
    var staminaRegen: Int
    var passive: StoreItemPassive
    var storeCost: Int?
    
    enum CodingKeys: String, CodingKey {
           case name
           case description
           case type
           case slot
           case armorRating
           case speed
           case staminaRegen
           case passive
           case storeCost
       }
       
       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           name = try container.decode(String.self, forKey: .name)
           description = try container.decode(String.self, forKey: .description)
           type = try container.decode(String.self, forKey: .type)
           slot = try container.decode(String.self, forKey: .slot)
           armorRating = try container.decode(Int.self, forKey: .armorRating)
           speed = try container.decode(Int.self, forKey: .speed)
           staminaRegen = try container.decode(Int.self, forKey: .staminaRegen)
           passive = try container.decode(StoreItemPassive.self, forKey: .passive)
           storeCost = try container.decodeIfPresent(Int.self, forKey: .storeCost)
           id = UUID()
       }
    
}

struct StoreItemPassive: Codable {
    var name: String
    var description: String
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct Enemy: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    var description: String
    var recommendedStratagems: [Stratagem]
    var imageUrl: String

    enum CodingKeys: String, CodingKey {
        case name, description, recommendedStratagems, imageUrl
    }
    
    // custom decoder to map string names to stratagems
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        
        // decode array of stratagem names
        let stratagemNames = try container.decode([String].self, forKey: .recommendedStratagems)
        
        // map names to global stratagems
        self.recommendedStratagems = stratagemNames.compactMap { name in
            globalStratagems.first { $0.name == name }
        }
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
}

var globalStratagems: [Stratagem] = [
    Stratagem(name: "Machine Gun", sequence: [.down, .left, .down, .up, .right], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199811/machine-gun_mayvjv.mp4"),
    Stratagem(name: "Airburst Rocket Launcher", sequence: [.down, .up, .up, .left, .right], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199781/airburst-rocket-launcher_zba4cf.mp4"),
    Stratagem(name: "Anti-Materiel Rifle", sequence: [.down, .left, .right, .up, .down], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199781/anti-materiel-rifle_qxi0dx.mp4"),
    Stratagem(name: "Stalwart", sequence: [.down, .left, .down, .up, .up, .left], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199838/stalwart_haa0p9.mp4"),
    Stratagem(name: "Expendable Anti-Tank", sequence: [.down, .down, .left, .up, .right], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199796/expendable-anti-tank_vyziwa.mp4"),
    Stratagem(name: "Recoilless Rifle", sequence: [.down, .left, .right, .right, .left], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199838/recoilless-rifle_qolpe1.mp4"),
    Stratagem(name: "Flamethrower", sequence: [.down, .left, .up, .down, .up], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199797/flamethrower_pwedpe.mp4"),
    Stratagem(name: "Autocannon", sequence: [.down, .left, .down, .up, .up, .right], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199782/autocannon_ircqzc.mp4"),
    Stratagem(name: "Railgun", sequence: [.down, .right, .down, .up, .left, .right], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199829/railgun_s3vkpc.mp4"),
    Stratagem(name: "Spear", sequence: [.down, .down, .up, .down, .down], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199837/spear_rsyzpf.mp4"),
    Stratagem(name: "Orbital Gatling Barrage", sequence: [.right, .down, .left, .up, .up], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199819/orbital-gatling-barrage_vnvvkn.mp4"),
    Stratagem(name: "Orbital Airburst Strike", sequence: [.right, .right, .right], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199819/orbital-airburst-strike_hqynoz.mp4"),
    Stratagem(name: "Orbital 120MM HE Barrage", sequence: [.right, .right, .down, .left, .right, .down], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199811/orbital-120mm-he-barrage_psualf.mp4"),
    Stratagem(name: "Orbital 380MM HE Barrage", sequence: [.right, .down, .up, .up, .left, .down, .down], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199811/orbital-380mm-he-barrage_fiftgw.mp4"),
    Stratagem(name: "Orbital Walking Barrage", sequence: [.right, .down, .right, .down, .right, .down], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199830/orbital-walking-barrage_tbduw8.mp4"),
    Stratagem(name: "Orbital Laser", sequence: [.right, .down, .up, .right, .down], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199819/orbital-laser_lcjewz.mp4"),
    Stratagem(name: "Orbital Railcannon Strike", sequence: [.right, .up, .down, .down, .right], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199830/orbital-railcannon-strike_nxeirs.mp4"),
    Stratagem(name: "Eagle Strafing Run", sequence: [.up, .right, .right], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199791/eagle-strafing-run_bluamq.mp4"),
    Stratagem(name: "Eagle Airstrike", sequence: [.up, .right, .down, .right], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199791/eagle-airstrike_t51mo5.mp4"),
    Stratagem(name: "Eagle Cluster Bomb", sequence: [.up, .right, .down, .down, .right], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199791/eagle-cluster-bomb_dotcej.mp4"),
    Stratagem(name: "Eagle Napalm Airstrike", sequence: [.up, .right, .down, .up], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199791/eagle-napalm-airstrike_m9jrjs.mp4"),
    Stratagem(name: "Jump Pack", sequence: [.down, .up, .up, .down, .up], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199804/jump-pack_h5a424.mp4"),
    Stratagem(name: "Eagle Smoke Strike", sequence: [.up, .right, .up, .down], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199791/eagle-smoke-strike_n0hnrs.mp4"),
    Stratagem(name: "Eagle 110MM Rocket Pods", sequence: [.up, .right, .up, .left], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199784/eagle-110mm-rocket-pods_ueooxq.mp4"),
    Stratagem(name: "Eagle 500KG Bomb", sequence: [.up, .right, .down, .down, .down], type: .hangar, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199791/eagle-500kg-bomb_snom6r.mp4"),
    Stratagem(name: "Orbital Precision Strike", sequence: [.right, .right, .up], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199819/orbital-precision-strike_hqa22z.mp4"),
    Stratagem(name: "Orbital Gas Strike", sequence: [.right, .right, .down, .right], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199819/orbital-gas-strike_eou2w6.mp4"),
    Stratagem(name: "Orbital EMS Strike", sequence: [.right, .right, .left, .down], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199819/orbital-ems-strike_fefzss.mp4"),
    Stratagem(name: "Orbital Smoke Strike", sequence: [.right, .right, .down, .up], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199830/orbital-smoke-strike_jffrd7.mp4"),
    Stratagem(name: "HMG Emplacement", sequence: [.down, .up, .left, .right, .right, .left], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199804/hmg-emplacement_w1u00u.mp4"),
    Stratagem(name: "Shield Generator Relay", sequence: [.down, .down, .left, .right, .left, .right], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199837/shield-generator-relay_uqp8ky.mp4"),
    Stratagem(name: "Tesla Tower", sequence: [.down, .up, .right, .up, .left, .right], type: .bridge, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199970/tesla-tower_nezgdq.mp4"),
    Stratagem(name: "Anti-Personnel Minefield", sequence: [.down, .left, .up, .right], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199781/anti-personnel-minefield_vnwjiz.mp4"),
    Stratagem(name: "Supply Pack", sequence: [.down, .left, .down, .up, .up, .down], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199839/supply-pack_wdm33j.mp4"),
    Stratagem(name: "Grenade Launcher", sequence: [.down, .left, .up, .left, .down], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199797/grenade-launcher_xz48sg.mp4"),
    Stratagem(name: "Laser Cannon", sequence: [.down, .left, .down, .up, .left], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199811/laser-cannon_hdo80e.mp4"),
    Stratagem(name: "Incendiary Mines", sequence: [.down, .left, .left, .down], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199804/incendiary-mines_m1vwjw.mp4"),
    Stratagem(name: "Guard Dog Rover", sequence: [.down, .up, .left, .up, .right, .right], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199804/guard-dog-rover_qadjo4.mp4"),
    Stratagem(name: "Ballistic Shield Backpack", sequence: [.down, .left, .down, .down, .up, .left], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199784/ballistic-shield-backpack_tp6mc1.mp4"),
    Stratagem(name: "Arc Thrower", sequence: [.down, .right, .down, .up, .left, .left], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199781/arc-thrower_bhmsyb.mp4"),
    Stratagem(name: "Shield Generator Pack", sequence: [.down, .up, .left, .right, .left, .right], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199837/shield-generator-pack_fz0mp8.mp4"),
    Stratagem(name: "Machine Gun Sentry", sequence: [.down, .up, .right, .right, .up], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199811/machine-gun-sentry_ude1jr.mp4"),
    Stratagem(name: "Gatling Sentry", sequence: [.down, .up, .right, .left], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199797/gatling-sentry_j1dksf.mp4"),
    Stratagem(name: "Mortar Sentry", sequence: [.down, .up, .right, .right, .down], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199811/mortar-sentry_j8p4xp.mp4"),
    Stratagem(name: "Guard Dog", sequence: [.down, .up, .left, .up, .right, .down], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199804/guard-dog_nxqhnj.mp4"),
    Stratagem(name: "Autocannon Sentry", sequence: [.down, .up, .right, .up, .left, .up], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199782/autocannon-sentry_mqci5o.mp4"),
    Stratagem(name: "Rocket Sentry", sequence: [.down, .up, .right, .right, .left], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199837/rocket-sentry_dwzvlz.mp4"),
    Stratagem(name: "EMS Mortar Sentry", sequence: [.down, .up, .right, .down, .right], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199797/ems-mortar-sentry_ipu2rr.mp4"),
    Stratagem(name: "Reinforce", sequence: [.up, .down, .right, .left, .up], type: .mission),
    Stratagem(name: "SOS Beacon", sequence: [.up, .down, .right, .up], type: .mission),
    Stratagem(name: "Super Earth Flag", sequence: [.down, .up, .down, .up], type: .mission),
    Stratagem(name: "Upload Data", sequence: [.left, .right, .up, .up, .up], type: .mission),
    Stratagem(name: "Hellbomb", sequence: [.down, .up, .left, .down, .up, .right, .down, .up], type: .mission),
    Stratagem(name: "Patriot Exosuit", sequence: [.left, .down, .right, .up, .left, .down, .down], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199830/patriot-exosuit_khycyw.mp4"),
    Stratagem(name: "Emancipator Exosuit", sequence: [.left, .down, .right, .up, .left, .down, .up], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199796/emancipator-exosuit_t6acx6.mp4"),
    Stratagem(name: "Quasar Cannon", sequence: [.down, .down, .up, .left, .right], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199830/quasar-cannon_sdgkmx.mp4"),
    Stratagem(name: "Heavy Machine Gun", sequence: [.down, .left, .up, .down, .down], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1721199804/heavy-machine-gun_mqll1v.mp4"),
    Stratagem(name: "Resupply", sequence: [.down, .down, .up, .right], type: .mission),
    Stratagem(name: "Prospecting Drill", sequence: [.down, .down, .left, .right, .down, .down], type: .mission),
    Stratagem(name: "Seismic Probe", sequence: [.up, .up, .left, .right, .down, .down], type: .mission),
    Stratagem(name: "SEAF Artillery", sequence: [.right, .up, .up, .down], type: .mission),
    Stratagem(name: "Orbital Illumination Flare", sequence: [.right, .right, .left, .left], type: .mission),
    Stratagem(name: "Guard Dog Breath", sequence: [.down, .up, .left, .right, .up], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822317/guard-dog-dog-breath-2.mp4"),
    Stratagem(name: "Tectonic Drill", sequence: [.up, .down, .up, .down, .up, .down], type: .mission),
    Stratagem(name: "Dark Fluid Vessel", sequence: [.up, .left, .right, .down, .up, .up], type: .mission),
    Stratagem(name: "Hive Breaker Drill", sequence: [.left, .up, .down, .right, .down, .down], type: .mission),
    Stratagem(name: "Orbital Napalm Barrage", sequence: [.right, .right, .down, .left, .right, .up], type: .orbital, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822296/orbital-napalm-barrage-2.mp4"),
    Stratagem(name: "Directional Shield", sequence: [.down, .up, .left, .right, .up, .up], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822347/directional-shield-2.mp4"),
    Stratagem(name: "Anti-Tank Emplacement", sequence: [.down, .up, .left, .right, .right, .right], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822398/anti-tank-emplacement-2.mp4"),
    Stratagem(name: "Flame Sentry", sequence: [.down, .up, .right, .down, .up, .up], type: .workshop, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822364/flame-sentry-2.mp4"),
    Stratagem(name: "Sterilizer", sequence: [.down, .left, .up, .down, .left], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822306/steriliser-2.mp4"),
    Stratagem(name: "Commando", sequence: [.down, .left, .up, .down, .right], type: .admin, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1734822285/commando-2.mp4"),
    Stratagem(name: "W.A.S.P. Launcher", sequence: [.down, .down, .up, .down, .right], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1735089553/wasp-launcher-2.mp4"),
    Stratagem(name: "Fast Recon Vehicle", sequence: [.left, .down, .right, .down, .right, .down, .up], type: .hangar),
    Stratagem(name: "Anti-Tank Mines", sequence: [.down, .left, .up, .up], type: .engineering, videoUrl: "https://res.cloudinary.com/dxtkcvynb/video/upload/v1735089844/anti-tank-mines-2.mp4"),
    Stratagem(name: "Gas Mines", sequence: [.down, .left, .left, .right], type: .engineering)
]

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
