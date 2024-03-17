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
    @Published var majorOrderString: String = "Bugs have taken over!"
    @Published var lastUpdatedDate: Date = Date()
    
    @Published var showInfo = false
    @Published var showOrders = false
    
    //var apiAddress = "http://127.0.0.1:4000/api"
    var apiAddress = "https://helldivers-2.fly.dev/api"
    
    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchCurrentWarSeason(completion: @escaping () -> Void) {
        
        let urlString = apiAddress
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let data = data {
                
                do {
                    
                    let decodedResponse = try JSONDecoder().decode(WarSeason.self, from: data)
                    DispatchQueue.main.async {
                        self?.currentSeason = decodedResponse.current
                        completion()
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
    
    
    func fetchPlanetStatuses() {
        
        let urlString = "\(apiAddress)/\(currentSeason)/status"
        
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url){ [weak self] data, response, error in
            
            if let data = data {
                
                
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    let decodedResponse = try decoder.decode(WarStatusResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.planets = decodedResponse.planetStatus
                            .filter { [weak self] in self?.isActive(planetStatus: $0) ?? false }
                            .sorted { $1.players < $0.players}
                    }
                    
                } catch {
                    print("Decoding error: \(error)")
                }
                
            }
            
            
        }.resume()
        
        
    }
   /*
    func fetchPlanetStatuses(for date: Date) async throws -> [PlanetDataPoint] {
        let dateString = iso8601Formatter.string(from: date)
        let urlString = "https://raw.githubusercontent.com/devpoole2907/Helldivers-Companion/main/data/\(dateString)_planet_statuses.json"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let planetStatuses = try decoder.decode([PlanetStatus].self, from: data)
        
        return planetStatuses.map { PlanetDataPoint(timestamp: date, status: $0) }
    }
   
    // fetches from github old planet status to create graphs
    func fetchCachedPlanetStatuses() async {
        let totalIntervals = 12 * 6 // 12 hours, 6 times per hour
        var planetDataPoints: [PlanetDataPoint] = []

        for interval in 0..<totalIntervals {
            guard let targetDate = Calendar.current.date(byAdding: .minute, value: -interval * 10, to: Date()) else {
                continue
            }
            
            do {
                let dataPoints = try await fetchPlanetStatuses(for: targetDate)
                planetDataPoints.append(contentsOf: dataPoints)
            } catch {
                print("Error fetching data for interval \(interval): \(error)")
            }
        }
        
        // Update your chart UI here with `planetDataPoints`
        print("count of planet data points: \(planetDataPoints.count)")
    }
    // Helper to create an ISO 8601 Date Formatter
    let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
*/

    
    
    // setup the timer to fetch the data every few seconds or so
    func startUpdating() {
        
        timer?.invalidate()
        
        fetchCurrentWarSeason() { [weak self] in
               self?.fetchPlanetStatuses()
                self?.fetchMajorOrder()
           }
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            
            // fetch planet data
            
            self?.lastUpdatedDate = Date()
            self?.fetchMajorOrder()
            self?.fetchPlanetStatuses()
            
            
        }
        
    }
    
    func isActive(planetStatus: PlanetStatus) -> Bool {
      // only show with more than 1000 planets and a liberation status less than 100%
        return planetStatus.players > 1000 && planetStatus.liberation < 100
    }

    
    
    
    
    
    
    
}
