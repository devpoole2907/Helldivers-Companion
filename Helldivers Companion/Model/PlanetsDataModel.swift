//
//  PlanetsDataModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 17/07/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor @Observable
class PlanetsDataModel {
    
    static let shared = PlanetsDataModel()
    
    // for during loading
    var isLoading: Bool = true
    
    var showPlayerCount: Bool = false
    
    // pop map to root from other views
    @ObservationIgnored let popMapToRoot = PassthroughSubject<Void, Never>()
    
    // pop to warbonds list
    @ObservationIgnored let popToWarBonds = PassthroughSubject<Void, Never>()
    
    var updatedPlanets: [UpdatedPlanet] = []
    var updatedDefenseCampaigns: [UpdatedCampaign] = []
    var updatedCampaigns: [UpdatedCampaign] = []
    var updatedSortedSectors: [String] = []
    var updatedGroupedBySectorPlanets: [String: [UpdatedPlanet]] = [:]
    var updatedTaskPlanets: [UpdatedPlanet] = []
    var planetHistory: [String: [UpdatedPlanetDataPoint]] = [:]
    
    var spaceStations: [SpaceStation] = []
    var firstSpaceStationDetails: SpaceStationDetails?
    var warTime: Int64?
    var nextFetchTime: Date?  // for the ui to show count down if a fetch failed due to rate limiting
    var hasSetSelectedPlanet: Bool = false  // to stop setting the selected planet to the first in campaigns every fetch after the first
    
    var currentTab: Tab = .home
    
    // FOR DEBUGGING
    var lastError: String?
    
    var lastCampaignsError: String?
    
    var dashPatterns: [UUID: [CGFloat]] = [:]
    
    var currentSeason: String = ""
    var majorOrders: [MajorOrder] = []
    var personalOrder: PersonalOrder?
    var galaxyStats: GalaxyStats?
    var lastUpdatedDate: Date = Date()
    
    var showIlluminateUI: Bool = false
    
    var redactedShakeTimes = 0  // for redacting illuminate info animation
    
    var selectedPlanet: UpdatedPlanet?  // for map view selection
    
    var status: StatusResponse? // for dark energy tracking etc
    
    @ObservationIgnored @AppStorage("viewCount") var viewCount = 0
    
    // @AppStorage cannot be combined directly with @Observable (causes _name redeclaration).
    // Use a plain stored var seeded from UserDefaults; didSet persists changes back.
    var enableLocalization: Bool = UserDefaults.standard.object(forKey: "enableLocalization") as? Bool ?? true {
        didSet { UserDefaults.standard.set(enableLocalization, forKey: "enableLocalization") }
    }
    var darkMode: Bool = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? false {
        didSet { UserDefaults.standard.set(darkMode, forKey: "darkMode") }
    }

    @ObservationIgnored private var apiToken: String? = ProcessInfo.processInfo.environment[
        "GITHUB_API_KEY"]
    
    var configData: RemoteConfigDetails = RemoteConfigDetails(
        alert: "", prominentAlert: nil, season: "801", showIlluminate: false,
        apiAddress: "", startedAt: "2024-02-10T07:20:30.089979Z", meridiaEvent: false)
    
    var showInfo = false
    var showOrders = false
    
    // var apiAddress = "http://127.0.0.1:4000/api"
    var apiAddress = "https://helldivers-2.fly.dev/api"
    
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var cacheTimer: Timer?
    
    @ObservationIgnored let netManager = NetworkManager.shared
    @ObservationIgnored let apiService = WarAPIService()
    
    private(set) var totalPlayerCount: Int64 = 0
    private(set) var formattedPlayerCount: String = ""
    
