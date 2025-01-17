//
//  PlanetImageFormatter.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import Foundation

class PlanetImageFormatter {
    // change to not optional eventually
    static func formattedPlanetImageName(for planet: UpdatedPlanet?) -> String {
        let biomeName = planet?.biome.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            print("Biome name received: \(biomeName ?? "nil")")
        print("Biome name received: \(biomeName ?? "nil")")
        
        switch planet?.name.lowercased() {
            
        case "meridia":
            return "meridiablackhole"
            
        case "super earth":
            return "Super Earth"
            
        case "tien kwan": // backup in case tien kwan biome name is changed in api
            return "Tien Kwan"
            
        default:
            switch planet?.biome.name.lowercased() {
            case "swamp":
                return "x45"
            case "foggy swamp", "haunted swamp":
                return "Haunted"
            case "wasteland", "deadlands":
                return "Troost"
            case "crimsonmoor", "ionic crimson":
                return "Ingmar"
            case "desolate", "scorched moor":
                return "Hellmire"
            case "winter", "icy glaciers":
                return "Vandalon IV"
            case "jungle", "volcanic jungle":
                return "Mantes"
            case "rainforest", "ionic jungle":
                return "Veld"
            case "moon":
                return "Fenrir III"
            case "icemoss", "boneyard":
                return "Estanu"
            case "tundra":
                return "Omicron"
            case "ethereal", "ethereal jungle":
                return "Turing"
            case "canyon", "rocky canyons":
                return "Fori Prime"
            case "highlands", "plains":
                return "Oshaune"
            case "desert", "desert cliffs":
                return "Ustotu"
            case "mesa", "desert dunes":
                return "Durgen"
            case "toxic", "acidic badlands":
                return "Merak"
            case "basic swamp":
                return "gacrux"
            case "icemoss special":
                return "Tien Kwan"
                
            default:
                return "MissingPlanetImage"
            }
            
            
        }
        
    }
}
