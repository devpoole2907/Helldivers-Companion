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
    @Published var updatedPlanetHistory: [String: [UpdatedPlanetDataPoint]] = [:]
    @Published var nextFetchTime: Date? // for the ui to show count down if a fetch failed due to rate limiting
    @Published var hasSetSelectedPlanet: Bool = false // to stop setting the selected planet to the first in campaigns every fetch after the first
    
    @Published var currentTab: Tab = .home
    
    @Published var currentSeason: String = ""
    @Published var majorOrder: MajorOrder? = nil
    @Published var galaxyStats: GalaxyStats? = nil
    @Published var lastUpdatedDate: Date = Date()
    
    @Published var selectedPlanet: UpdatedPlanet? = nil // for map view selection
    
    @AppStorage("viewCount") var viewCount = 0
    
    @AppStorage("enableLocalization") var enableLocalization = true
    @AppStorage("darkMode") var darkMode = false
    
    private var apiToken: String? = ProcessInfo.processInfo.environment["GITHUB_API_KEY"]
    
    
    // TODO: MAKE FETCH FOR STARTEDAT DYNAMIC FROM API NOT STATIC
    @Published var configData: RemoteConfigDetails = RemoteConfigDetails(alert: "", prominentAlert: nil, season: "801", showIlluminate: false, apiAddress: "", startedAt: "2024-02-10T07:20:30.089979Z")
    
    @Published var showInfo = false
    @Published var showOrders = false
    
    //var apiAddress = "http://127.0.0.1:4000/api"
    var apiAddress = "https://helldivers-2.fly.dev/api"
    
    private var timer: Timer?
    private var cacheTimer: Timer?


    
    
    
    var totalPlayerCount: Int64 {
        updatedPlanets.reduce(0) { $0 + $1.statistics.playerCount }
    }
    
    var formattedPlayerCount: String {
        formatNumber(totalPlayerCount)
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
        
        if planet.currentOwner == "Humans" {
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
    
    func currentLiberationRate(for planetName: String) -> Double? {
        guard let dataPoints = updatedPlanetHistory[planetName], dataPoints.count >= 3 else {
            return nil
        }
        
        // get the second and third last data points, latest ones are wrong need to be fixed somethings incorrect somewhere
        let secondLastPoint = dataPoints[dataPoints.count - 3]
        let thirdLastPoint = dataPoints[dataPoints.count - 2]
        
  
        let timeInterval = thirdLastPoint.timestamp.timeIntervalSince(secondLastPoint.timestamp) / 3600
        if timeInterval <= 0 {
            return nil
        }
        
        let secondLastPercentage = self.updatedDefenseCampaigns.contains(where: { $0.planet == secondLastPoint.planet }) ?
            secondLastPoint.planet?.event?.percentage : secondLastPoint.planet?.percentage
        let thirdLastPercentage = self.updatedDefenseCampaigns.contains(where: { $0.planet == thirdLastPoint.planet }) ?
            thirdLastPoint.planet?.event?.percentage : thirdLastPoint.planet?.percentage
        
        guard let lastLiberation = thirdLastPercentage, let previousLiberation = secondLastPercentage else {
            return nil
        }
        
        let rate = (lastLiberation - previousLiberation) / timeInterval
        
        return rate
    }

    
    func averageLiberationRate(for planetName: String) -> Double? {
        guard let dataPoints = updatedPlanetHistory[planetName] else {
            return nil
        }
        
        // exclude 100 because 100 will only show if a planet has become part of a recent event
        let filteredDataPoints = dataPoints.filter { dataPoint in
            let percentage = self.updatedDefenseCampaigns.contains(where: { $0.planet == dataPoint.planet }) ?
            dataPoint.planet?.event?.percentage : dataPoint.planet?.percentage
            return percentage != 100.0
        }
        
        // must be at least 2 data points
        guard filteredDataPoints.count >= 2 else {
            return nil
        }
        
        var totalRate: Double = 0
        var count: Double = 0
        
        for i in 1..<filteredDataPoints.count {
            let timeInterval = filteredDataPoints[i].timestamp.timeIntervalSince(filteredDataPoints[i - 1].timestamp) / 3600
            if timeInterval > 0 {
                let currentPercentage = self.updatedDefenseCampaigns.contains(where: { $0.planet == filteredDataPoints[i].planet }) ?
                filteredDataPoints[i].planet?.event?.percentage : filteredDataPoints[i].planet?.percentage
                let previousPercentage = self.updatedDefenseCampaigns.contains(where: { $0.planet == filteredDataPoints[i - 1].planet }) ?
                filteredDataPoints[i - 1].planet?.event?.percentage : filteredDataPoints[i - 1].planet?.percentage
                
                if let lastLiberation = currentPercentage, let previousLiberation = previousPercentage {
                    let rate = (lastLiberation - previousLiberation) / timeInterval
                    totalRate += rate
                    count += 1
                }
            }
        }
        
        // average liberation rate calculation
        let averageRate = count > 0 ? totalRate / count : nil
        
        print("THE LAST PERCENT IN HISTORY IS \(dataPoints.last?.planet?.percentage)")
        
        return averageRate
    }
    
    
    
    
    
    
    func fetchUpdatedPlanetTimeSeries(completion: @escaping ([String: [UpdatedPlanetDataPoint]]) -> Void) {
        
        Task {
            do {
                var history = try await fetchUpdatedCachedPlanetData()
                
                var localHistory = history
                
                DispatchQueue.main.async {
                    //       self.updatedPlanetHistory = localHistory
                    completion(localHistory)
                }
            } catch {
                print("Error fetching planet status time series: \(error)")
                completion([:])
            }
        }
        
        
        
    }
    
    func fetchUpdatedCachedPlanetData() async throws -> [String: [UpdatedPlanetDataPoint]] {
        let apiURLString = "https://api.github.com/repos/devpoole2907/helldivers-api-cache/contents/newData"
        guard let apiURL = URL(string: apiURLString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        if let apiToken = apiToken {
            request.addValue("token \(apiToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (apiData, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let files = try decoder.decode([GitHubFile].self, from: apiData)
        
        let manager = PlanetHistoryManager()
        
        print("Fetched files count: \(files.count)")

        // async let to fetch and decode files in parallel
        await withTaskGroup(of: Void.self) { group in
            for file in files {
                group.addTask {
                    do {
                        print("Processing file: \(file.name)")
                        guard let fileURL = URL(string: file.downloadUrl) else { return }
                        let (fileData, _) = try await URLSession.shared.data(from: fileURL)
                        let decodedResponse = try decoder.decode([UpdatedPlanet].self, from: fileData)
                        
                        for planet in decodedResponse {
                            let fileTimestamp = self.extractTimestamp(from: file.name)
                            let dataPoint = UpdatedPlanetDataPoint(timestamp: fileTimestamp, planet: planet)
                            await manager.append(planet: planet.name, dataPoint: dataPoint)
                        }
                    } catch {
                        print("Error decoding data for file \(file.name): \(error)")
                    }
                }
            }
        }
        
        // retrieve + sort the planet history
        var finalHistory = await manager.getHistory()
        for key in finalHistory.keys {
            finalHistory[key]?.sort(by: { $0.timestamp < $1.timestamp })
        }
        
        return finalHistory
    }

    
    func extractTimestamp(from filename: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let endOfTimestampIndex = filename.firstIndex(of: "_") ?? filename.endIndex
        let timestampString = String(filename.prefix(upTo: endOfTimestampIndex))
        return dateFormatter.date(from: timestampString) ?? Date()
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
        if enableLocalization {
            request.addValue(apiSupportedLanguage, forHTTPHeaderField: "Accept-Language")
        }
      
        
        URLSession.shared.dataTask(with: request){ [weak self] data, response, error in
            
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion([], [])
                return
            }
            
            if httpResponse.statusCode == 429 {
                if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                   let retryAfterSeconds = Double(retryAfter) {
                    let retryDate = Date().addingTimeInterval(retryAfterSeconds + 10) // add 10 extra seconds to be safe
                    print("retry after seconds is: \(retryAfterSeconds)")
                    
                    DispatchQueue.main.async {
                        self?.nextFetchTime = retryDate
                    }
                    
                    // retry after specified number of seconds in the response header, give an extra 15s to be safe
                    DispatchQueue.global().asyncAfter(deadline: .now() + retryAfterSeconds + 10) {
                        completion([], [])
                        
                        self?.stopUpdating {
                            
                            self?.nextFetchTime = nil
                            
                            self?.startUpdating()
                            
                        }
                        
                        // no longer waiting for fetch
                    }
                    return
                }
            }
            
            guard let data = data else {
                completion([], [])
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode([UpdatedCampaign].self, from: data)
                
                self?.fetchExpirationTimes { expirationTimes in
                    
                    let planetExpirationMap = Dictionary(uniqueKeysWithValues: expirationTimes.map { ($0.planetIndex, $0.expireDateTime) })
                    
                    for index in decodedResponse.indices {
                        if let expirationTime = planetExpirationMap[decodedResponse[index].planet.index] {
                            let expireDate = Date(timeIntervalSince1970: expirationTime ?? 0.0)
                            decodedResponse[index].planet.event?.expireTimeDate = expireDate
                        }
                    }
                    
               
                        
                        // use updated planets if available, otherwise use original planets without additional info added
                        let finalPlanets = decodedResponse.map { $0.planet }
                        
                        for planet in finalPlanets {
                            
                            
                            print("planet current owner is: \(planet.currentOwner)")
                            print("planet regen is: \(planet.regenPerSecond)")
                            
                        }
                        
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
                            
                            self?.objectWillChange.send()
                            
                            self?.lastUpdatedDate = Date()
                            withAnimation(.bouncy) {
                                self?.updatedCampaigns = sortedCampaigns
                                self?.updatedDefenseCampaigns = defenseCampaigns
                            }
                            completion(sortedCampaigns, defenseCampaigns)
                        }
                        
                    
                    
                }
                
                
                
            } catch {
                print("Decoding error: \(error)")
                completion([], [])
            }
            
            
            
        }.resume()
        
        
        
    }
    
    func fetchMajorOrder(for season: String? = nil, with planets: [UpdatedPlanet]? = nil, completion: @escaping ([UpdatedPlanet], MajorOrder?) -> Void) {
        
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/v2/Assignment/War/\(season ?? configData.season)"
        
     //   let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/MOtesting.json"
        
        print("made url")
        guard let url = URL(string: urlString) else { print("mission failed")
            return }
        
        var request = URLRequest(url: url)
     /*   if enableLocalization {
            request.addValue(apiSupportedLanguage, forHTTPHeaderField: "Accept-Language")
        }*/
        
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
                
                // set default selected planet for map, grab first planet in campaigns, only if it hasnt been set already
                if !(self?.hasSetSelectedPlanet ?? false) {
                    
                    self?.selectedPlanet = campaigns.first?.planet
                    self?.hasSetSelectedPlanet = true
                }
                
                self?.fetchUpdatedPlanetTimeSeries { history in
                    DispatchQueue.main.async {
                        self?.updatedPlanetHistory = history
                    }
                }
                
            }
            
            self?.fetchUpdatedPlanets { _ in
                
                self?.fetchMajorOrder { _, _ in
                    print("fetched major order")
                }// fetching in here so planets is populated to associate major order planets with tasks
                
                
                
                
            }
            
            
        }
        
        
        
        
        
        
        // }
    }
    
    
    
    // setup the timer to fetch the data every few seconds or so
    func startUpdating() {
        
        timer?.invalidate()
        
        cacheTimer?.invalidate()
        
        refresh()
        
        timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            
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
                    
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        // fetch cache every 5 min (although it is only updated every 10...)
        cacheTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            
            
            self?.fetchUpdatedPlanetTimeSeries { history in
                self?.updatedPlanetHistory = history
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
    
    // TODO: GET RID OF THIS AND USE ACTUAL DEFENSE TIME REMAINING FROM DEALLOCS NEW API
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
        if enableLocalization {
            request.addValue(apiSupportedLanguage, forHTTPHeaderField: "Accept-Language")
        }
        
        URLSession.shared.dataTask(with: request){ [weak self] data, response, error in
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion([])
                return
            }
            
            /*  if httpResponse.statusCode == 429 {
             if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After"),
             let retryAfterSeconds = Double(retryAfter) {
             let retryDate = Date().addingTimeInterval(retryAfterSeconds + 20) // add 20 extra seconds to be safe
             print("retry after seconds is: \(retryAfterSeconds)")
             
             DispatchQueue.main.async {
             self?.nextFetchTime = retryDate
             }
             
             // retry after specified number of seconds in the response header, give an extra 15s to be safe
             DispatchQueue.global().asyncAfter(deadline: .now() + retryAfterSeconds) {
             completion([])
             
             self?.stopUpdating()
             
             self?.startUpdating()
             
             self?.nextFetchTime = nil // no longer waiting for fetch
             }
             return
             }
             }*/
            
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode([UpdatedPlanet].self, from: data)

                    // group planets by sector
                    let groupedBySector = Dictionary(grouping: decodedResponse) { $0.sector }
                    
                    // sort alphabetically by sector
                    let sortedSectors = groupedBySector.keys.sorted()
                    
                    for planet in decodedResponse {
                        
                        
                        print("planet current owner is: \(planet.currentOwner)")
                        print("planet regen is: \(planet.regenPerSecond)")
                        
                    }
                    
                    
                    DispatchQueue.main.async {
                        
                        self?.objectWillChange.send()
                        withAnimation(.bouncy) {
                            self?.updatedPlanets = decodedResponse
                        }
                        self?.updatedSortedSectors = sortedSectors
                        self?.updatedGroupedBySectorPlanets = groupedBySector
                        
                        
                        
                        completion(decodedResponse)
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
    
    /*
     func eventExpirationDate(from endTimeString: String?) -> Date? {
     guard let endTimeString = endTimeString else { return nil }
     
     let formatter = ISO8601DateFormatter()
     formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
     return formatter.date(from: endTimeString)
     }
     */
    
}

enum Tab: String, CaseIterable {
    case home = "War" /*String(localized: "War")*/
    case news = "News"
    case game = "Hero"
    case about = "About"
    case orders = "Orders"
    case stats = "Stats"
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
