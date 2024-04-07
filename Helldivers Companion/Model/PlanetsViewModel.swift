//
//  PlanetsViewModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation
import SwiftUI

class PlanetsViewModel: ObservableObject {
    
    @Published var updatedPlanets: [UpdatedPlanet] = []
    @Published var updatedDefenseCampaigns: [UpdatedCampaign] = []
    @Published var updatedCampaigns: [UpdatedCampaign] = []
    @Published var updatedSortedSectors: [String] = []
    @Published var updatedGroupedBySectorPlanets: [String: [UpdatedPlanet]] = [:]
    @Published var updatedTaskPlanets: [UpdatedPlanet] = []
    
    
    
    @Published var currentTab: Tab = .home
    
    @Published var allPlanetStatuses: [PlanetStatus] = []
    
    @Published var sortedSectors: [String] = []
    @Published var groupedBySectorPlanetStatuses: [String: [PlanetStatus]] = [:] // to display in stats view all planets by sector
    
    @Published var defensePlanets: [PlanetEvent] = []
    @Published var campaignPlanets: [PlanetStatus] = []
    @Published var currentSeason: String = ""
    @Published var majorOrder: MajorOrder? = nil
    @Published var galaxyStats: GalaxyStats? = nil
    @Published var warStatusResponse: WarStatusResponse? = nil
    @Published var lastUpdatedDate: Date = Date()
    // planetstatuses with tasks in the major order (e.g need to be liberated)
    @Published var taskPlanets: [PlanetStatus] = []
    
    @Published var selectedPlanet: UpdatedPlanet? = nil // for map view selection
    
    @AppStorage("viewCount") var viewCount = 0
    
    private var apiToken: String? = ProcessInfo.processInfo.environment["GITHUB_API_KEY"]
    
    @Published var configData: RemoteConfigDetails = RemoteConfigDetails(terminidRate: "-5%", automatonRate: "-1.5%", illuminateRate: "-0%", alert: "", prominentAlert: nil, season: "801", showIlluminate: false, apiAddress: "")
    
    @Published var showInfo = false
    @Published var showOrders = false
    
    //var apiAddress = "http://127.0.0.1:4000/api"
    var apiAddress = "https://helldivers-2.fly.dev/api"
    
    @Published var planetHistory: [String: [PlanetDataPoint]] = [:]
    @Published var eventHistory: [String: [PlanetDataPoint]] = [:]
    
