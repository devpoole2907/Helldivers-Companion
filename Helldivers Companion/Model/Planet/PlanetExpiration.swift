//
//  PlanetExpiration.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct PlanetExpiration: Decodable {
    let planetIndex: Int
    let name: String
    let expireDateTime: Double?
}
