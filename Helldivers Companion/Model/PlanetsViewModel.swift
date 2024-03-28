//
//  PlanetsViewModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation
import SwiftUI

class PlanetsViewModel: ObservableObject {
    
    @Published var currentTab: Tab = .home
    
    @Published var allPlanetStatuses: [PlanetStatus] = []
    @Published var defensePlanets: [PlanetEvent] = []
    @Published var campaignPlanets: [PlanetStatus] = []
    @Published var currentSeason: String = ""
    @Published var majorOrder: MajorOrder? = nil
    @Published var lastUpdatedDate: Date = Date()
    // planetstatuses with tasks in the major order (e.g need to be liberated)
    @Published var taskPlanets: [PlanetStatus] = []
    
    @AppStorage("viewCount") var viewCount = 0
    
    private var apiToken: String? = ProcessInfo.processInfo.environment["GITHUB_API_KEY"]
    
    @Published var configData: RemoteConfigDetails = RemoteConfigDetails(terminidRate: "-5%", automatonRate: "-1.5%", alert: "", prominentAlert: nil, season: "801")
    
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
                    
                    let previousDataPoint = planetHistory[planetName]?.last
                    var currentDataPoint = PlanetDataPoint(timestamp: fileTimestamp, status: status)
                    
                    // override the liberation with a defense percentage if defending
                                   if let defensePercentage = defensePercentages[planetName] {
                                       currentDataPoint.status?.liberation = defensePercentage
                                   }