    private var timer: Timer?
    private var cacheTimer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    func getColorForPlanet(planet: UpdatedPlanet?) -> Color {
        guard let planet = planet else {
            return .gray // default color if no matching planet found
        }
        
        if planet.currentOwner == "Humans" {
            if updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                let campaign = updatedDefenseCampaigns.first { $0.planet.index == planet.index }
                switch campaign?.planet.event?.faction {
                case "Terminids": return .yellow
                case "Automaton": return .red
                case "Illuminate": return .blue
                default: return .cyan
                }
            } else {
                return .cyan
            }
        } else if updatedCampaigns.contains(where: { $0.planet.index == planet.index }) {
            if !updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                switch planet.currentOwner {
                case "Automaton": return .red
                case "Terminids": return .yellow
                case "Illuminate": return .blue
                default: return .gray // default color if currentOwner doesn't match any known factions
                }
                
                
                print("current owner is \(planet.currentOwner)")
            }
        } else {
            switch planet.currentOwner {
            case "Automaton": return .red
            case "Terminids": return .yellow
            case "Illuminate": return .blue
            default: return .gray // default color if currentOwner doesn't match any known factions
            }
        }
        
        return .gray // if no conditions meet for some reason
    }
    
    func getImageNameForPlanet(_ planet: UpdatedPlanet?) -> String {
           guard let planet = planet else {
               return "human" 
           }
           
           if planet.currentOwner == "humans" {
               if updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                   let campaign = updatedDefenseCampaigns.first { $0.planet.index == planet.index }
                   switch campaign?.planet.event?.faction {
                   case "Terminids": return "terminid"
                   case "Automaton": return "automaton"
                   case "Illuminate": return "illuminate"
                   default: return "human"
                   }
               } else {
                   return "human"
               }
           } else if updatedCampaigns.contains(where: { $0.planet.index == planet.index }) {
               if !updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
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
    
    
    func averageLiberationRate(for planetName: String) -> Double? {
        guard let dataPoints = planetHistory[planetName] else {
            return nil
        }
        // exclude 100 because 100 will only show if a planet has become part of a recent event
        let filteredDataPoints = dataPoints.filter { $0.status?.liberation != 100.0 }
        
        // must be at least 2 data points
        guard filteredDataPoints.count >= 2 else {
            return nil
        }
        
        var totalRate: Double = 0
        var count: Double = 0
        
        for i in 1..<filteredDataPoints.count {
            let timeInterval = filteredDataPoints[i].timestamp.timeIntervalSince(filteredDataPoints[i - 1].timestamp) / 3600
            if timeInterval > 0, let lastLiberation = filteredDataPoints[i].status?.liberation, let previousLiberation = filteredDataPoints[i - 1].status?.liberation {
                let rate = (lastLiberation - previousLiberation) / timeInterval
                totalRate += rate
                count += 1
            }
        }
        
        // average liberation rate calculation
        let averageRate = count > 0 ? totalRate / count : nil
        return averageRate
    }
    
    
    func fetchPlanetStatusTimeSeries(completion: @escaping (Error?) -> Void) {
        Task {
            do {
                let history = try await fetchCachedPlanetData()
                DispatchQueue.main.async {
                    self.planetHistory = history.0
                    self.eventHistory = history.1
                    
                    print("there are this many event history: \(self.eventHistory.count)")
                    
                    //    print("Success, there are \(history.count) data points")
                    completion(nil)  // No error, pass nil to the completion handler
                }
            } catch {
                print("Error fetching planet status time series: \(error)")
                completion(error)  // Pass the error to the completion handler
            }
        }
    }
    
    func fetchCachedPlanetData() async throws -> ([String: [PlanetDataPoint]], [String: [PlanetDataPoint]]) {
        let apiURLString = "https://api.github.com/repos/devpoole2907/helldivers-api-cache/contents/data"
        guard let apiURL = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        
        if let apiToken = apiToken { // unauthenticated for deployed versions
            
            request.addValue("token \(apiToken)", forHTTPHeaderField: "Authorization")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let (apiData, _) = try await URLSession.shared.data(for: request)
        
        let files = try decoder.decode([GitHubFile].self, from: apiData)
        
        var planetHistory: [String: [PlanetDataPoint]] = [:]
        var defensePercentages: [String: Double] = [:]
        
        for file in files {
            guard let fileURL = URL(string: file.downloadUrl) else {
                continue
            }
            
            do {
                let (fileData, response) = try await URLSession.shared.data(from: fileURL)
                
                guard response is HTTPURLResponse else {
                    continue
                }
                
                let decodedResponse = try decoder.decode(WarStatusResponse.self, from: fileData)
                let planetStatuses = decodedResponse.planetStatus
                
                // calculate defense if a planet is defending
                for event in decodedResponse.planetEvents {
                    let planetName = event.planet.name
                    let defensePercentage = event.maxHealth > 0 ? (1 - (Double(event.health) / Double(event.maxHealth))) * 100 : 0
                    
                    // dont replace the defense percents in from the current files events if the real time defense planets doesnt contain the events in the current file
                    if self.defensePlanets.contains(where: {$0.planet.name == event.planet.name }) {
                        
                        defensePercentages[planetName] = defensePercentage
                    }
                }
                
                
                // adds data point but first calcs liberation rate
                for status in planetStatuses {
                    let planetName = status.planet.name
                    let fileTimestamp = extractTimestamp(from: file.name)
                    
                    //  print("filestamp is \(fileTimestamp)")
                    
                    let previousDataPoint = planetHistory[planetName]?.last
                    var currentDataPoint = PlanetDataPoint(timestamp: fileTimestamp, status: status)
                    
                    
                    
                    
                    
                    // override the liberation with a defense percentage if defending
                    if let defensePercentage = defensePercentages[planetName] {
                        
                        currentDataPoint.status?.liberation = defensePercentage
                    }
                    
                    
                    
                    
                    planetHistory[planetName, default: []].append(currentDataPoint)
                }
                
            } catch {
                // print("Error fetching file data: \(error)")
                continue // skip file, couldve been rated limited
            }
        }
        
        for key in planetHistory.keys {
            planetHistory[key]?.sort(by: { $0.timestamp < $1.timestamp })
        }
        
        return (planetHistory, eventHistory)
        
    }
    
    
    func extractTimestamp(from filename: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let endOfTimestampIndex = filename.firstIndex(of: "_") ?? filename.endIndex
        let timestampString = String(filename.prefix(upTo: endOfTimestampIndex))
        return dateFormatter.date(from: timestampString) ?? Date()
    }
    
    func fetchMajorOrder(for season: String? = nil, with planets: [UpdatedPlanet]? = nil, completion: @escaping ([UpdatedPlanet], MajorOrder?) -> Void) {
        
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/v2/Assignment/War/\(season ?? configData.season)"
        
        print("made url")
        guard let url = URL(string: urlString) else { print("mission failed")
            return }
        
        var request = URLRequest(url: url)
        request.addValue("en", forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data else {
                print("NOOO! No data received: \(error?.localizedDescription ?? "Unknown error")")
                completion([], nil)
                return
            }
            
            
            do {
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let decodedResponse = try decoder.decode([MajorOrder].self, from: data)
                
                var taskPlanets: [UpdatedPlanet] = []
                var majorOrder: MajorOrder? = nil
                DispatchQueue.main.async {
                    if let firstOrder = decodedResponse.first {
                        
                        print("first order title is: \(firstOrder.setting.taskDescription)")
                        
                        majorOrder = firstOrder
                        
                        withAnimation(.bouncy) {
                            self?.majorOrder = majorOrder
                        }
                        
                        var collectionOfPlanets: [UpdatedPlanet] = []
                        
                        // if passed planets (widgets), set collection to be those
                        if let planets = planets {
                            collectionOfPlanets = planets
                        } else if let planets = self?.updatedPlanets {
                            // otherwise they are the viewmodel's planets
                            collectionOfPlanets = planets
                        }
                        
                        // get planets with planet index found in task, assuming the tasks are in the same order as the progress array also associate the progress (0 or 1 for complete) with the planet in the tasks array
                        
                        let taskPlanetIndexes = firstOrder.setting.tasks.compactMap { task in
                            task.values.count >= 3 ? task.values[2] : nil
                        }
                        
                        taskPlanets = collectionOfPlanets.filter { planet in
                            taskPlanetIndexes.contains(planet.index)
                        }
                        
                        for (index, progressValue) in firstOrder.progress.enumerated() {
                            if index < firstOrder.setting.tasks.count {
                                let task = firstOrder.setting.tasks[index]
                                if let taskIndex = task.values.count >= 3 ? task.values[2] : nil,
                                   let planetIndex = taskPlanets.firstIndex(where: { $0.index == taskIndex }) {
                                    taskPlanets[planetIndex].taskProgress = progressValue
                                }
                            }
                        }
                        
                        
                        
                        
                        self?.updatedTaskPlanets = taskPlanets
                        
                        
                        print("We set the major order")
                    } else {
                        self?.majorOrder = nil
                    }
                    
                    completion(taskPlanets, majorOrder)
                    
                }
                
                
            } catch {
                print("Decoding error: \(error)")
                completion([], nil)
            }
            
            
            print("yeet")
            
        }.resume()
        
        print("woohoo")
        
        
    }
    
    func refresh() {
        // fetchCurrentWarSeason() { [weak self] _ in
        self.fetchConfig { [weak self] _ in
            print("fetched config")
            
            self?.fetchUpdatedGalaxyStats {
                print("fetched galaxy stats")
            }
            
            self?.fetchUpdatedCampaigns { campaigns, _ in
                
                // for first call set default selected planet for map view
                
                // set default selected planet for map, grab first planet in campaigns
                self?.selectedPlanet = campaigns.first?.planet
                
            }
            
            self?.fetchUpdatedPlanets { _ in
                
                self?.fetchMajorOrder { _, _ in
                    print("fetched major order")
                }// fetching in here so planets is populated to associate major order planets with tasks
                
            }
            
            self?.fetchPlanetStatuses { planets in
                
            }
            self?.fetchPlanetStatusTimeSeries { error in
                if let error = error {
                    print("Error updating planet status time series: \(error)")
                }
            }
        }
        
        
        
        
        
        
        // }
    }
    
    
    
    // setup the timer to fetch the data every few seconds or so
    func startUpdating() {
        
        timer?.invalidate()
        
        cacheTimer?.invalidate()
        
        refresh()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            
            // fetch planet data
            
            // only update if the current tab is not the game, bit of a duct tape fix for now but should stop fetching while playing stratagem hero etc
            if self?.currentTab != .game {
                
                
                self?.fetchConfig { _ in
                    print("fetched config")
                    
                    self?.fetchUpdatedCampaigns { _, _ in
                        
                    }
                    
                    
                    self?.fetchUpdatedPlanets { planets in
                        
                        print("fetched \(planets.count) planets from new api")
                        
                        self?.lastUpdatedDate = Date()
                        
                        
                        self?.fetchMajorOrder { _, _ in
                            
                            print("fetched major order")
                            
                        } // fetching in here so planets is populated to associate major order planets with tasks
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    self?.fetchPlanetStatuses { planets in
                        print("Updated planets: \(planets)")
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
        // fetch cache every 5 min (although it is only updated every 10...)
        cacheTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            
            
            self?.fetchPlanetStatusTimeSeries { error in
                if let error = error {
                    print("Error updating planet status time series: \(error)")
                }
            }
            
            self?.fetchUpdatedGalaxyStats {
                
            }
            
            
            
            
        }
        
        
    }
    // update bug rates via github json file so the app doesnt need an update every change, or an alert string to present in the about page to update remotely
    func fetchConfig(completion: @escaping (RemoteConfigDetails?) -> Void) {
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/config/newApiConfig.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(RemoteConfigDetails.self, from: data) {
                    DispatchQueue.main.async {
                        self.configData = decodedResponse
                        completion(decodedResponse)
                    }
                }
            } else {
                completion(nil)
            }
            
            
            
        }.resume()
    }
    
    func isActive(planetStatus: PlanetStatus) -> Bool {
        // only show with more than 1000 planets and a liberation status less than 100%
        return planetStatus.players > 1000 && planetStatus.liberation < 100
    }
    
    // optional, because if we cant reach this endpoint then we dont want to overwrite the fetched planet statuses with nothing when we call this
    func fetchPlanetDetailsAndUpdateStatuses(for planetStatuses: [PlanetStatus], completion: @escaping ([PlanetStatus]?) -> Void) {
        // helldivers 2 training manual api additional planet info is called in a github action, and cached there. if it ever goes down, at least we have this static info that we could update manually if it came to it.
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/planets/additionalPlanetInfo.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let planetDetailsDictionary = try decoder.decode([String: PlanetAdditionalInfo].self, from: data)
                
                for planetDetail in planetDetailsDictionary {
                    print("when decoding, \(planetDetail.key) has: \(planetDetail.value.environmentals)")
                }
                
                DispatchQueue.main.async {
                    
                    let updatedWithAdditionalInfoPlanetStatuses = self?.updatePlanetStatusesWithAdditionalInfo(planetStatuses, with: planetDetailsDictionary)
                    
                    print("Decoding success for training manual api!")
                    completion(updatedWithAdditionalInfoPlanetStatuses)
                }
            } catch {
                print("Decoding failed: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchPlanetDetailsAndUpdatePlanets(for planets: [UpdatedPlanet], completion: @escaping ([UpdatedPlanet]?) -> Void) {
        // helldivers 2 training manual api additional planet info is called in a github action, and cached there. if it ever goes down, at least we have this static info that we could update manually if it came to it.
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/planets/additionalPlanetInfo.json"
        
        // failures result in planet array simply passed back with no changes
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(planets)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(planets)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let planetDetailsDictionary = try decoder.decode([String: PlanetAdditionalInfo].self, from: data)
                
                for planetDetail in planetDetailsDictionary {
                    print("when decoding, \(planetDetail.key) has: \(planetDetail.value.environmentals)")
                }
                
                DispatchQueue.main.async {
                    
                    let updatedWithAdditionalInfoPlanets = self?.updatePlanetsWithAdditionalInfo(planets, with: planetDetailsDictionary)
                    
                    print("Decoding success for training manual api!")
                    completion(updatedWithAdditionalInfoPlanets)
                }
            } catch {
                print("Decoding failed: \(error)")
                completion(planets)
            }
        }.resume()
        
        
        
        
    }
    
    private func updatePlanetsWithAdditionalInfo(_ planets: [UpdatedPlanet]?, with planetDetails: [String: PlanetAdditionalInfo]) -> [UpdatedPlanet] {
        guard let planets = planets else { return [] }
        
        print("additional info got called")
        return planets.map { planet in
            var updatedPlanet = planet
            
            // find planet details by matching name
            if let planetDetail = planetDetails.values.first(where: { $0.name.lowercased() == planet.name.lowercased() }) {
                print("current planet: \(updatedPlanet.name) and enviros are: \(planetDetail.environmentals)")
                updatedPlanet.environmentals = planetDetail.environmentals
                updatedPlanet.biome = planetDetail.biome
                updatedPlanet.sector = planetDetail.sector
            }
            return updatedPlanet
        }
        
    }
    
    // adds additional info to planet status' planets from training manual api
    private func updatePlanetStatusesWithAdditionalInfo(_ statuses: [PlanetStatus]?, with planetDetails: [String: PlanetAdditionalInfo]) -> [PlanetStatus] {
        guard let statuses = statuses else { return [] }
        
        
        print("additional info got called")
        return statuses.map { status in
            var updatedStatus = status
            
            // find planet details by matching name
            if let planetDetail = planetDetails.values.first(where: { $0.name.lowercased() == status.planet.name.lowercased() }) {
                print("current planet: \(updatedStatus.planet.name) and enviros are: \(planetDetail.environmentals)")
                updatedStatus.planet.environmentals = planetDetail.environmentals
                updatedStatus.planet.biome = planetDetail.biome
                updatedStatus.planet.sector = planetDetail.sector
            }
            return updatedStatus
        }
    }
    
    
    
    
    // returns campaign planets, planet events, and all planet statuses (for widgets to use etc)
    func fetchPlanetStatuses(using url: String? = nil, for season: String? = nil, completion: @escaping (([PlanetStatus], [PlanetEvent], [PlanetStatus], WarStatusResponse?)) -> Void) {
        
        // this function should be adapted for use both in the caching one or the live one below
        
        var urlString = "\(configData.apiAddress)/\(season ?? configData.season)/status"
        
        // override url with provided url, must be a widget requesting data from the github cache instead
        if let url = url {
            urlString = url
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url){ [weak self] data, response, error in
            
            guard let data = data else {
                completion(([], [], [], nil))
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode(WarStatusResponse.self, from: data)
                
                
                self?.fetchPlanetDetailsAndUpdateStatuses(for: decodedResponse.planetStatus) { updatedPlanetStatuses in
                    // update planet statuses with additional info from training manual api if possible
                    if let updatedStatuses = updatedPlanetStatuses {
                        decodedResponse.planetStatus = updatedStatuses
                    }
                    
                    self?.fetchExpirationTimes { defenseExpirations in
                        
                        // update owner to race variable in planet events, duct tape fixing mantes for example for now
                        // also update expiration time with value from helldivers training api
                        for i in 0..<decodedResponse.planetEvents.count {
                            if let index = decodedResponse.planetStatus.firstIndex(where: { $0.planet.index == decodedResponse.planetEvents[i].planet.index }) {
                                decodedResponse.planetStatus[index].owner = decodedResponse.planetEvents[i].race
                                decodedResponse.planetEvents[i].planetStatus = decodedResponse.planetStatus[index]
                            }
                            
                        }
                        
                        for i in 0..<decodedResponse.planetEvents.count {
                            let eventIndex = decodedResponse.planetEvents[i].planet.index
                            print("index of planet is: \(eventIndex), name is \(decodedResponse.planetEvents[i].planet.name)")
                            if let matchingStatus = decodedResponse.planetStatus.first(where: { $0.planet.index == eventIndex }) {
                                decodedResponse.planetEvents[i].planetStatus = matchingStatus
                                print("found matching planet index")
                            }
                            
                            // add defense expirations
                            
                            if let expiration = defenseExpirations.first(where: { $0.planetIndex == eventIndex }) {
                                if let expireTime = expiration.expireDateTime {
                                    let expireDate = Date(timeIntervalSince1970: expireTime)
                                    decodedResponse.planetEvents[i].expireTimeDate = expireDate
                                }
                            }
                            
                        }
                        // now add the statistics for each planet, if they exist
                        self?.fetchGalaxyStats(for: decodedResponse.planetStatus) { galaxyUpdatedStatuses in
                            
                            
                            
                            print("fetchGalaxyStats is called")
                            
                            if let galaxyUpdatedStatuses = galaxyUpdatedStatuses {
                                decodedResponse.planetStatus = galaxyUpdatedStatuses
                            }
                            // should i wrap the rest with this new func?
                            
                            let campaignPlanetsWithStatus = decodedResponse.campaigns.compactMap { campaignPlanet in
                                decodedResponse.planetStatus.first { $0.planet.index == campaignPlanet.planet.index }
                            }
                            
                            for planet in campaignPlanetsWithStatus {
                                print("\(planet.planet.name) has enviros: \(planet.planet.environmentals)")
                            }
                            
                            
                            
                            let sortedCampaignPlanets = campaignPlanetsWithStatus.sorted { firstPlanetStatus, secondPlanetStatus in
                                let isFirstPlanetInEvent = decodedResponse.planetEvents.contains { $0.planet.index == firstPlanetStatus.planet.index }
                                let isSecondPlanetInEvent = decodedResponse.planetEvents.contains { $0.planet.index == secondPlanetStatus.planet.index }
                                
                                if isFirstPlanetInEvent && !isSecondPlanetInEvent {
                                    return true
                                } else if !isFirstPlanetInEvent && isSecondPlanetInEvent {
                                    return false
                                } else {
                                    return firstPlanetStatus.players > secondPlanetStatus.players
                                }
                            }
                            
                            // group planet statuses by sector
                            var groupedBySector = Dictionary(grouping: decodedResponse.planetStatus) { $0.planet.sector }
                            
                            // sort alphabetically by sector
                            let sortedSectors = groupedBySector.keys.sorted()
                            
                            
                            DispatchQueue.main.async {
                                
                                self?.defensePlanets = decodedResponse.planetEvents
                                
                                self?.groupedBySectorPlanetStatuses = groupedBySector
                                self?.sortedSectors = sortedSectors
                                self?.allPlanetStatuses = decodedResponse.planetStatus
                                self?.warStatusResponse = decodedResponse
                                withAnimation(.bouncy) {
                                    self?.campaignPlanets = sortedCampaignPlanets
                                }
                                print("fetchPlanetStatuses: All updates done, calling completion")
                                completion((campaignPlanetsWithStatus, decodedResponse.planetEvents, decodedResponse.planetStatus, decodedResponse))
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                }
                
                
            } catch {
                print("Decoding error: \(error)")
                completion(([], [], [], nil))
            }
            
            
            
            
        }.resume()
        
        
    }
    
    // gets defense expiration times from a cache from helldiverstrainingmanual api
    func fetchExpirationTimes(completion: @escaping ([PlanetExpiration]) -> Void) {
        
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/planets/campaignInfo.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode([PlanetExpiration].self, from: data)
                completion(decodedResponse)
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
        
        
    }
    
    // fetches statistics for the galaxy and individual planets
    func fetchGalaxyStats(for planetStatuses: [PlanetStatus], completion: @escaping ([PlanetStatus]?) -> Void) {
        
        print("fetch galaxy stats called!")
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/planets/galaxyStatistics.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            print("fetchGalaxyStats: Network request completed")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            
            print("fetchGalaxyStats: Received data, starting decoding")
            
            do {
                
                let decodedResponse = try decoder.decode(GalaxyStatsResponseData.self, from: data)
                
                DispatchQueue.main.async {
                    
                    //  self?.galaxyStats = decodedResponse.galaxyStats
                    
                    // now must link all stats into each planetstatus.stats variable
                    // planets can be matched by their index, planetstatus has index as string and json response is an INT!
                    
                    let updatedPlanetStatuses = self?.updatePlanetStatusesWithGalaxyStats(planetStatuses, with: decodedResponse.planetsStats)
                    
                    print("fetchGalaxyStats: Updating UI and calling completion")
                    completion(updatedPlanetStatuses)
                    
                }
                print("fetchGalaxyStats: Decoding successful")
                
                
            } catch {
                print("fetchGalaxyStats: Decoding failed: \(error)")
                completion(nil)
            }
            
            
        }.resume()
        
        
    }
    
    
    private func updatePlanetStatusesWithGalaxyStats(_ statuses: [PlanetStatus]?, with planetStats: [PlanetStats]) -> [PlanetStatus] {
        print("yeet")
        guard let statuses = statuses else {
            
            print("statuses were nil dawg")
            
            return [] }
        
        print("update with galaxy stats called")
        return statuses.compactMap { status in
            var updatedStatus = status
            print("updatePlanetStatusesWithGalaxyStats: Updating status for \(status.planet.name)")
            
            print("planet status index is: \(status.planet.index)")
            
            for stat in planetStats {
                print("planet status indexes are: \(stat.planetIndex)")
            }
            
            // find corresponding planet stats by matching index
            if let planetStat = planetStats.first(where: { $0.planetIndex == Int(updatedStatus.planet.index) }) {
                print("current planet: \(updatedStatus.planet.name) and bug kills are: \(planetStat.bugKills)")
                updatedStatus.planet.stats = planetStat // associate stats w planet status planet stats variable
            }
            
            return updatedStatus
        }
    }
    
    // completion gives both campaigns and campaigns with an event
    func fetchUpdatedCampaigns(using url: String? = nil, completion: @escaping ([UpdatedCampaign], [UpdatedCampaign]) -> Void) {
        
        var urlString = "\(configData.apiAddress)campaigns"
        
        // override url with provided url, must be a widget requesting data from the github cache instead
        if let url = url {
            urlString = url
        }
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("WarMonitoriOS/2.1", forHTTPHeaderField: "User-Agent")
        request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Application-Contact")
        
        
        URLSession.shared.dataTask(with: request){ [weak self] data, response, error in
            
            guard let data = data else {
                completion([], [])
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode([UpdatedCampaign].self, from: data)
                
                self?.fetchPlanetDetailsAndUpdatePlanets(for: decodedResponse.map { $0.planet }) { updatedPlanets in
                    
                    // use updated planets if available, otherwise use original planets without additional info added
                    let finalPlanets = updatedPlanets ?? decodedResponse.map { $0.planet }
                    
                    // update campaigns with the updated planets with additional info
                    let updatedCampaigns = decodedResponse.map { campaign -> UpdatedCampaign in
                        var updatedCampaign = campaign
                        if let updatedPlanet = finalPlanets.first(where: { $0.name == campaign.planet.name }) {
                            updatedCampaign.planet = updatedPlanet
                        }
                        return updatedCampaign
                    }
                    
                    let sortedCampaigns = updatedCampaigns.sorted { firstCampaign, secondCampaign in
                        if firstCampaign.planet.event != nil && secondCampaign.planet.event == nil {
                            return true
                        } else if firstCampaign.planet.event == nil && secondCampaign.planet.event != nil {
                            return false
                        } else {
                            return firstCampaign.planet.statistics.playerCount > secondCampaign.planet.statistics.playerCount
                        }
                    }
                    
                    let defenseCampaigns = sortedCampaigns.filter { $0.planet.event != nil }
                    
                    DispatchQueue.main.async {
                        self?.updatedCampaigns = sortedCampaigns
                        self?.updatedDefenseCampaigns = defenseCampaigns
                        completion(sortedCampaigns, defenseCampaigns)
                    }
                }
                
                
                
            } catch {
                print("Decoding error: \(error)")
                completion([], [])
            }
            
            
            
        }.resume()
        
        
        
    }
    
    func fetchUpdatedPlanets(using url: String? = nil, completion: @escaping ([UpdatedPlanet]) -> Void) {
        
        var urlString = "\(configData.apiAddress)planets"
        
        // override url with provided url, must be a widget requesting data from the github cache instead
        if let url = url {
            urlString = url
        }
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("WarMonitoriOS/2.1", forHTTPHeaderField: "User-Agent")
        request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Application-Contact")
        
        URLSession.shared.dataTask(with: request){ [weak self] data, response, error in
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                       completion([])
                       return
                   }

                   if httpResponse.statusCode == 429 {
                       if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                          let retryAfterSeconds = Double(retryAfter) {
                           print("retry after seconds is: \(retryAfterSeconds)")
                           // retry after specified number of seconds in the response header
                           DispatchQueue.global().asyncAfter(deadline: .now() + retryAfterSeconds) {
                               self?.fetchUpdatedPlanets(completion: completion)
                           }
                           return
                       }
                   }
            
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode([UpdatedPlanet].self, from: data)
                
                
                
                self?.fetchPlanetDetailsAndUpdatePlanets(for: decodedResponse) { updatedPlanets in
                    // update planet statuses with additional info from training manual api if possible
                    if let updatedPlanets = updatedPlanets {
                        decodedResponse = updatedPlanets
                    }
                    
                    // group planets by sector
                    let groupedBySector = Dictionary(grouping: decodedResponse) { $0.sector }
                    
                    // sort alphabetically by sector
                    let sortedSectors = groupedBySector.keys.sorted()
                    
                    DispatchQueue.main.async {
                        
                        self?.updatedPlanets = decodedResponse
                        self?.updatedSortedSectors = sortedSectors
                        self?.updatedGroupedBySectorPlanets = groupedBySector
                        
                        completion(decodedResponse)
                    }
                    
                }
                
                
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
            
            
            
        }.resume()
        
        
    }
    
    
    func fetchUpdatedGalaxyStats(completion: @escaping () -> Void) {
        
        print("fetch galaxy stats called!")
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/planets/galaxyStatistics.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            
            print("fetchGalaxyStats: Network request completed")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            
            print("fetchGalaxyStats: Received data, starting decoding")
            
            do {
                
                let decodedResponse = try decoder.decode(GalaxyStatsResponseData.self, from: data)
                
                DispatchQueue.main.async {
                    
                    self?.galaxyStats = decodedResponse.galaxyStats
                    completion()
                }
                
                
                
                
            } catch {
                print("Decoding error: \(error)")
                completion()
            }
            
        }.resume()
        
    }
    
    
    func eventExpirationDate(from endTimeString: String?) -> Date? {
            guard let endTimeString = endTimeString else { return nil }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: endTimeString)
        }
    
    
}

enum Tab: String, CaseIterable {
    case home = "War"
    case news = "News"
    case game = "Game"
    case about = "About"
    case orders = "Orders"
    case stats = "Stats"
    case map = "Map"
    case tipJar = "Tip Jar"
    
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




