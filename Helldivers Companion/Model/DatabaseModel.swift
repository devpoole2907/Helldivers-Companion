//
//  DatabaseModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import Foundation

class DatabaseModel: ObservableObject {
    
    @Published var decodedStrats: [DecodedStratagem] = []
    @Published var primaryWeapons: [Weapon] = []
    @Published var secondaryWeapons: [Weapon] = []
    @Published var grenades: [Grenade] = []
    @Published var types: [WeaponType] = []
    @Published var traits: [Trait] = []
    @Published var fireModes: [FireMode] = []
    
    
    init() {
        fetchStrats()
        fetchPrimaryWeapons()
        fetchSecondaryWeapons()
        fetchGrenades()
        fetchTypes()
        fetchTraits()
        fetchFireModes()
    }
    
    func fetch<T: Decodable>(url: URL, completion: @escaping (T) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    func fetchPrimaryWeapons() {
        let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/primary.json")!
        fetch(url: url) { (weapons: [String: Weapon]) in
            self.primaryWeapons = Array(weapons.values)

            
        }
    }
    
    func fetchSecondaryWeapons() {
        let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/secondary.json")!
        fetch(url: url) { (weapons: [String: Weapon]) in
            self.secondaryWeapons = Array(weapons.values)

            
        }
    }
    
    func fetchGrenades() {
        let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/grenades.json")!
        fetch(url: url) { (grenades: [String: Grenade]) in
            self.grenades = Array(grenades.values)

            
        }
    }
    

    
    func fetchTypes() {
        let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/types.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network or other error: \(error!.localizedDescription)")
                return
            }
            do {
                let rawTypes = try JSONDecoder().decode([String: String].self, from: data)
                let types = rawTypes.compactMap { (key, value) -> WeaponType? in
                    guard let id = Int(key) else {
                        print("Invalid key \(key), expected an integer")
                        return nil
                    }
                    return WeaponType(id: id, name: value)
                }
                DispatchQueue.main.async {
                    self.types = types
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }

    
    func fetchTraits() {
        let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/traits.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network or other error: \(error!.localizedDescription)")
                return
            }
            do {
                let rawTraits = try JSONDecoder().decode([String: String].self, from: data)
                let traits = rawTraits.compactMap { (key, value) -> Trait? in
                    guard let id = Int(key) else {
                        print("Invalid key \(key), expected an integer")
                        return nil
                    }
                    return Trait(id: id, description: value)
                }
                DispatchQueue.main.async {
                    self.traits = traits
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }

    
    func fetchFireModes() {
        let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/fire_modes.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network or other error: \(error!.localizedDescription)")
                return
            }
            do {
                let rawFireModes = try JSONDecoder().decode([String: String].self, from: data)
                let fireModes = rawFireModes.compactMap { (key, value) -> FireMode? in
                    guard let id = Int(key) else {
                        print("Invalid key \(key), expected an integer")
                        return nil
                    }
                    return FireMode(id: id, mode: value)
                }
                DispatchQueue.main.async {
                    self.fireModes = fireModes
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }

    
    func fetchStrats() {
        
        let urlString = "https://api-hellhub-collective.koyeb.app/api/stratagems?limit=100"
        
        guard let url = URL(string: urlString) else { print("no strats :(")
            return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let data = data, error == nil {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode(DecodedStratagemData.self, from: data)
                    DispatchQueue.main.async {
                        self?.decodedStrats = decodedData.data
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
            
            
        }.resume()
        
        
    }
    
    
    
}
