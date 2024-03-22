//
//  PlanetsViewModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation

class PlanetsViewModel: ObservableObject {
    
    @Published var allPlanetStatuses: [PlanetStatus] = []
    @Published var defensePlanets: [PlanetEvent] = []
    @Published var campaignPlanets: [PlanetStatus] = []
    @Published var currentSeason: String = ""
    @Published var majorOrderBody: String = "Awaiting further orders from Super Earth High Command."
    @Published var majorOrderTitle: String = "Stand by."
    @Published var majorOrderRewardType: Int = 1
    @Published var majorOrderRewardValue = 0
    @Published var majorOrderTimeRemaining = 0
    @Published var lastUpdatedDate: Date = Date()
    // planetstatuses with tasks in the major order (e.g need to be liberated)
    @Published var taskPlanets: [PlanetStatus] = []
    
    private var apiToken: String? = ProcessInfo.processInfo.environment["GITHUB_API_KEY"]
    
    @Published var configData: RemoteConfigDetails = RemoteConfigDetails(terminidRate: "-5%", automatonRate: "-1.5%", alert: "", prominentAlert: nil)
    
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
        var eventHistory: [String: [PlanetDataPoint]] = [:]
        
        for file in files {
            guard let fileURL = URL(string: file.downloadUrl) else {
                continue
            }
            
            do {
                let (fileData, response) = try await URLSession.shared.data(from: fileURL)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    continue
                }
                
                var request = URLRequest(url: apiURL)
                request.addValue("token YOUR_PERSONAL_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
                
                
                let decodedResponse = try decoder.decode(WarStatusResponse.self, from: fileData)
                let planetStatuses = decodedResponse.planetStatus
                let planetEvents = decodedResponse.planetEvents
                
                let fileTimestamp = extractTimestamp(from: file.name)
                
                for status in planetStatuses {
                    let planetName = status.planet.name
                    let dataPoint = PlanetDataPoint(timestamp: fileTimestamp, status: status)
                    planetHistory[planetName, default: []].append(dataPoint)
                }
                
                for event in planetEvents {
                    let planetName = event.planet.name
                    
                    
                    if var existingStatuses = planetHistory[planetName] {
                            for i in 0..<existingStatuses.count {
                                if existingStatuses[i].status?.planet.index == event.planet.index {
                                    existingStatuses[i].status?.defensePercentage = event.defensePercentage
                                }
                            }
                            planetHistory[planetName] = existingStatuses
                        }

                    
                    print("planet events health is: \(event.defensePercentage)")
                    let dataPoint = PlanetDataPoint(timestamp: fileTimestamp, event: event)
                    eventHistory[planetName, default: []].append(dataPoint)
                }
                
            } catch {
               // print("Error fetching file data: \(error)")
                continue // skip file, couldve been rated limited
            }
        }
        
        for key in planetHistory.keys {
            planetHistory[key]?.sort(by: { $0.timestamp < $1.timestamp })
        }
        
        for key in eventHistory.keys {
            eventHistory[key]?.sort(by: { $0.timestamp < $1.timestamp })
        }
        
