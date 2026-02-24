//
//  UpdatedPlanetStatistics.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


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
