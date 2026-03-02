//
//  WidgetDataProvider.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/03/2026.
//

import Foundation

// Cache URLs for GitHub-backed data (avoids hammering the live API from widgets)
private let campaignsURL = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentCampaigns.json"
private let planetsURL   = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentPlanets.json"

/// Shared fetch logic used by all widget TimelineProviders.
/// Each provider instantiates one of these and calls the appropriate method,
/// keeping getTimeline() bodies to ~5 lines.
struct WidgetDataProvider {

    let apiService: WarAPIService

    init(apiService: WarAPIService = WarAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Planet widget

    struct PlanetData {
        let campaigns: [UpdatedCampaign]
        let defenseCampaigns: [UpdatedCampaign]
        let spaceStations: [SpaceStation]
        let fleetStrengthProgress: Double
        let fleetStrengthResource: GlobalResource?
    }

    func fetchPlanetData() async -> PlanetData? {
        guard let config = await apiService.fetchConfig() else { return nil }

        let status = await apiService.fetchStatus(season: config.season)
        let fleetResource = status?.globalResources.resource(for: .fleetStrength)
        let fleetProgress: Double = fleetResource.map { r in
            r.maxValue > 0 ? Double(r.currentValue) / Double(r.maxValue) : 0
        } ?? 0

        async let campaignsResult     = apiService.fetchCampaigns(url: campaignsURL, apiAddress: config.apiAddress, language: nil)
        async let spaceStationsResult = apiService.fetchSpaceStations(apiAddress: config.apiAddress, language: nil)

        let (campaigns, defenseCampaigns) = await campaignsResult
        let spaceStations = await spaceStationsResult

        return PlanetData(
            campaigns: campaigns,
            defenseCampaigns: defenseCampaigns,
            spaceStations: spaceStations,
            fleetStrengthProgress: fleetProgress,
            fleetStrengthResource: fleetResource
        )
    }

    // MARK: - Galaxy map widget

    struct MapData {
        let planets: [UpdatedPlanet]
        let campaigns: [UpdatedCampaign]
        let defenseCampaigns: [UpdatedCampaign]
        let spaceStations: [SpaceStation]
        let taskPlanets: [UpdatedPlanet]
    }

    func fetchMapData() async -> MapData? {
        guard let config = await apiService.fetchConfig() else { return nil }

        async let planetsResult       = apiService.fetchPlanets(url: planetsURL, apiAddress: config.apiAddress, language: nil)
        async let campaignsResult     = apiService.fetchCampaigns(url: campaignsURL, apiAddress: config.apiAddress, language: nil)
        async let spaceStationsResult = apiService.fetchSpaceStations(apiAddress: config.apiAddress, language: nil)

        let (planets, _, _) = await planetsResult
        let (campaigns, defenseCampaigns) = await campaignsResult
        let spaceStations = await spaceStationsResult

        let (taskPlanets, _) = await apiService.fetchMajorOrder(season: config.season, planets: planets, language: nil)

        return MapData(planets: planets, campaigns: campaigns, defenseCampaigns: defenseCampaigns, spaceStations: spaceStations, taskPlanets: taskPlanets)
    }

    // MARK: - Major order widget

    struct OrderData {
        let planets: [UpdatedPlanet]
        let taskPlanets: [UpdatedPlanet]
        let majorOrder: MajorOrder?
    }

    func fetchOrderData() async -> OrderData? {
        guard let config = await apiService.fetchConfig() else { return nil }

        let (planets, _, _) = await apiService.fetchPlanets(url: planetsURL, apiAddress: config.apiAddress, language: nil)
        let (taskPlanets, majorOrders) = await apiService.fetchMajorOrder(season: config.season, planets: planets, language: nil)

        return OrderData(planets: planets, taskPlanets: taskPlanets, majorOrder: majorOrders.first)
    }

    // MARK: - Player count widget

    func fetchTotalPlayerCount() async -> Int64? {
        guard let config = await apiService.fetchConfig() else { return nil }
        let (planets, _, _) = await apiService.fetchPlanets(url: planetsURL, apiAddress: config.apiAddress, language: nil)
        return planets.reduce(0) { $0 + $1.statistics.playerCount }
    }
}
