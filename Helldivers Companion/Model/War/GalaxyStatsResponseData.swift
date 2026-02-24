//
//  GalaxyStatsResponseData.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct GalaxyStatsResponseData: Decodable {
    let galaxyStats: GalaxyStats
    let planetsStats: [PlanetStats]
}
