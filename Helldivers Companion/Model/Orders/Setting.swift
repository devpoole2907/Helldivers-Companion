//
//  Setting.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct Setting: Codable {
    let type: Int
    let overrideTitle: String
    let overrideBrief: String
    let taskDescription: String
    let tasks: [Task]
    let rewards: [Reward]
    let reward: Reward?
    let flags: Int
    
    /// Unified reward access — returns the rewards array, or falls back to the singular reward.
    var allRewards: [Reward] {
        if rewards.isEmpty {
            return reward.map { [$0] } ?? []
        } else {
            return rewards
        }
    }

    struct Task: Codable, Equatable, Hashable {
        let type: Int
        let values: [Int64]
        let valueTypes: [Int]
        
        // for planet location or sector
        private var locationName: AttributedString? {
            let locationType = TaskLocationType(rawValue: value(for: .locationType))
            let locationIndex = value(for: .planetIndex)
            
            if locationType == .sector, let sector = sectorLookup[locationIndex] {
                var text = AttributedString("in the \(sector.name) sector")
                text.foregroundColor = .yellow
                return text
            } else if locationIndex > 0, let planet = planetPositionLookup[locationIndex] {
                // planet is the default — either explicit .planet or absent (nil)
                var text = AttributedString("on \(planet.name)")
                text.foregroundColor = .yellow
                return text
            }
            
            return nil
        }
        
        var description: AttributedString {
            var text = AttributedString("")
            
            let raceId      = value(for: .raceId)
            let planetIndex = value(for: .planetIndex)
            let goal        = value(for: .goal)
            let unitId      = value(for: .unitId)
            let itemId      = value(for: .itemId)
                    
            switch taskType {
            case .extract:
                text += AttributedString("Extract ")
                
                if goal > 0 {
                    var goalText = AttributedString("\(goal)")
                    goalText.foregroundColor = .yellow
                    text += goalText + " "
                }
                
                if itemId > 0 {
                    let itemName = orderItemsDictionary[itemId] ?? "item #\(itemId)"
                    var itemText = AttributedString(itemName)
                    itemText.foregroundColor = .yellow
                    text += itemText + " "
                }
                
                if let location = locationName {
                    text += location
                }
                
            case .eradicate:
                text += AttributedString("Kill ")
                
                if goal > 0 {
                    var goalText = AttributedString("\(goal)")
                    goalText.foregroundColor = .yellow
                    text += goalText + " "
                }
                
                if unitId > 0 {
                    let name = unitNamesDictionary[unitId] ?? "unit #\(unitId)"
                    var unitText = AttributedString(name)
                    unitText.foregroundColor = .yellow
                    text += unitText
                } else if raceId > 0 {
                    let faction = Faction(id: raceId)
                    var factionText = AttributedString(faction.displayName)
                    factionText.foregroundColor = faction.color
                    text += factionText
                } else {
                    text += AttributedString("enemies")
                }
                
                if itemId > 0 {
                    let itemName = orderItemsDictionary[itemId] ?? "item #\(itemId)"
                    var itemText = AttributedString(" using the \(itemName)")
                    itemText.foregroundColor = .yellow
                    text += itemText
                }
                
                if planetIndex > 0, let planetPos = planetPositionLookup[planetIndex] {
                    var planetText = AttributedString(" on \(planetPos.name)")
                    planetText.foregroundColor = .yellow
                    text += planetText
                }
                
            case .secondaryObjective:
                text += AttributedString("Complete ")
                
                if goal > 0 {
                    var goalText = AttributedString("\(goal)")
                    goalText.foregroundColor = .yellow
                    text += goalText + " "
                }
                
                text += AttributedString("secondary objectives")
                
            case .missionExtract:
                text += AttributedString("Extract from a successful mission ")
                
                if goal > 0 {
                    var goalText = AttributedString("\(goal) time" + (goal > 1 ? "s" : ""))
                    goalText.foregroundColor = .yellow
                    text += goalText
                }
                
                if raceId > 0 {
                    let faction = Faction(id: raceId)
                    var factionText = AttributedString(" against \(faction.displayName)")
                    factionText.foregroundColor = faction.color
                    text += factionText
                }
                
                if planetIndex > 0, let planetPos = planetPositionLookup[planetIndex] {
                    var planetText = AttributedString(" on \(planetPos.name)")
                    planetText.foregroundColor = .yellow
                    text += planetText
                }
                
            case .defense:
                text += AttributedString("Defend ")

                if planetIndex > 0, let planetPos = planetPositionLookup[planetIndex] {
                    var planetText = AttributedString(planetPos.name)
                    planetText.foregroundColor = .yellow
                    text += planetText + " "
                }
                
                text += AttributedString("against ")
                
                if goal > 0 {
                    var goalText = AttributedString("\(goal) attack" + (goal > 1 ? "s" : ""))
                    goalText.foregroundColor = .yellow
                    text += goalText + " from "
                } else {
                    text += AttributedString("an attack from ")
                }
                
                if raceId > 0 {
                    let faction = Faction(id: raceId)
                    var factionText = AttributedString(faction.displayName)
                    factionText.foregroundColor = faction.color
                    text += factionText
                } else {
                    text += AttributedString("an unknown enemy")
                }
                
            case .none:
                text += AttributedString("Task type \(type) not handled! Contact the dev.")
                
            default:
                text += AttributedString("Task type \(type) not handled! Contact the dev.")
            }
            return text
        }
            
            
        }

    struct Reward: Codable {
        let type: Int
        let id32: Int
        let amount: Int
    }
}
