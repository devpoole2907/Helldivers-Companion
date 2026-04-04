//
//  MockAPIService.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/03/2026.
//

#if DEBUG
import Foundation

/// A mock implementation of WarAPIServiceProtocol that returns static data immediately.
/// Use this in Xcode Previews and unit tests — no network calls are made.
actor MockAPIService: WarAPIServiceProtocol {

    // MARK: - Config

    func fetchConfig() async -> RemoteConfigDetails? {
        RemoteConfigDetails(
            alert: "",
            prominentAlert: nil,
            season: "801",
            showIlluminate: false,
            apiAddress: "https://helldivers-2.fly.dev/api",
            startedAt: "2024-02-10T07:20:30.089979Z",
            meridiaEvent: false
        )
    }

    // MARK: - Status

    func fetchStatus(season: String) async -> StatusResponse? {
        StatusResponse(time: 9_876_543, planetActiveEffects: [], globalResources: [])
    }

    // MARK: - Space Stations

    func fetchSpaceStations(apiAddress: String, language: String?) async -> [SpaceStation] {
        []
    }

    func fetchSpaceStationDetails(id32: Int64, season: String) async -> SpaceStationDetails? {
        nil
    }

    // MARK: - Campaigns

    func fetchCampaigns(url: String?, apiAddress: String, language: String?) async -> ([UpdatedCampaign], [UpdatedCampaign]) {
        ([], [])
    }

    // MARK: - Orders

    func fetchPersonalOrder() async -> PersonalOrder? {
        nil
    }

    func fetchMajorOrder(season: String, planets: [UpdatedPlanet], language: String?) async -> ([UpdatedPlanet], [MajorOrder]) {
        ([], [])
    }

    // MARK: - Planets

    func fetchPlanets(url: String?, apiAddress: String, language: String?, status: StatusResponse?) async -> ([UpdatedPlanet], [String], [String: [UpdatedPlanet]]) {
        let planets: [UpdatedPlanet] = [.mockTerminid, .mockAutomaton]
        let grouped = Dictionary(grouping: planets, by: { $0.sector })
        let sorted = grouped.keys.sorted()
        return (planets, sorted, grouped)
    }

    // MARK: - Galaxy Stats

    func fetchGalaxyStats() async -> GalaxyStatsResponseData? {
        nil
    }

    // MARK: - Cached Planet Data

    func fetchCachedPlanetData() async -> [String: [UpdatedPlanetDataPoint]] {
        [:]
    }
}
#endif
