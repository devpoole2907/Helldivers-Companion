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
    
    // merges additonal region info from warinfo endpoint
    
    func mergeWarInfoRegions(into status: StatusResponse?, with warInfo: WarInfoResponse?) -> StatusResponse? {
        guard
            let status,
            let originalRegions = status.planetRegions,
            let warInfo
        else {
            return status
        }

        let updatedRegions = originalRegions.map { region -> PlanetRegion in
            var updatedRegion = region
            if let warRegion = warInfo.planetRegions.first(where: {
                $0.planetIndex == region.planetIndex && $0.regionIndex == region.regionIndex
            }) {
                updatedRegion.maxHealth = warRegion.maxHealth
                updatedRegion.regionSize = warRegion.regionSize
            }
            return updatedRegion
        }

        return StatusResponse(
            planetActiveEffects: status.planetActiveEffects,
            globalResources: status.globalResources,
            planetRegions: updatedRegions
        )
    }
    
    func startUpdating() {
        Task {
            guard let config = await fetchConfig() else {
                print("config failed to load")
                return
            }
            
            let warTime = await fetchWarTime(with: config)
            
            let status = await fetchStatus(with: config)
            
            let warInfo = await fetchWarInfo(with: config)
            
            let mergedStatus = mergeWarInfoRegions(into: status, with: warInfo)
            
            let galaxyStats = await fetchGalaxyStats()
            let (campaigns, defenseCampaigns) = await fetchCampaigns(
                for: config)
            let (planets, sortedSectors, groupedBySector) = await fetchPlanets(for: config, with: status)
            let (taskPlanets, majorOrders) = await fetchMajorOrder(with: planets)
            let spaceStations = await fetchSpaceStations(for: config)
            
            // TODO: for now, fetch ONLY the first station - upgrade in future for more spcae stations
            
            let firstStationID = spaceStations.first?.id32 ?? 749875195 // fallback to static id for dss
            let firstStationDetails = await self.fetchSpaceStationDetails(for: firstStationID, with: config)
            let personalOrder = await self.fetchPersonalOrder()
            
            await MainActor.run {
                self.objectWillChange.send()
                withAnimation(.bouncy) {
                    self.configData = config
                    self.showIlluminateUI = config.showIlluminate
                    self.warTime = warTime
                    self.status = mergedStatus
                    self.updatedCampaigns = campaigns
                    self.updatedDefenseCampaigns = defenseCampaigns
                    self.galaxyStats = galaxyStats?.galaxyStats
                    
                    self.updatedPlanets = planets
                    self.spaceStations = spaceStations
                    self.updatedSortedSectors = sortedSectors
                    self.updatedGroupedBySectorPlanets = groupedBySector
                    self.updatedTaskPlanets = taskPlanets
                    
                    self.majorOrders = majorOrders
                    self.personalOrder = personalOrder
                    self.firstSpaceStationDetails = firstStationDetails
                    
                    self.lastUpdatedDate = Date()
                    
                    if !(self.hasSetSelectedPlanet) {
                        // for first call set default selected planet for map view
                        // set default selected planet for map, grab first planet in campaigns, only if it hasnt been set already
                        self.selectedPlanet = campaigns.first?.planet
                        self.hasSetSelectedPlanet = true
                    }
                    
                    withAnimation {
                        self.isLoading = false
                    }
                    
                }
                
            }
            
            //    print("fetched major order")
        }
        
        Task {
            let cachedData = await fetchCachedPlanetData()
            
            await MainActor.run {
                self.objectWillChange.send()
                withAnimation(.bouncy) {
                    self.planetHistory = cachedData
                    self.lastUpdatedDate = Date()
                }
            }
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
                
                guard let config = await self.fetchConfig() else {
                    print("config failed to load")
                    return
                }
                let warTime = await self.fetchWarTime(with: config)
                let status = await self.fetchStatus(with: config)
                
                let warInfo = await self.fetchWarInfo(with: config)
                
                let mergedStatus = await self.mergeWarInfoRegions(into: status, with: warInfo)
                
                let (campaigns, defenseCampaigns) = await self.fetchCampaigns(
                    for: config)
                let (planets, sortedSectors, groupedBySector) = await self.fetchPlanets(for: config, with: status)
                let (taskPlanets, majorOrders) = await self.fetchMajorOrder(
                    with: planets)
                print("getting the fookn space stations")
                let spaceStations = await self.fetchSpaceStations(for: config)
                
                // TODO: for now, fetch ONLY the first station - upgrade in future for more spcae stations
                
                let firstStationID = spaceStations.first?.id32 ?? 749875195 // fallback to static id for dss
                let firstStationDetails = await self.fetchSpaceStationDetails(for: firstStationID, with: config)
                
                let personalOrder = await self.fetchPersonalOrder()
                
                await MainActor.run {
                    self.objectWillChange.send()
                    withAnimation(.bouncy) {
                        self.configData = config
                        self.showIlluminateUI = config.showIlluminate
                        self.warTime = warTime
                        self.status = mergedStatus
                        self.updatedCampaigns = campaigns
                        self.updatedDefenseCampaigns = defenseCampaigns
                        
                        self.updatedPlanets = planets
                        self.spaceStations = spaceStations
                        self.updatedSortedSectors = sortedSectors
                        self.updatedGroupedBySectorPlanets = groupedBySector
                        self.updatedTaskPlanets = taskPlanets
                        
                        self.majorOrders = majorOrders
                        self.personalOrder = personalOrder
                        self.firstSpaceStationDetails = firstStationDetails
                        
                        self.lastUpdatedDate = Date()
                    }
                    
                }
                
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
        let apiURLString =
        "https://api.github.com/repos/devpoole2907/helldivers-api-cache/contents/newData"
        
        do {
            let files = try await netManager.fetchFileList(from: apiURLString)
            let manager = PlanetHistoryManager()
            
            print("Fetched files count: \(files.count)")
            
            // Fetch and decode files in parallel
            await withTaskGroup(of: Void.self) { group in
                for file in files {
                    group.addTask {
                        do {
                            print("Processing file: \(file.name)")
                            guard let fileURL = URL(string: file.downloadUrl)
                            else { return }
                            let decodedResponse: [UpdatedPlanet] =
                            try await NetworkManager.shared.fetchFileData(
                                from: fileURL.absoluteString)
                            
                            for planet in decodedResponse {
                                let fileTimestamp = await self.extractTimestamp(
                                    from: file.name)
                                let dataPoint = UpdatedPlanetDataPoint(
                                    timestamp: fileTimestamp, planet: planet)
                                await manager.append(
                                    planet: planet.name, dataPoint: dataPoint)
                            }
                        } catch {
                            print(
                                "Error decoding data for file \(file.name): \(error)"
                            )
                        }
                    }
                }
            }
            
            // Retrieve + sort the planet history
            var finalHistory = await manager.getHistory()
            for key in finalHistory.keys {
                finalHistory[key]?.sort(by: { $0.timestamp < $1.timestamp })
            }
            
            return finalHistory
            
        } catch {
            print("Error fetching cached planet data: \(error)")
            return [:]
        }
    }
    
    func fetchWarTime(with config: RemoteConfigDetails? = nil) async -> Int64? {
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/WarSeason/\(config?.season ?? "801")/Status"
        
        do {
            // minimal struct for decoding
            let response: WarStatusResponse = try await netManager.fetchData(from: urlString)
            return response.time
        } catch {
            print("Error fetching war time: \(error)")
            return nil
        }
    }
    
    func fetchWarInfo(with config: RemoteConfigDetails? = nil) async -> WarInfoResponse? {
        
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/WarSeason/\(config?.season ?? "801")/WarInfo"
        
        do {
            // minimal struct for decoding
            let response: WarInfoResponse = try await netManager.fetchData(from: urlString)
            return response
        } catch {
            print("Error fetching war time: \(error)")
            return nil
        }
        
    }
    
    func fetchStatus(with config: RemoteConfigDetails? = nil) async -> StatusResponse? {
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/WarSeason/\(config?.season ?? "801")/Status"
        do {
            let response: StatusResponse = try await netManager.fetchData(from: urlString)
            return response
        } catch {
            print("Error fetching galactic effects: \(error)")
            return nil
        }
    }
    
    func fetchSpaceStationDetails(for id32: Int64? = nil, with config: RemoteConfigDetails? = nil) async -> SpaceStationDetails? {
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/SpaceStation/\(config?.season ?? "801")/\(id32 ?? 749875195)"
        
        do {
            let details: SpaceStationDetails = try await netManager.fetchData(from: urlString)
            return details
        } catch {
            print("Error fetching space station details: \(error)")
            return nil
        }
    }
    
    func fetchSpaceStations(using url: String? = nil, for configData: RemoteConfigDetails) async -> [SpaceStation] {
        let urlString = "\(configData.apiAddress)api/v2/space-stations"
        
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": enableLocalization ? apiSupportedLanguage : "",
        ]
        
        do {
            let stations: [SpaceStation] = try await netManager.fetchData(
                from: urlString, headers: headers
            )
            
            print("station count: \(stations.count)")
            
            // fetched stations logging
            for station in stations {
                print("Station ID: \(station.id32), Election End: \(station.electionEnd)")
                print("Planet: \(station.planet.name), Owner: \(station.planet.currentOwner)")
            }
            
            return stations
        } catch {
            print("Error fetching space stations: \(error)")
            return []
        }
        
        
    }
    
    func fetchCampaigns(
        using url: String? = nil, for configData: RemoteConfigDetails
    ) async -> ([UpdatedCampaign], [UpdatedCampaign]) {
        let urlString = url ?? "\(configData.apiAddress)api/v1/campaigns"
        
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": enableLocalization ? apiSupportedLanguage : "",
        ]
        
        do {
            
            let campaigns: [UpdatedCampaign] = try await netManager.fetchData(
                from: urlString, headers: headers)
            
            let finalPlanets = campaigns.map { $0.planet }
            
            for planet in finalPlanets {
                print(
                    "Planet current owner is: \(planet.currentOwner ?? "Unknown")"
                )
                print("Planet regen is: \(planet.regenPerSecond ?? 0)")
            }
            
            // Update campaigns with the updated planets with additional info
            let updatedCampaigns = campaigns.map {
                campaign -> UpdatedCampaign in
                var updatedCampaign = campaign
                if let updatedPlanet = finalPlanets.first(where: {
                    $0.name == campaign.planet.name
                }) {
                    updatedCampaign.planet = updatedPlanet
                }
                return updatedCampaign
            }
            
            let sortedCampaigns = updatedCampaigns.sorted {
                firstCampaign, secondCampaign in
                if firstCampaign.planet.event != nil
                    && secondCampaign.planet.event == nil
                {
                    return true
                } else if firstCampaign.planet.event == nil
                            && secondCampaign.planet.event != nil
                {
                    return false
                } else {
                    return firstCampaign.planet.statistics.playerCount
                    > secondCampaign.planet.statistics.playerCount
                }
            }
            
            let defenseCampaigns = sortedCampaigns.filter {
                $0.planet.event != nil
            }
            
            return (sortedCampaigns, defenseCampaigns)
            
        } catch {
            print("Error fetching campaigns: \(error)")
            return ([], [])
        }
    }
    
    func fetchPersonalOrder() async -> PersonalOrder? {
        let urlString =
        "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/refs/heads/main/newData/personalOrder.json"
        
        do {
            let orders: [PersonalOrder] = try await netManager.fetchData(from: urlString)
            return orders.first(where: { $0.expiresIn > 0 })
        } catch {
            print("Error fetching personal order: \(error)")
            return nil
        }
    }
    
    func fetchMajorOrder(
        for season: String? = nil,
        with planets: [UpdatedPlanet]? = nil
    ) async -> ([UpdatedPlanet], [MajorOrder]) {

        let seasonString = season ?? configData.season
        let urlString =
            "https://api.live.prod.thehelldiversgame.com/api/v2/Assignment/War/\(seasonString)"

        let headers: [String: String] = [
            "Accept-Language": enableLocalization ? apiSupportedLanguage : ""
        ]

        do {
            let majorOrders: [MajorOrder] =
                try await netManager.fetchData(from: urlString, headers: headers)

            guard !majorOrders.isEmpty else { return ([], []) }

            // Flat-map tasks and progress once
            let allTasks: [Setting.Task]   = majorOrders.flatMap { $0.setting.tasks }
            let allProgress: [Int64]       = majorOrders.flatMap { $0.progress }

            let collectionOfPlanets = planets ?? self.updatedPlanets

            /// Helper closure – prefer valueType 12 (planet index), fall back to 11.
            let extractPlanetIndex: (Setting.Task) -> Int64? = { task in
                if let i = task.valueTypes.firstIndex(of: 12), i < task.values.count {
                    return task.values[i]
                }
                if let i = task.valueTypes.firstIndex(of: 11), i < task.values.count {
                    return task.values[i]
                }
                return nil
            }

            // 1️⃣ All planet indexes referenced by tasks (non-zero only)
            let taskPlanetIndexes: [Int64] = allTasks.compactMap { task in
                guard let idx = extractPlanetIndex(task), idx != 0 else { return nil }
                return idx
            }

            // 2️⃣ Filter planet list down to those referenced in tasks
            var taskPlanets = collectionOfPlanets.filter { planet in
                taskPlanetIndexes.contains(Int64(planet.index))
            }

            // 3️⃣ Attach progress to matching task planet
            var progressIndex = 0
            for task in allTasks {
                guard let planetIndex = extractPlanetIndex(task), planetIndex != 0 else {
                    progressIndex += 1
                    continue
                }

                if let arrayIdx = taskPlanets.firstIndex(where: { $0.index == planetIndex }),
                   progressIndex < allProgress.count {
                    taskPlanets[arrayIdx].taskProgress = allProgress[progressIndex]
                }
                progressIndex += 1
            }

            print("Fetched \(majorOrders.count) major orders.")
            return (taskPlanets, majorOrders)

        } catch {
            print("Decoding error: \(error)")
            return ([], [])
        }
    }
    
    func fetchConfig() async -> RemoteConfigDetails? {
        let urlString =
        "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/config/feb2025config.json"
        
        do {
            let configData: RemoteConfigDetails =
            try await netManager.fetchData(from: urlString)
            
            return configData
        } catch {
            print("Failed to fetch config: \(error)")
            return nil
        }
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
        
        let urlString = url ?? "\(configData.apiAddress)api/v1/planets"
        
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": enableLocalization ? apiSupportedLanguage : "",
        ]
        
        do {
            var planets: [UpdatedPlanet] = try await netManager.fetchData(
                from: urlString, headers: headers)
            // update the outdated planets info from unofficial api with updated info in helldivers-2/json repo - bit of a duct tape but hey it works
            planets = await fetchAndMergePlanets(planets: planets)
            print("updating planets")
            
            planets = await mergeGalacticEffectsIntoPlanets(planets, with: status)
            
            // Group planets by sector
            let groupedBySector = Dictionary(grouping: planets) { $0.sector }
            // Sort alphabetically by sector
            let sortedSectors = groupedBySector.keys.sorted()
            
            for planet in planets {
                print("planet current owner is: \(planet.currentOwner)")
                print("planet regen is: \(planet.regenPerSecond)")
            }
            
            return (planets, sortedSectors, groupedBySector)
            
        } catch {
            print("Decoding error: \(error)")
            return ([], [], [:])
        }
    }
    
    func fetchGalaxyStats() async -> GalaxyStatsResponseData? {
        print("fetch galaxy stats called!")
        
        let urlString =
        "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/planets/galaxyStatistics.json"
        
        do {
            let decodedResponse: GalaxyStatsResponseData =
            try await netManager.fetchData(from: urlString)
            
            print("fetchGalaxyStats: Network request completed")
            
            return decodedResponse
            
        } catch {
            print("Network or decoding error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // other
    
    func fetchGalacticEffectDefinitions() async -> [Int: PlanetEffectJSON] {
        
        // this is coming from a fork of the json repo
        let urlString = "https://raw.githubusercontent.com/CrosswaveOmega/json/refs/heads/master/effects/planetEffects.json"
        do {
            let planetEffectsDict: [String: PlanetEffectJSON] = try await netManager.fetchData(from: urlString)
            
            var result = [Int: PlanetEffectJSON]()
            for (key, value) in planetEffectsDict {
                if let effectId = Int(key) {
                    result[effectId] = value
                }
            }
            return result
            
        } catch {
            print("Error fetching planetEffects.json: \(error)")
            return [:]
        }
        
    }
    
    // merge galactic effects into planets based on index
    
    func mergeGalacticEffectsIntoPlanets(_ planets: [UpdatedPlanet], with status: StatusResponse? = nil) async -> [UpdatedPlanet] {
        print("calling galactic effects planet update...")
        
        var updatedPlanets = planets
        
        guard let status = status else {
            print("Status data is missing, skipping merge")
            return updatedPlanets
        }
        
        let galacticEffects = status.planetActiveEffects
        
        let effectDefinitions = await fetchGalacticEffectDefinitions()
        
        let effectsByPlanetIndex = Dictionary(grouping: galacticEffects, by: { $0.index })
        
        for i in updatedPlanets.indices {
            let planetIndex = updatedPlanets[i].index
            if let effects = effectsByPlanetIndex[planetIndex] {
                
                let updatedEffects: [GalacticEffect] = effects.map { effect in
                    var mutableEffect = effect
                    if let def = effectDefinitions[effect.galacticEffectId] {
                        mutableEffect.name = def.name
                        mutableEffect.description = def.description
                    }
                    return mutableEffect
                }
                
                
                updatedPlanets[i].galacticEffects = updatedEffects
            }
        }
        
        return updatedPlanets
    }
    
    // a duct tape fix - this overwrites the outdated planet information provided by the unofficial api, with up to date planet info from the helldivers-2/json repo
    func fetchAndMergePlanets(planets: [UpdatedPlanet]) async -> [UpdatedPlanet] {
        print("Calling planet update...")
        
        do {
            print("Fetching planets JSON...")
            let planetsJSON: [String: PlanetJSON]
            do {
                planetsJSON = try await netManager.fetchData(
                    from: "https://raw.githubusercontent.com/helldivers-2/json/master/planets/planets.json"
                )
                print("Successfully fetched planets JSON with \(planetsJSON.count) entries.")
            } catch {
                print("Failed to fetch planets JSON: \(error.localizedDescription)")
                throw error
            }
            
            print("Fetching biomes JSON...")
            let biomesJSON: [String: Biome]
            do {
                biomesJSON = try await netManager.fetchData(
                    from: "https://raw.githubusercontent.com/helldivers-2/json/master/planets/biomes.json"
                )
                print("Successfully fetched biomes JSON with \(biomesJSON.count) entries.")
            } catch {
                print("Failed to fetch biomes JSON: \(error.localizedDescription)")
                throw error
            }
            
            print("Fetching environmentals JSON...")
            let environmentalsJSON: [String: Environmental]
            do {
                environmentalsJSON = try await netManager.fetchData(
                    from: "https://raw.githubusercontent.com/helldivers-2/json/master/planets/environmentals.json"
                )
                print("Successfully fetched environmentals JSON with \(environmentalsJSON.count) entries.")
            } catch {
                print("Failed to fetch environmentals JSON: \(error.localizedDescription)")
                throw error
            }
            
            print("Updating planet data with fetched JSON...")
            return updatePlanets(
                planets: planets,
                with: planetsJSON,
                biomes: biomesJSON,
                environmentals: environmentalsJSON
            )
        } catch {
            print("Error during planet update process: \(error.localizedDescription)")
            print("Debug suggestion: Check if the JSON endpoints are reachable and contain valid data.")
            return planets
        }
    }
    
    func updatePlanets(
        planets: [UpdatedPlanet], with planetsJSON: [String: PlanetJSON],
        biomes: [String: Biome], environmentals: [String: Environmental]
    ) -> [UpdatedPlanet] {
        var updatedPlanets = planets
        
        for i in 0..<updatedPlanets.count {
            let planetIndex = String(updatedPlanets[i].index)
            
            if let planetData = planetsJSON[planetIndex] {
                // update biome
                if let biomeInfo = biomes[planetData.biome] {
                    updatedPlanets[i].biome = biomeInfo
                }
                
                // update hazards (environmentals)
                var updatedHazards = planetData.environmentals.compactMap {
                    envKey in
                    environmentals[envKey]
                }
                
                print("i added initial hazards, now adding weather effects")
                
                // weather effects added as additional encvironmentals:
                if let weatherEffects = planetData.weatherEffects {
                    for weatherKey in weatherEffects {
                        if weatherKey == "normal_temp" {
                            // skip normal temp, not a hazard
                            continue
                        }
                        if let weather = environmentals[weatherKey],
                           !updatedHazards.contains(where: { $0.name == weather.name }) {
                            print("\(updatedPlanets[i].name): adding \(weather.name)")
                            updatedHazards.append(weather)
                        }
                    }
                }
                
                updatedPlanets[i].hazards = updatedHazards
                
            }
        }
        
        return updatedPlanets
    }
    
    
    var playerDistribution: [PlayerDistributionItem] {

        var distribution: [String: (count: Int64, color: Color)] = [
            "Automaton": (0, .red),
            "Terminids": (0, .yellow),
            "Illuminate": (0, .purple),
            "Other": (0, .cyan)
        ]
        
        // sum player counts for each planet
        for planet in updatedPlanets {
            let count = planet.statistics.playerCount
            let factionName = planet.factionName.lowercased()
            
            switch factionName {
            case "automaton":
                distribution["Automaton"]?.count += count
            case "terminids":
                distribution["Terminids"]?.count += count
            case "illuminate":
                distribution["Illuminate"]?.count += count
            default:
                distribution["Other"]?.count += count
            }
        }
        
        return distribution.compactMap { key, value in
            value.count > 0
                ? PlayerDistributionItem(faction: key, count: value.count, color: value.color)
                : nil
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
    
    func getColorForPlanet(planet: UpdatedPlanet?) -> Color {
        guard let planet = planet else {
            return .gray  // default color if no matching planet found
        }
        
        if planet.currentOwner == "Humans" {
            if updatedDefenseCampaigns.contains(where: {
                $0.planet.index == planet.index
            }) {
                let campaign = updatedDefenseCampaigns.first {
                    $0.planet.index == planet.index
                }
                switch campaign?.planet.event?.faction {
                case "Terminids": return .yellow
                case "Automaton": return .red
                case "Illuminate": return .purple
                default: return .cyan
                }
            } else {
                return .cyan
            }
        } else if updatedCampaigns.contains(where: {
            $0.planet.index == planet.index
        }) {
            if !updatedDefenseCampaigns.contains(where: {
                $0.planet.index == planet.index
            }) {
                switch planet.currentOwner {
                case "Automaton": return .red
                case "Terminids": return .yellow
                case "Illuminate": return .purple
                default: return .gray  // default color if currentOwner doesn't match any known factions
                }
            }
        } else {
            switch planet.currentOwner {
            case "Automaton": return .red
            case "Terminids": return .yellow
            case "Illuminate": return .purple
            default: return .gray  // default color if currentOwner doesn't match any known factions
            }
        }
        
        return .gray  // if no conditions meet for some reason
    }
    
    func getImageNameForPlanet(_ planet: UpdatedPlanet?) -> String {
        guard let planet = planet else {
            return "human"
        }
        
        if planet.currentOwner == "Humans" {
            if updatedDefenseCampaigns.contains(where: {
                $0.planet.index == planet.index
            }) {
                let campaign = updatedDefenseCampaigns.first {
                    $0.planet.index == planet.index
                }
                switch campaign?.planet.event?.faction {
                case "Terminids": return "terminid"
                case "Automaton": return "automaton"
                case "Illuminate": return "illuminate"
                default: return "human"
                }
            } else {
                return "human"
            }
        } else if updatedCampaigns.contains(where: {
            $0.planet.index == planet.index
        }) {
            if !updatedDefenseCampaigns.contains(where: {
                $0.planet.index == planet.index
            }) {
                switch planet.currentOwner {
                case "Automaton": return "automaton"
                case "Terminids": return "terminid"
                case "Illuminate": return "illuminate"
                default: return "human"
                }
            }
        } else {
            switch planet.currentOwner {
            case "Automaton": return "automaton"
            case "Terminids": return "terminid"
            case "Illuminate": return "illuminate"
            default: return "human"
            }
        }
        
        return "human"
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
    
    func extractTimestamp(from filename: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let endOfTimestampIndex =
        filename.firstIndex(of: "_") ?? filename.endIndex
        let timestampString = String(filename.prefix(upTo: endOfTimestampIndex))
        return dateFormatter.date(from: timestampString) ?? Date()
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
