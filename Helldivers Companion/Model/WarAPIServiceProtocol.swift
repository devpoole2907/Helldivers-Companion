//
//  WarAPIServiceProtocol.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/03/2026.
//

import Foundation

/// Protocol describing all public data-fetch operations performed by the war API service.
/// Conforming types may be the real network actor or a DEBUG-only mock.
protocol WarAPIServiceProtocol: Actor {

    // MARK: - Config
    func fetchConfig() async -> RemoteConfigDetails?

    // MARK: - War Time
    func fetchWarTime(season: String) async -> Int64?

    // MARK: - Status
    func fetchStatus(season: String) async -> StatusResponse?

    // MARK: - Space Stations
    func fetchSpaceStations(apiAddress: String, language: String?) async -> [SpaceStation]
    func fetchSpaceStationDetails(id32: Int64, season: String) async -> SpaceStationDetails?

    // MARK: - Campaigns
    func fetchCampaigns(url: String?, apiAddress: String, language: String?) async -> ([UpdatedCampaign], [UpdatedCampaign])

    // MARK: - Orders
    func fetchPersonalOrder() async -> PersonalOrder?
    func fetchMajorOrder(season: String, planets: [UpdatedPlanet], language: String?) async -> ([UpdatedPlanet], [MajorOrder])

    // MARK: - Planets
    func fetchPlanets(url: String?, apiAddress: String, language: String?, status: StatusResponse?) async -> ([UpdatedPlanet], [String], [String: [UpdatedPlanet]])

    // MARK: - Galaxy Stats
    func fetchGalaxyStats() async -> GalaxyStatsResponseData?

    // MARK: - Cached Planet Data
    func fetchCachedPlanetData() async -> [String: [UpdatedPlanetDataPoint]]
}
