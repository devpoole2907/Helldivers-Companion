//
//  PlanetsDataModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 17/07/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PlanetsDataModel: ObservableObject {
    
    static let shared = PlanetsDataModel()
    
    // for during loading
    @Published var isLoading: Bool = true
    
    @Published var showPlayerCount: Bool = false
    
    // pop map to root from other views
    let popMapToRoot = PassthroughSubject<Void, Never>()
    
    // pop to warbonds list
    let popToWarBonds = PassthroughSubject<Void, Never>()
    
    @Published var updatedPlanets: [UpdatedPlanet] = []
    @Published var updatedDefenseCampaigns: [UpdatedCampaign] = []
    @Published var updatedCampaigns: [UpdatedCampaign] = []
    @Published var updatedSortedSectors: [String] = []
    @Published var updatedGroupedBySectorPlanets: [String: [UpdatedPlanet]] =
    [:]
    @Published var updatedTaskPlanets: [UpdatedPlanet] = []
    @Published var planetHistory: [String: [UpdatedPlanetDataPoint]] = [:]
    
    @Published var spaceStations: [SpaceStation] = []
    @Published var firstSpaceStationDetails: SpaceStationDetails?
    @Published var warTime: Int64?
    @Published var nextFetchTime: Date?  // for the ui to show count down if a fetch failed due to rate limiting
    @Published var hasSetSelectedPlanet: Bool = false  // to stop setting the selected planet to the first in campaigns every fetch after the first
    
    @Published var currentTab: Tab = .home
    
    // FOR DEBUGGING
    @Published var lastError: String?
    
    @Published var lastCampaignsError: String?
    
    var dashPatterns: [UUID: [CGFloat]] = [:]
    
    @Published var currentSeason: String = ""
    @Published var majorOrders: [MajorOrder] = []
    @Published var personalOrder: PersonalOrder? = nil
    @Published var galaxyStats: GalaxyStats? = nil
    @Published var lastUpdatedDate: Date = Date()
    
    @Published var showIlluminateUI: Bool = false
    
    @Published var redactedShakeTimes = 0  // for redacting illuminate info animation
    
    @Published var selectedPlanet: UpdatedPlanet? = nil  // for map view selection
    
    @Published var status: StatusResponse? = nil // for dark energy tracking etc
    
    @AppStorage("viewCount") var viewCount = 0
    
    @AppStorage("enableLocalization") var enableLocalization = true
    @AppStorage("darkMode") var darkMode = false
    
    private var apiToken: String? = ProcessInfo.processInfo.environment[
        "GITHUB_API_KEY"]
    
    @Published var configData: RemoteConfigDetails = RemoteConfigDetails(
        alert: "", prominentAlert: nil, season: "801", showIlluminate: false,
        apiAddress: "", startedAt: "2024-02-10T07:20:30.089979Z", meridiaEvent: false)
    
    @Published var showInfo = false
    @Published var showOrders = false
    
    //var apiAddress = "http://127.0.0.1:4000/api"
    var apiAddress = "https://helldivers-2.fly.dev/api"
    
    private var timer: Timer?
    private var cacheTimer: Timer?
    
    let netManager = NetworkManager.shared
    let apiService = WarAPIService()
    
    var totalPlayerCount: Int64 {
        updatedPlanets.reduce(0) { $0 + $1.statistics.playerCount }
    }
    
    var formattedPlayerCount: String {
        formatNumber(totalPlayerCount)
    }
    
    var fleetStrengthResource: GlobalResource? {
        guard let resources = status?.globalResources else { return nil }
        return resources.first { $0.id32 == 175685818 }
    }
    
    var fleetStrengthProgress: Double {
        guard let resource = fleetStrengthResource else { return 0 }
        return Double(resource.currentValue) / Double(resource.maxValue)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func stopUpdating(completion: @escaping () -> Void) {
        timer?.invalidate()
        timer = nil
        cacheTimer?.invalidate()
        cacheTimer = nil
        completion()
    }
    
    /// Single refresh method that fetches all data with maximum parallelism,
    /// then applies all results in one animated UI update.
    /// - Parameter isInitialLoad: When true, also fetches galaxyStats + cachedPlanetData,
    ///   sets `isLoading = false`, and sets the default `selectedPlanet`.
    func refreshAll(isInitialLoad: Bool = false) async {
        
        let language = enableLocalization ? apiSupportedLanguage : nil
        
        // 1. Config must come first — it gates everything else
        guard let config = await apiService.fetchConfig() else {
            print("config failed to load")
            return
        }
        
        // 2. Fire independent fetches in parallel
        async let warTimeResult = apiService.fetchWarTime(season: config.season)
        async let statusResult = apiService.fetchStatus(season: config.season)
        async let campaignsResult = apiService.fetchCampaigns(url: nil, apiAddress: config.apiAddress, language: language)
        async let spaceStationsResult = apiService.fetchSpaceStations(apiAddress: config.apiAddress, language: language)
        async let personalOrderResult = apiService.fetchPersonalOrder()
        
        // galaxyStats only on initial load (cache timer handles subsequent fetches)
        async let galaxyStatsResult = isInitialLoad ? apiService.fetchGalaxyStats() : nil
        
        // 3. Await status, then fetch planets (needs status for galactic effects merge)
        let status = await statusResult
        let (planets, sortedSectors, groupedBySector) = await apiService.fetchPlanets(url: nil, apiAddress: config.apiAddress, language: language, status: status)
        
        // 4. Await planets, then fetch major order (needs planets for task matching)
        let (taskPlanets, majorOrders) = await apiService.fetchMajorOrder(season: config.season, planets: planets, language: language)
        
        // 5. Await space stations, then fetch details for first station
        let spaceStations = await spaceStationsResult
        let firstStationID = spaceStations.first?.id32 ?? 749875195
        let firstStationDetails = await apiService.fetchSpaceStationDetails(id32: firstStationID, season: config.season)
        
        // 6. Await remaining parallel results
        let warTime = await warTimeResult
        let (campaigns, defenseCampaigns) = await campaignsResult
        let personalOrder = await personalOrderResult
        let galaxyStats = await galaxyStatsResult
        
        // cachedPlanetData only on initial load
        let cachedData: [String: [UpdatedPlanetDataPoint]] = isInitialLoad ? await apiService.fetchCachedPlanetData() : [:]
        
        // 7. Single animated UI update
        withAnimation(.bouncy) {
            self.configData = config
            self.showIlluminateUI = config.showIlluminate
            self.lastUpdatedDate = Date()
            
            // Only overwrite if the fetch returned data — keep previous value on failure
            if let warTime { self.warTime = warTime }
            if let status { self.status = status }
            if !campaigns.isEmpty { self.updatedCampaigns = campaigns }
            if !defenseCampaigns.isEmpty || !campaigns.isEmpty { self.updatedDefenseCampaigns = defenseCampaigns }
            if !planets.isEmpty {
                self.updatedPlanets = planets
                self.updatedSortedSectors = sortedSectors
                self.updatedGroupedBySectorPlanets = groupedBySector
            }
            if !spaceStations.isEmpty { self.spaceStations = spaceStations }
            if !taskPlanets.isEmpty || !majorOrders.isEmpty {
                self.updatedTaskPlanets = taskPlanets
                self.majorOrders = majorOrders
            }
            if let personalOrder { self.personalOrder = personalOrder }
            if let firstStationDetails { self.firstSpaceStationDetails = firstStationDetails }
            
            if isInitialLoad {
                if let stats = galaxyStats?.galaxyStats { self.galaxyStats = stats }
                if !cachedData.isEmpty { self.planetHistory = cachedData }
                
                if !self.hasSetSelectedPlanet {
                    self.selectedPlanet = campaigns.first?.planet
                    self.hasSetSelectedPlanet = true
                }
                
                withAnimation {
                    self.isLoading = false
                }
            }
        }
    }
    
    func startUpdating() {
        Task {
            await refreshAll(isInitialLoad: true)
        }
        
        setupTimer()
        setupCacheTimer()
    }
    
    func setupTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.refreshAll()
            }
        }
    }
    // for slower fetches e.g historical data
    func setupCacheTimer() {
        
        cacheTimer?.invalidate()
        
        cacheTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true)
        { [weak self] _ in
            guard let self = self else { return }
            Task {
                
                let galaxyStats = await self.fetchGalaxyStats()
                let cachedData = await self.fetchCachedPlanetData()
                
                await MainActor.run {
                    self.objectWillChange.send()
                    withAnimation(.bouncy) {
                        self.galaxyStats = galaxyStats?.galaxyStats
                        
                        self.planetHistory = cachedData
                        self.lastUpdatedDate = Date()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func fetchCachedPlanetData() async -> [String: [UpdatedPlanetDataPoint]] {
        await apiService.fetchCachedPlanetData()
    }
    
    func fetchWarTime(with config: RemoteConfigDetails? = nil) async -> Int64? {
        await apiService.fetchWarTime(season: config?.season ?? "801")
    }
    
    func fetchStatus(with config: RemoteConfigDetails? = nil) async -> StatusResponse? {
        await apiService.fetchStatus(season: config?.season ?? "801")
    }
    
    func fetchSpaceStationDetails(for id32: Int64? = nil, with config: RemoteConfigDetails? = nil) async -> SpaceStationDetails? {
        await apiService.fetchSpaceStationDetails(id32: id32 ?? 749875195, season: config?.season ?? "801")
    }
    
    func fetchSpaceStations(using url: String? = nil, for configData: RemoteConfigDetails) async -> [SpaceStation] {
        await apiService.fetchSpaceStations(apiAddress: configData.apiAddress, language: enableLocalization ? apiSupportedLanguage : nil)
    }
    
    func fetchCampaigns(
        using url: String? = nil, for configData: RemoteConfigDetails
    ) async -> ([UpdatedCampaign], [UpdatedCampaign]) {
        await apiService.fetchCampaigns(url: url, apiAddress: configData.apiAddress, language: enableLocalization ? apiSupportedLanguage : nil)
    }
    
    func fetchPersonalOrder() async -> PersonalOrder? {
        await apiService.fetchPersonalOrder()
    }
    
    func fetchMajorOrder(
        for season: String? = nil,
        with planets: [UpdatedPlanet]? = nil
    ) async -> ([UpdatedPlanet], [MajorOrder]) {
        let seasonString = season ?? configData.season
        let collectionOfPlanets = planets ?? self.updatedPlanets
        return await apiService.fetchMajorOrder(season: seasonString, planets: collectionOfPlanets, language: enableLocalization ? apiSupportedLanguage : nil)
    }
    
    func fetchConfig() async -> RemoteConfigDetails? {
        await apiService.fetchConfig()
    }
    
    struct PlanetJSON: Decodable {
        let name: String
        let sector: String
        let biome: String
        let environmentals: [String]
        let weatherEffects: [String]?
    }
    
    func fetchPlanets(
        using url: String? = nil, for configData: RemoteConfigDetails, with status: StatusResponse? = nil
    ) async -> ([UpdatedPlanet], [String], [String: [UpdatedPlanet]]) {
        await apiService.fetchPlanets(url: url, apiAddress: configData.apiAddress, language: enableLocalization ? apiSupportedLanguage : nil, status: status)
    }
    
    func fetchGalaxyStats() async -> GalaxyStatsResponseData? {
        await apiService.fetchGalaxyStats()
    }
    
    
    var playerDistribution: [PlayerDistributionItem] {
        
        var counts = [Faction: Int64]()
        for planet in updatedPlanets {
            counts[planet.faction, default: 0] += planet.statistics.playerCount
        }
        return counts.compactMap { faction, count in
            count > 0 ? PlayerDistributionItem(faction: faction.displayName, count: count, color: faction.color, imageName: faction.imageName) : nil
            
        }
    }
    
    
    // TODO: move me at some point, just dupicated here so strat rows in db can get strokes im moving quick
    func dashPattern(for stratagem: Stratagem) -> [CGFloat] {
        if let pattern = dashPatterns[stratagem.id] {
            return pattern
        } else {
            // Create a new pattern if not exists
            let newPattern = [
                CGFloat.random(in: 50...70), CGFloat.random(in: 5...20),
            ]
            dashPatterns[stratagem.id] = newPattern
            return newPattern
        }
    }
    
    func currentLiberationRate(for planetName: String) -> Double? {
        guard let dataPoints = planetHistory[planetName], dataPoints.count >= 3
        else {
            return nil
        }
        
        // get the second and third last data points, latest ones are wrong need to be fixed somethings incorrect somewhere
        let secondLastPoint = dataPoints[dataPoints.count - 3]
        let thirdLastPoint = dataPoints[dataPoints.count - 2]
        
        let timeInterval =
        thirdLastPoint.timestamp.timeIntervalSince(
            secondLastPoint.timestamp) / 3600
        if timeInterval <= 0 {
            return nil
        }
        
        let secondLastPercentage =
        self.updatedDefenseCampaigns.contains(where: {
            $0.planet == secondLastPoint.planet
        })
        ? secondLastPoint.planet?.event?.percentage
        : secondLastPoint.planet?.percentage
        let thirdLastPercentage =
        self.updatedDefenseCampaigns.contains(where: {
            $0.planet == thirdLastPoint.planet
        })
        ? thirdLastPoint.planet?.event?.percentage
        : thirdLastPoint.planet?.percentage
        
        guard let lastLiberation = thirdLastPercentage,
              let previousLiberation = secondLastPercentage
        else {
            return nil
        }
        
        let rate = (lastLiberation - previousLiberation) / timeInterval
        
        return rate
    }
    
    func averageLiberationRate(for planetName: String) -> Double? {
        guard let dataPoints = planetHistory[planetName] else {
            return nil
        }
        
        // exclude 100 because 100 will only show if a planet has become part of a recent event
        let filteredDataPoints = dataPoints.filter { dataPoint in
            let percentage =
            self.updatedDefenseCampaigns.contains(where: {
                $0.planet == dataPoint.planet
            })
            ? dataPoint.planet?.event?.percentage
            : dataPoint.planet?.percentage
            return percentage != 100.0
        }
        
        // must be at least 2 data points
        guard filteredDataPoints.count >= 2 else {
            return nil
        }
        
        var totalRate: Double = 0
        var count: Double = 0
        
        for i in 1..<filteredDataPoints.count {
            let timeInterval =
            filteredDataPoints[i].timestamp.timeIntervalSince(
                filteredDataPoints[i - 1].timestamp) / 3600
            if timeInterval > 0 {
                let currentPercentage =
                self.updatedDefenseCampaigns.contains(where: {
                    $0.planet == filteredDataPoints[i].planet
                })
                ? filteredDataPoints[i].planet?.event?.percentage
                : filteredDataPoints[i].planet?.percentage
                let previousPercentage =
                self.updatedDefenseCampaigns.contains(where: {
                    $0.planet == filteredDataPoints[i - 1].planet
                })
                ? filteredDataPoints[i - 1].planet?.event?.percentage
                : filteredDataPoints[i - 1].planet?.percentage
                
                if let lastLiberation = currentPercentage,
                   let previousLiberation = previousPercentage
                {
                    let rate =
                    (lastLiberation - previousLiberation) / timeInterval
                    totalRate += rate
                    count += 1
                }
            }
        }
        
        // average liberation rate calculation
        let averageRate = count > 0 ? totalRate / count : nil
        
        print(
            "THE LAST PERCENT IN HISTORY IS \(dataPoints.last?.planet?.percentage)"
        )
        
        return averageRate
    }
    
    
    private func formatNumber(_ number: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let number = NSNumber(value: number)
        
        if number.intValue >= 1000 {
            let thousands = Double(number.intValue) / 1000.0
            return "\(formatter.string(from: NSNumber(value: thousands))!)K"
        } else {
            return formatter.string(from: number) ?? "\(number)"
        }
    }
    
}

enum Tab: String, CaseIterable {
    case home = "War" /*String(localized: "War")*/
    case news = "News"
    case game = "Hero"
    case about = "About"
    case orders = "Orders"
    case stats = "Data"
    case map = "Map"
    case tipJar = "Tip Jar"
    
    var localizedName: String {
        String(localized: "\(self.rawValue)")
    }
    
    var systemImage: String? {
        switch self {
        case .home:
            return "scope"
        case .game:
            return "gamecontroller.fill"
        case .news:
            return "newspaper.fill"
        case .about:
            return "info.circle.fill"
        case .orders:
            return "target"
        case .stats:
            return "globe.americas.fill"
        case .map:
            return "map.fill"
        case .tipJar:
            return "cart.fill"
        }
    }
}

actor PlanetHistoryManager {
    var history: [String: [UpdatedPlanetDataPoint]] = [:]
    
    func append(planet: String, dataPoint: UpdatedPlanetDataPoint) {
        history[planet, default: []].append(dataPoint)
    }
    
    func getHistory() -> [String: [UpdatedPlanetDataPoint]] {
        return history
    }
}