    private(set) var fleetStrengthResource: GlobalResource?
    private(set) var fleetStrengthProgress: Double = 0
    
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
            }

            // Rebuild contexts inside withAnimation so the dictionary assignment
            // animates in the same transaction as the rest of the data update.
            // This is safe because the properties it reads (updatedPlanets, etc.)
            // are already set above in this same synchronous closure.
            self.rebuildFleetStrength()
            self.rebuildContexts()
            self.rebuildPlayerDistribution()
        }

        if isInitialLoad {
            withAnimation {
                self.isLoading = false
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
                    withAnimation(.bouncy) {
                        self.galaxyStats = galaxyStats?.galaxyStats
                        
                        self.planetHistory = cachedData
                        self.lastUpdatedDate = Date()
                        self.rebuildContexts()
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
    
    
    private(set) var playerDistribution: [PlayerDistributionItem] = []

    private func rebuildFleetStrength() {
        let resource = status?.globalResources.resource(for: .fleetStrength)
        fleetStrengthResource = resource
        fleetStrengthProgress = resource.map { r in r.maxValue > 0 ? Double(r.currentValue) / Double(r.maxValue) : 0.0 } ?? 0
    }

    private func rebuildPlayerDistribution() {
        var counts = [Faction: Int64]()
        for planet in updatedPlanets {
            counts[planet.faction, default: 0] += planet.statistics.playerCount
        }
        totalPlayerCount = updatedPlanets.reduce(0) { $0 + $1.statistics.playerCount }
        formattedPlayerCount = formatNumber(totalPlayerCount)
        playerDistribution = counts.compactMap { faction, count in
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
                CGFloat.random(in: 50...70), CGFloat.random(in: 5...20)
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

    // MARK: - PlanetContext

    /// Stored lookup — rebuilt once per refresh cycle via rebuildContexts().
    /// Stored (not computed) so @Observable / ObservableObject only notifies
    /// views once when the dictionary is reassigned, not on every individual
    /// property change that feeds into it.
    private(set) var contextLookup: [Int: PlanetContext] = [:]

    /// The single access point for all views — list rows, detail views, map, everything.
    func context(for planetIndex: Int) -> PlanetContext? {
        contextLookup[planetIndex]
    }

    /// Rebuilds the full lookup dictionary. Call once at the end of refreshAll().
    private func rebuildContexts() {
        contextLookup = Dictionary(
            uniqueKeysWithValues: updatedPlanets.compactMap { planet in
                buildContext(for: planet).map { (planet.index, $0) }
            }
        )
    }

    /// Computes a PlanetContext for one planet. Private — views use context(for:).
    private func buildContext(for planet: UpdatedPlanet) -> PlanetContext? {
        let planetIndex = planet.index
        let defense = updatedDefenseCampaigns.first { $0.planet.index == planetIndex }
        let isActive = updatedCampaigns.contains { $0.planet.index == planetIndex }
        let isDefending = defense != nil

        let faction: Faction = {
            if isDefending, let ef = defense?.planet.event?.faction { return Faction(ownerString: ef) }
            return Faction(ownerString: planet.currentOwner)
        }()

        let libPct: Double = {
            if !isActive && planet.currentOwner.lowercased() == "humans" { return 100.0 }
            if defense?.planet.event?.eventType == 3, fleetStrengthResource != nil {
                return (1.0 - fleetStrengthProgress) * 100
            }
            return defense?.planet.event?.percentage ?? planet.percentage
        }()

        let rate = currentLiberationRate(for: planet.name)
        let timeRemaining: Date? = {
            let current = planet.event?.percentage ?? planet.percentage
            guard let r = rate, r > 0 else { return nil }
            return Date().addingTimeInterval(((100.0 - current) / r) * 3600)
        }()

        let station = spaceStations.first { $0.planet.index == planetIndex }
        let stationDetails = station.flatMap { s in
            firstSpaceStationDetails?.id32 == s.id32 ? firstSpaceStationDetails : nil
        }

        let regions = planet.regions ?? []

        return PlanetContext(
            planet: planet,
            faction: faction,
            ownerFaction: Faction(ownerString: planet.currentOwner),
            isActive: isActive,
            isDefending: isDefending,
            campaignType: updatedCampaigns.first { $0.planet.index == planetIndex }?.type,
            liberationType: isDefending ? .defense : .liberation,
            liberationPercentage: libPct,
            liberationRate: rate,
            liberationTimeRemaining: timeRemaining,
            eventExpiration: defense?.planet.event?.expireTimeDate,
            eventTotalDuration: defense?.planet.event?.totalDuration,
            invasionLevel: defense?.planet.event?.invasionLevel,
            eventHealth: defense?.planet.event?.health,
            eventMaxHealth: defense?.planet.event?.maxHealth,
            fleetStrengthProgress: fleetStrengthResource != nil ? fleetStrengthProgress : nil,
            fleetStrengthResource: fleetStrengthResource,
            spaceStation: station,
            spaceStationDetails: stationDetails,
            spaceStationExpiration: station?.electionEndDate,
            matchingRegions: regions,
            isMajorOrderTarget: updatedTaskPlanets.contains { $0.index == planetIndex },
            taskProgress: planet.taskProgress,
            warTime: warTime
        )
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
