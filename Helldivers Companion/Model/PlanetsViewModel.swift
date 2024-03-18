//
//  PlanetsViewModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation

class PlanetsViewModel: ObservableObject {
    
    @Published var planets: [PlanetStatus] = []
    @Published var currentSeason: String = ""
    @Published var majorOrderString: String = "Stand by for further orders from Super Earth High Command."
    @Published var lastUpdatedDate: Date = Date()
    
    private var apiToken: String? = nil
    
    @Published var bugRates: BugRate = BugRate(terminidRate: "-5%", automatonRate: "-1.5%")
    
    @Published var showInfo = false
    @Published var showOrders = false
    
    //var apiAddress = "http://127.0.0.1:4000/api"
    var apiAddress = "https://helldivers-2.fly.dev/api"
    
    @Published var planetHistory: [String: [PlanetDataPoint]] = [:]
    
    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    
    func fetchPlanetStatusTimeSeries(completion: @escaping (Error?) -> Void) {
        Task {
            do {
                let history = try await fetchCachedPlanetData()
                DispatchQueue.main.async {
                    self.planetHistory = history
                    print("Success, there are \(history.count) data points")
                    completion(nil)  // No error, pass nil to the completion handler
                }
            } catch {
                print("Error fetching planet status time series: \(error)")
                completion(error)  // Pass the error to the completion handler
            }
        }
    }
    
    func fetchCachedPlanetData() async throws -> [String: [PlanetDataPoint]] {
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
                    
                    let fileTimestamp = extractTimestamp(from: file.name)
                    
                    for status in planetStatuses {
                        let planetName = status.planet.name
                        let dataPoint = PlanetDataPoint(timestamp: fileTimestamp, status: status)
                        planetHistory[planetName, default: []].append(dataPoint)
                    }
                } catch {
                    print("Error fetching file data: \(error)")
                    continue // skip file, couldve been rated limited
                }
            }
        
        for key in planetHistory.keys {
            planetHistory[key]?.sort(by: { $0.timestamp < $1.timestamp })
        }
        
        return planetHistory
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
    
    func fetchMajorOrder() {
        
        
        let urlString = "\(apiAddress)/\(currentSeason)/events/latest"
        
        print("made url")
        guard let url = URL(string: urlString) else { print("mission failed")
            return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let data = data {
                
                
                do {
                    let decoder = JSONDecoder()
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let decodedResponse = try decoder.decode(MajorOrderResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.majorOrderString = decodedResponse.message.en
                        print("We set the major order")
                    }
                    
                    
                } catch {
                    print("Decoding error: \(error)")
                }
            } else {
                print("NOOO!")
            }
            
            print("yeet")
            
        }.resume()
        
        print("woohoo")
        
        
    }
    
    
    func fetchPlanetStatuses(for season: String? = nil, completion: @escaping ([PlanetStatus]) -> Void) {
        
        // this function should be adapted for use both in the caching one or the live one below
        
        
        let urlString = "\(apiAddress)/\(season ?? currentSeason)/status"
        
        //  let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/data/2024-03-17T02%3A20%3A07Z_planet_statuses.json"
        
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url){ [weak self] data, response, error in
            
            guard let data = data else {
                completion([])
                return
            }
            

                
                
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let decodedResponse = try decoder.decode(WarStatusResponse.self, from: data)
                    DispatchQueue.main.async {
                        
                        
                        
                        let filteredPlanets = decodedResponse.planetStatus
                            .filter { [weak self] in self?.isActive(planetStatus: $0) ?? false }
                            .sorted { $1.players < $0.players}
                        self?.planets = filteredPlanets
                                        completion(filteredPlanets)
                    }
                    
                } catch {
                    print("Decoding error: \(error)")
                    completion([])
                }
                
            
            
            
        }.resume()
        
        
    }
    
    
    
    // setup the timer to fetch the data every few seconds or so
    func startUpdating() {
        
        timer?.invalidate()
        
        fetchCurrentWarSeason() { [weak self] _ in
            self?.fetchBugRates()
            self?.fetchPlanetStatuses { planets in
                print("Fetched planets: \(planets)")
            }
            self?.fetchMajorOrder()
            self?.fetchPlanetStatusTimeSeries { error in
                if let error = error {
                    print("Error updating planet status time series: \(error)")
                }
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            
            // fetch planet data
            
            self?.lastUpdatedDate = Date()
            self?.fetchBugRates()
            self?.fetchMajorOrder()
            self?.fetchPlanetStatuses { planets in
                print("Fetched planets: \(planets)")
            }
            self?.fetchPlanetStatusTimeSeries { error in
                if let error = error {
                    print("Error updating planet status time series: \(error)")
                }
            }
            
        }
        
    }
    // update bug rates via github json file so the app doesnt need an update every change
    func fetchBugRates() {
            let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/force-rates/rates.json"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(BugRate.self, from: data) {
                        DispatchQueue.main.async {
                            self.bugRates = decodedResponse
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
