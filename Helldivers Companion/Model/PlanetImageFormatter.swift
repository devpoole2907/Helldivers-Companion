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

            switch planet?.name.lowercased() {
                
            case "meridia":
                return "Meridia"
                
            case "super earth":
                return "Super Earth"
            
            case "tien kwan": // backup in case tien kwan biome name is changed in api
                return "Tien Kwan"
                
            default:
                switch planet?.biome.name.lowercased() {
                case "swamp":
                return "Troost"
            case "crimsonmoor":
                return "Ingmar"
            case "desolate":
                return "Hellmire"
            case "winter":
                return "Vandalon IV"
            case "jungle":
                return "Mantes"
            case "rainforest":
                return "Veld"
            case "moon":
                return "Fenrir III"
            case "icemoss":
                return "Estanu"
            case "tundra":
                return "Omicron"
            case "ethereal":
                return "Turing"
            case "canyon":
                return "Fori Prime"
            case "highlands":
                return "Oshaune"
                case "desert":
                return "Ustotu"
            case "mesa":
                return "Durgen"
                case "toxic":
                return "Merak"
            case "icemoss special":
                return "Tien Kwan"
  
                default:
                    return "MissingPlanetImage"
            }
            
       
    }
    
}
    }
