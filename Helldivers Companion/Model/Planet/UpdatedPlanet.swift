//
//  UpdatedPlanet.swift
//  Helldivers Companion
//
//  Created by James Poole on 23/02/2026.
//

import SwiftUI


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
    var regions: [Region]?
    
    // galactic effects
    var galacticEffects: [GalacticEffect]?
    
    // return the event or the liberation percent
    var planetProgressPercent: Double {
        event?.percentage ?? percentage
    }
    
    // computed prop for liberation
    var percentage: Double {
        maxHealth > 0 ? (1 - (Double(health) / Double(maxHealth))) * 100 : 0
    }
    // if its associated with major order, put its task progress here
    var taskProgress: Int64?
    
    var faction: Faction {
        if let eventFaction = event?.faction, !eventFaction.isEmpty {
            return Faction(ownerString: eventFaction)
        }
        return Faction(ownerString: currentOwner)
    }
    
    var ownerFaction: Faction {
        return Faction(ownerString: currentOwner) // should this be initial owner?
    }
    
    // compatibility wrappers:
    var factionColor: Color {
        return faction.color
    }
    
    
}