        return (planetHistory, eventHistory)
        
    }
    
    
    func extractTimestamp(from filename: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let endOfTimestampIndex = filename.firstIndex(of: "_") ?? filename.endIndex
        let timestampString = String(filename.prefix(upTo: endOfTimestampIndex))
        return dateFormatter.date(from: timestampString) ?? Date()
    }
    
    
    
    
    func fetchCurrentWarSeason(completion: @escaping (String) -> Void) {
        
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
        
        
    }
    
    func fetchMajorOrder(for season: String? = nil, completion: @escaping ([PlanetStatus]) -> Void) {
        
        
        let urlString = "https://api.live.prod.thehelldiversgame.com/api/v2/Assignment/War/\(currentSeason)"
            print("made url")
        
        print("made url")
        guard let url = URL(string: urlString) else { print("mission failed")
            return }
        
        var request = URLRequest(url: url)
            request.addValue("en", forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let data = data else {
                        print("NOOO! No data received: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                        return
                    }

                
                do {
                    let decoder = JSONDecoder()
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let decodedResponse = try decoder.decode([MajorOrder].self, from: data)
                    
                    var taskPlanets: [PlanetStatus] = []
                    DispatchQueue.main.async {
                                    if let firstOrder = decodedResponse.first {
                                        
                                        print("first order title is: \(firstOrder.setting.taskDescription)")
                                        
                                        self?.majorOrderTitle = firstOrder.setting.taskDescription
                                        self?.majorOrderBody = firstOrder.setting.overrideBrief
                                        self?.majorOrderRewardType = firstOrder.setting.reward.type
                                        self?.majorOrderRewardValue = firstOrder.setting.reward.amount
                                        self?.majorOrderTimeRemaining = firstOrder.expiresIn
                                        
                                        let taskPlanetIndexes = firstOrder.setting.tasks.compactMap { task in
                                                task.values.count >= 3 ? task.values[2] : nil
                                            }
                                        
                                        taskPlanets = self?.allPlanetStatuses.filter { planetStatus in
                                            taskPlanetIndexes.contains(planetStatus.planet.index)
                                        } ?? []
                                        
                                        self?.taskPlanets = taskPlanets
                                        
                                        
                                        print("We set the major order")
                                    } else {
                                        self?.majorOrderTitle = "Stand by."
                                        self?.majorOrderBody = "Await further orders from Super Earth High Command."
                                    }
                        
                        completion(taskPlanets)
                        
                                }
                    
                    
                } catch {
                    print("Decoding error: \(error)")
                    completion([])
                }
           
            
            print("yeet")
            
        }.resume()
        
        print("woohoo")
        
        
    }
    
    
    func fetchPlanetStatuses(for season: String? = nil, completion: @escaping ([PlanetStatus]) -> Void) {
        
        // this function should be adapted for use both in the caching one or the live one below
        
        
        let urlString = "\(apiAddress)/\(season ?? currentSeason)/status"
        
        // for testing
       //   let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/data/2024-03-21T06%3A08%3A52Z_planet_statuses.json"
        
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url){ [weak self] data, response, error in
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var decodedResponse = try decoder.decode(WarStatusResponse.self, from: data)
                DispatchQueue.main.async {
                    
                    // get planets in the active campaigns
                    let campaignPlanets = decodedResponse.campaigns.map { $0 }

                                   // match planets with their campaigns
                                   let campaignPlanetsWithStatus = campaignPlanets.compactMap { campaignPlanet in
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
                    self?.campaignPlanets = campaignPlanetsWithStatus.sorted  { $0.players > $1.players }

                    completion(campaignPlanetsWithStatus)
                }
                
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
            
            
            
            
        }.resume()
        
        
    }
    
    func refresh() {
        fetchCurrentWarSeason() { [weak self] _ in
            self?.fetchConfig()
            self?.fetchPlanetStatuses { planets in
                self?.fetchMajorOrder { _ in
                    print("fetched major order")
                }// fetching in here so planet status is populated to associate major order planets with tasks
                print("Fetched planets: \(planets.count)")
            }
            self?.fetchPlanetStatusTimeSeries { error in
                if let error = error {
                    print("Error updating planet status time series: \(error)")
                }
            }
        }
    }
    
    
    
    // setup the timer to fetch the data every few seconds or so
    func startUpdating() {
        
        timer?.invalidate()
        
        cacheTimer?.invalidate()
        
        refresh()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            
            // fetch planet data
            
            self?.lastUpdatedDate = Date()
            self?.fetchConfig()
            
            self?.fetchPlanetStatuses { planets in
                
                
                self?.fetchMajorOrder { _ in
                
                    print("fetched major order")
                    
                } // fetching in here so planet status is populated to associate major order planets with tasks
                print("Updated planets: \(planets)")
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
    func fetchConfig() {
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/config/config.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(RemoteConfigDetails.self, from: data) {
                    DispatchQueue.main.async {
                        self.configData = decodedResponse
                    }
                }
            }
        }.resume()
    }
    
    func isActive(planetStatus: PlanetStatus) -> Bool {
        // only show with more than 1000 planets and a liberation status less than 100%
        return planetStatus.players > 1000 && planetStatus.liberation < 100
    }
    
}
