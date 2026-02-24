//
//  Region.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


// new regions implementation 10/2/26

struct Region: Codable {
    let id: Int
    let hash: Int64
    let name: String?
    let description: String?
    let health: Int?
    let maxHealth: Int?
    let size: String?
    let regenPerSecond: Double?
    let availabilityFactor: Double?
    let isAvailable: Bool
    let players: Int
}