                    if let previous = previousDataPoint {
                            let timeInterval = currentDataPoint.timestamp.timeIntervalSince(previous.timestamp) / 3600
                            if timeInterval > 0 {
                                let currentLiberation = currentDataPoint.status?.liberation ?? 0
                                let previousLiberation = previous.status?.liberation ?? 0
                                let liberationRate = (currentLiberation - previousLiberation) / timeInterval
                                currentDataPoint.liberationRate = liberationRate
                            }
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
    
    
    
    
  /*  func fetchCurrentWarSeason(completion: @escaping (String) -> Void) {
        
        let urlString = apiAddress
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let data = data {
                
                do {
                    
                    let decodedResponse = try JSONDecoder().decode(WarSeason.self, from: data)
                    DispatchQueue.main.async {
                        self?.currentSeason = decodedResponse.current
                        completion(decodedResponse.current)
                    }
                    
                } catch {
                    print("Decoding error: \(error)")
                }
                
                
            }
            
            
            
        }.resume()
        
        
    }*/
    // optionally passed season and planet statuses if calling from widget
    func fetchMajorOrder(for season: String? = nil, with planetStatuses: [PlanetStatus]? = nil, completion: @escaping ([PlanetStatus], MajorOrder?) -> Void) {
        
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
                    
                    var taskPlanets: [PlanetStatus] = []
                    var majorOrder: MajorOrder? = nil
                    DispatchQueue.main.async {
                                    if let firstOrder = decodedResponse.first {
                                        
                                        print("first order title is: \(firstOrder.setting.taskDescription)")
                                        
                                        majorOrder = firstOrder
                                        
                                        withAnimation(.bouncy) {
                                            self?.majorOrder = majorOrder
                                        }
                                        
                                        var collectionOfPlanetStatuses: [PlanetStatus] = []
                                        
                                        // if passed planet statuses (widgets), set collection to be those
                                        if let planetStatuses = planetStatuses {
                                            collectionOfPlanetStatuses = planetStatuses
                                        } else if let planetStatuses = self?.allPlanetStatuses {
                                            // otherwise they are the viewmodel's planet statuses
                                            collectionOfPlanetStatuses = planetStatuses
                                        }
                                        
                                        let taskPlanetIndexes = firstOrder.setting.tasks.compactMap { task in
                                                task.values.count >= 3 ? task.values[2] : nil
                                            }
                                        
                                        taskPlanets = collectionOfPlanetStatuses.filter { planetStatus in
                                            taskPlanetIndexes.contains(planetStatus.planet.index)
                                        }
                                        
                                        self?.taskPlanets = taskPlanets
                                        
                                        
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
    
    // returns campaign planets, planet events, and all planet statuses (for widgets to use etc)
    func fetchPlanetStatuses(using url: String? = nil, for season: String? = nil, completion: @escaping (([PlanetStatus], [PlanetEvent], [PlanetStatus])) -> Void) {
        
        // this function should be adapted for use both in the caching one or the live one below
        
        var urlString = "\(apiAddress)/\(season ?? configData.season)/status"
        
        // override url with provided url, must be a widget requesting data from the github cache instead
        if let url = url {
            urlString = url
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url){ [weak self] data, response, error in
            
            guard let data = data else {
                completion(([], [], []))
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode(WarStatusResponse.self, from: data)
                DispatchQueue.main.async {
                    
                    // update owner to race variable in planet events, duct tape fixing mantes for example for now
                    for i in 0..<decodedResponse.planetEvents.count {
                        if let index = decodedResponse.planetStatus.firstIndex(where: { $0.planet.index == decodedResponse.planetEvents[i].planet.index }) {
                            decodedResponse.planetStatus[index].owner = decodedResponse.planetEvents[i].race
                            decodedResponse.planetEvents[i].planetStatus = decodedResponse.planetStatus[index]
                        }
                    }

                // campaign planets with status updated array
                    let campaignPlanetsWithStatus = decodedResponse.campaigns.compactMap { campaignPlanet in
                        decodedResponse.planetStatus.first { $0.planet.index == campaignPlanet.planet.index }
                    }


                    
                    for i in 0..<decodedResponse.planetEvents.count {
                                        let eventIndex = decodedResponse.planetEvents[i].planet.index
                        print("index of planet is: \(eventIndex), name is \(decodedResponse.planetEvents[i].planet.name)")
                        if let matchingStatus = decodedResponse.planetStatus.first(where: { $0.planet.index == eventIndex }) {
                                            decodedResponse.planetEvents[i].planetStatus = matchingStatus
                                            print("found matching planet index")
                                        }
                                    }
                    
            
                    
                    self?.defensePlanets = decodedResponse.planetEvents
                    self?.allPlanetStatuses = decodedResponse.planetStatus
                    withAnimation(.bouncy) {
                        self?.campaignPlanets = campaignPlanetsWithStatus.sorted { firstPlanetStatus, secondPlanetStatus in
                            // prioritise planets in an event first, then by highest player count
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


                    }

                    completion((campaignPlanetsWithStatus, decodedResponse.planetEvents, decodedResponse.planetStatus))
                }
                
            } catch {
                print("Decoding error: \(error)")
                completion(([], [], []))
            }
            
            
            
            
        }.resume()
        
        
    }
    
    func refresh() {
       // fetchCurrentWarSeason() { [weak self] _ in
        self.fetchConfig { [weak self] _ in
            print("fetched config")
            
            self?.fetchPlanetStatuses { planets in
                self?.fetchMajorOrder { _, _ in
                    print("fetched major order")
                }// fetching in here so planet status is populated to associate major order planets with tasks
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            
            // fetch planet data
            
            // only update if the current tab is home, bit of a duct tape fix for now but should stop fetching while playing stratagem hero etc
            if self?.currentTab == .home {
                
                
                self?.fetchConfig { _ in
                    print("fetched config")
                    
                    
                    self?.fetchPlanetStatuses { planets in
                        self?.lastUpdatedDate = Date()
                        
                        self?.fetchMajorOrder { _, _ in
                            
                            print("fetched major order")
                            
                        } // fetching in here so planet status is populated to associate major order planets with tasks
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
            
            
        }
        
        
    }
    // update bug rates via github json file so the app doesnt need an update every change, or an alert string to present in the about page to update remotely
    func fetchConfig(completion: @escaping (RemoteConfigDetails?) -> Void) {
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/config/newConfig.json"
        
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
    
}

enum Tab: String, CaseIterable {
    case home = "War"
    case news = "News"
    case game = "Game"
    case about = "About"
    case orders = "Orders"
    case stats = "Stats"
    
    var systemImage: String? {
        switch self {
        case .home:
            return "globe.americas.fill"
        case .game:
            return "scope"
        case .news:
            return "newspaper.fill"
        case .about:
            return "info.circle.fill"
        case .orders:
            return "target"
        case .stats:
            return "stats"
        }
    }
}
