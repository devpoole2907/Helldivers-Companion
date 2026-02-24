//
//  GalaxyStats.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


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
