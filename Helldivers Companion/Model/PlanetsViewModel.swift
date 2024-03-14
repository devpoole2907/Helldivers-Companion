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
    
    private var timer: Timer?
    
    init() {
        
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchCurrentWarSeason(completion: @escaping () -> Void) {
        
        let urlString = "https://helldivers-2.fly.dev/api"
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
        
        
        let urlString = "https://helldivers-2.fly.dev/api/\(currentSeason)/events/latest"
        
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
        
        let urlString = "https://helldivers-2.fly.dev/api/\(currentSeason)/status"
        
        
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
      
        return planetStatus.players > 0 && planetStatus.liberation < 100
    }

    
    
    
    
    
    
    
}
