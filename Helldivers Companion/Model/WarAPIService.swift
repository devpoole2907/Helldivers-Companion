//
//  WarAPIService.swift
//  Helldivers Companion
//
//  Created by James Poole on 23/02/2026.
//

import Foundation

/// Thread-safe networking service extracted from PlanetsDataModel.
/// No SwiftUI imports — works in app, widget, and watch targets.
actor WarAPIService {
    
    private let netManager = NetworkManager.shared
    
    // MARK: - Config
    
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
    
    // MARK: - War Time
    
    func fetchWarTime(season: String = "801") async -> Int64? {
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/WarSeason/\(season)/Status"
        
        do {
            let response: WarStatusResponse = try await netManager.fetchData(from: urlString)
            return response.time
        } catch {
            print("Error fetching war time: \(error)")
            return nil
        }
    }
    
    // MARK: - Status
    
    func fetchStatus(season: String = "801") async -> StatusResponse? {
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/WarSeason/\(season)/Status"
        do {
            let response: StatusResponse = try await netManager.fetchData(from: urlString)
            return response
        } catch {
            print("Error fetching galactic effects: \(error)")
            return nil
        }
    }
    
    // MARK: - Space Stations
    
    func fetchSpaceStations(apiAddress: String, language: String?) async -> [SpaceStation] {
        let urlString = "\(apiAddress)api/v2/space-stations"
        
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": language ?? "",
        ]
        
        do {
            let stations: [SpaceStation] = try await netManager.fetchData(
                from: urlString, headers: headers
            )
            
            print("station count: \(stations.count)")
            
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
    
    // MARK: - Space Station Details
    
    func fetchSpaceStationDetails(id32: Int64 = 749875195, season: String = "801") async -> SpaceStationDetails? {
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/SpaceStation/\(season)/\(id32)"
        
        do {
            let details: SpaceStationDetails = try await netManager.fetchData(from: urlString)
            return details
        } catch {
            print("Error fetching space station details: \(error)")
            return nil
        }
    }
    
    // MARK: - Campaigns
    
    func fetchCampaigns(url: String? = nil, apiAddress: String, language: String?) async -> ([UpdatedCampaign], [UpdatedCampaign]) {
        let urlString = url ?? "\(apiAddress)api/v1/campaigns"
        
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": language ?? "",
        ]
        
        do {
            let campaigns: [UpdatedCampaign] = try await netManager.fetchData(
                from: urlString, headers: headers)
            
            let finalPlanets = campaigns.map { $0.planet }
            
            for planet in finalPlanets {
                print("Planet current owner is: \(planet.currentOwner ?? "Unknown")")
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
    
    // MARK: - Personal Order
    
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
    
    // MARK: - Major Order
    
    func fetchMajorOrder(
        season: String = "801",
        planets: [UpdatedPlanet],
        language: String?
    ) async -> ([UpdatedPlanet], [MajorOrder]) {
        
        let urlString =
            "https://api.live.prod.thehelldiversgame.com/api/v2/Assignment/War/\(season)"
        
        let headers: [String: String] = [
            "Accept-Language": language ?? ""
        ]
        
        do {
            let majorOrders: [MajorOrder] =
                try await netManager.fetchData(from: urlString, headers: headers)
            
            guard !majorOrders.isEmpty else { return ([], []) }
            
            // Flat-map tasks and progress once
            let allTasks: [Setting.Task]   = majorOrders.flatMap { $0.setting.tasks }
            let allProgress: [Int64]       = majorOrders.flatMap { $0.progress }
            
            // 1. All planet indexes referenced by tasks (non-zero only)
            let taskPlanetIndexes: [Int64] = allTasks.compactMap { $0.planetIndex }
            
            // 2. Filter planet list down to those referenced in tasks
            var taskPlanets = planets.filter { planet in
                taskPlanetIndexes.contains(Int64(planet.index))
            }
            
            // 3. Attach progress to matching task planet
            var progressIndex = 0
            for task in allTasks {
                guard let planetIndex = task.planetIndex else {
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
    
    // MARK: - Planets
    
    func fetchPlanets(
        url: String? = nil, apiAddress: String, language: String?, status: StatusResponse? = nil
    ) async -> ([UpdatedPlanet], [String], [String: [UpdatedPlanet]]) {
        
        let urlString = url ?? "\(apiAddress)api/v1/planets"
        
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": language ?? "",
        ]
        
        do {
            var planets: [UpdatedPlanet] = try await netManager.fetchData(
                from: urlString, headers: headers)
            // update the outdated planets info from unofficial api with updated info in helldivers-2/json repo
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
    
    // MARK: - Galaxy Stats
    
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
    
    // MARK: - Cached Planet Data
    
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
                                let fileTimestamp = self.extractTimestamp(
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
    
    // MARK: - Planet Data Merging Helpers
    
    func fetchGalacticEffectDefinitions() async -> [Int: PlanetEffectJSON] {
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
    
    func fetchAndMergePlanets(planets: [UpdatedPlanet]) async -> [UpdatedPlanet] {
        print("Calling planet update...")
        
        do {
            print("Fetching planets JSON...")
            let planetsJSON: [String: PlanetsDataModel.PlanetJSON]
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
        planets: [UpdatedPlanet], with planetsJSON: [String: PlanetsDataModel.PlanetJSON],
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
                
                // weather effects added as additional environmentals:
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
    
    // MARK: - Utility
    
    nonisolated func extractTimestamp(from filename: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let endOfTimestampIndex =
            filename.firstIndex(of: "_") ?? filename.endIndex
        let timestampString = String(filename.prefix(upTo: endOfTimestampIndex))
        return dateFormatter.date(from: timestampString) ?? Date()
    }
}
