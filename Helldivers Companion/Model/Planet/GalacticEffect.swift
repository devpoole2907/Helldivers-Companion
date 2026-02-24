//
//  GalacticEffect.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct GalacticEffect: Codable, Identifiable {
    var id: Int { galacticEffectId }
    let index: Int
    let galacticEffectId: Int
    
    var imageName: String? {
        switch galacticEffectId {
        case 1186, 1187, 1188, 1193:
            return "gloom" // gloom
        case 1198:
            return "hammer" // Deep Mantle Forge Complex
        case 1236:
            return "surveillancecenter" // Center for Civilian Surveillance and Safety
        case 1232:
            return "hammer" // Factory Hub
        case 1197:
            return "sciencecenter" // Xenoentomology Center
        case 1228, 1229, 1230:
            return "blackhole" // MERIDIAN BLACK HOLE
        case 1234:
            return "sciencecenter" // center of science
        case 1239:
            return "automaton" // jet brigade factory
        case 1240:
            return "alert"
        case 1241, 1242, 1252:
            return "blackhole" // fractured, moving singularity
        case 1245:
            return "predator"
        case 1269:
            return "illuminatewhite" // the great host
        default:
            return nil // effects we wont be displaying
        }
    }
    
    var showImageOnMap: Bool {
        switch galacticEffectId {
        case 1186, 1187, 1188, 1193:
            return false
        default:
            return true
        }
    }
    
    // only ones we know are:
    //Deep Mantle Forge Complex, Center for Civilian Surveillance and Safety, Factory Hub, Xenoentomology Center, MERIDIAN BLACK HOLE
    
    // we will not display anything other than these in the app for the time being
    
    // for additional info fetched from json:
    var name: String?
    var description: String?
}
