//
//  DatabaseModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import Foundation
import SwiftUI

class DatabaseModel: ObservableObject {
    
    @Published var decodedStrats: [DecodedStratagem] = []
    @Published var primaryWeapons: [Weapon] = []
    @Published var secondaryWeapons: [Weapon] = []
    @Published var grenades: [Grenade] = []
    @Published var types: [WeaponType] = []
    @Published var traits: [Trait] = []
    @Published var fireModes: [FireMode] = []
    @Published var boosters: [Booster] = []
    
    @Published var helmets: [Armour] = []
    @Published var cloaks: [Armour] = []
    @Published var chests: [Armour] = []
    
    var allArmour: [Armour] {
         helmets + cloaks + chests
       }
    
    var allWeapons: [Weapon] {
        primaryWeapons + secondaryWeapons
    }
    // fetch item costs in the store
    func storeCost(for itemName: String) -> Int? {
        return storeRotation?.items.first { $0.name == itemName }?.storeCost
    }
    
    @Published var armourSlots: [ArmourSlot] = []
    @Published var passives: [Passive] = []
    
    @Published var searchText = "" // for search bars
    @Published var selectedWeaponCategory: WeaponCategory = .all // for weapons list
    @Published var selectedArmourCategory: ArmourCategory = .all // for armour list
    
    @Published var sortCriteria: ArmourSortCriteria = .staminaRegen
    
    @Published var storeRotation: SuperStoreResponse?
    
    // war bonds
    // TODO: warbonds are totally screwed up here i misunderstood the data structures, for now ive duct taped it but its completely RINSED how all this works lmaoo
       @Published var cuttingEdge: FixedWarBond?
       @Published var steeledVeterans: FixedWarBond?
       @Published var helldiversMobilize: FixedWarBond?
       @Published var democraticDetonation: FixedWarBond?
       @Published var polarPatriots: FixedWarBond?
    
    //enemies for bestiary
    @Published var automatonEnemies: [Enemy] = []
    @Published var terminidsEnemies: [Enemy] = []
    

    private var timer: Timer?
    
    func loadData() {
        fetchStrats()
        fetchPrimaryWeapons()
        fetchSecondaryWeapons()
        fetchGrenades()
        fetchTypes()
        fetchTraits()
        fetchFireModes()
        fetchBoosters()
        fetchSlots()
        fetchArmours()
        fetchPassives()
        fetchWarBonds()
        fetchEnemies()
        startUpdating()
    }
    
    func fetchEnemies() {
        
        fetchAutomatonEnemies()
        fetchTerminidsEnemies()
        
    }
    
    
    func startUpdating() {
        
        timer?.invalidate()
        
        self.fetchStoreRotation {
            print("fetched store rotation")
        }
        
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            self?.fetchStoreRotation {
                
            }
            
        }
        
        
    }

    
    func fetchStoreRotation(completion: @escaping () -> Void) {
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/storeRotation.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("WarMonitoriOS/3.1", forHTTPHeaderField: "User-Agent")
        request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Application-Contact")
        request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Super-Contact")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion()
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
            
            
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            
            do {
                
                let decodedResponse = try decoder.decode(SuperStoreResponse.self, from: data)
                
                DispatchQueue.main.async {
                    
                    withAnimation(.bouncy) {
                        self?.storeRotation = decodedResponse
                    }
                    completion()
                }
                
                
                
                
            } catch {
                print("Decoding error: \(error)")
                completion()
            }
            
            
        }.resume()
        
        
    }
    
    func warBond(for itemId: Int) -> WarBond? {
        let collections = [self.cuttingEdge, self.steeledVeterans, self.helldiversMobilize, self.democraticDetonation, self.polarPatriots]
        for fixedWarBond in collections {
            for warBond in fixedWarBond?.warbondPages ?? [] {
                if warBond.items.contains(where: { $0.itemId == itemId }) {
                    return warBond
                }
            }
        }
        return nil
    }
    
    func fixedWarBond(for itemId: Int) -> FixedWarBond? {
        let collections = [self.cuttingEdge, self.steeledVeterans, self.helldiversMobilize, self.democraticDetonation, self.polarPatriots]
        for fixedWarBond in collections {
            if fixedWarBond?.warbondPages.contains(where: { warBond in
                warBond.items.contains(where: { $0.itemId == itemId })
            }) ?? false {
                return fixedWarBond
            }
        }
        return nil
    }


    func itemMedalCost(for itemId: Int) -> Int? {
        guard let warBond = warBond(for: itemId) else { return nil }
        return warBond.items.first { $0.itemId == itemId }?.medalCost
    }

    
    func fetchWarBonds() {
        let urls = [
            "https://raw.githubusercontent.com/helldivers-2/json/master/warbonds/cutting_edge.json",
            "https://raw.githubusercontent.com/helldivers-2/json/master/warbonds/helldivers_mobilize.json",
            "https://raw.githubusercontent.com/helldivers-2/json/master/warbonds/democratic_detonation.json",
            "https://raw.githubusercontent.com/helldivers-2/json/master/warbonds/steeled_veterans.json",
            "https://raw.githubusercontent.com/helldivers-2/json/master/warbonds/polar_patriots.json"
        ]
        
        let warBondNames: [WarBondName] = [.cuttingEdge, .helldiversMobilize, .democraticDetonation, .steeledVeterans, .polarPatriots]
        
        for (index, urlString) in urls.enumerated() {
            if let url = URL(string: urlString) {
                fetchWarBond(url: url, warBondName: warBondNames[index])
            } else {
                print("Invalid URL: \(urlString)")
            }
        }
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
    
    func fetchWarBond(url: URL, warBondName: WarBondName) {
        fetch(url: url) { [weak self] (result: [String: WarBondDetails]) in
            var warBonds = [WarBond]()
            for (_, details) in result {
                let newWarBond = WarBond(name: warBondName, medalsToUnlock: details.medalsToUnlock, items: details.items)
                warBonds.append(newWarBond)
            }
            DispatchQueue.main.async {
                self?.updateWarBondCollection(with: warBonds, for: warBondName)
            }
        }
    }

    private func updateWarBondCollection(with warBonds: [WarBond], for warBondName: WarBondName) {
        let fixedWarBond = FixedWarBond(warbondPages: warBonds)
        DispatchQueue.main.async {
            switch warBondName {
            case .cuttingEdge:
                self.cuttingEdge = fixedWarBond
            case .steeledVeterans:
                self.steeledVeterans = fixedWarBond
            case .helldiversMobilize:
                self.helldiversMobilize = fixedWarBond
            case .democraticDetonation:
                self.democraticDetonation = fixedWarBond
            case .polarPatriots:
                self.polarPatriots = fixedWarBond
            }
        }
    }

    
    
    func fetchPrimaryWeapons() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/primary.json") {
            fetch(url: url) { (weapons: [String: Weapon]) in
                self.primaryWeapons = Array(weapons.values)
                
            }
        }
    }
    
    func fetchSecondaryWeapons() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/secondary.json") {
            fetch(url: url) { (weapons: [String: Weapon]) in
                self.secondaryWeapons = Array(weapons.values)
                
            }
        }
    }
    
    func fetchGrenades() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/grenades.json") {
            fetch(url: url) { (grenades: [String: Grenade]) in
                self.grenades = Array(grenades.values)
                
                
            }
        }
    }
    
    func fetchBoosters() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/boosters.json") {
            fetch(url: url) { (boosters: [String: Booster]) in
                self.boosters = Array(boosters.values)
                
                
            }
        }
    }
    
    func fetchArmours() {
        guard let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/armor/armor.json") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    // decode json into a dictionary
                    let armoursDict = try JSONDecoder().decode([String: Armour].self, from: data)
                    
                    let armours = Array(armoursDict.values)
                    
                    self.helmets = armours.filter({ $0.slot == 0 })
                    
                    self.chests = armours.filter({ $0.slot == 2 })
                    
                    self.cloaks = armours.filter({ $0.slot == 1 })
                    
                   
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func fetchSlots() {
        
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/armor/slot.json") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Network or other error: \(error!.localizedDescription)")
                    return
                }
                do {
                    let rawSlots = try JSONDecoder().decode([String: String].self, from: data)
                    let slots = rawSlots.compactMap { (key, value) -> ArmourSlot? in
                        guard let id = Int(key) else {
                            print("Invalid key \(key), expected an integer")
                            return nil
                        }
                        return ArmourSlot(id: id, name: value)
                    }
                    DispatchQueue.main.async {
                        self.armourSlots = slots
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }.resume()
        }
        
        
    }
    
    func fetchPassives() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/armor/passive.json") {
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Network or other error: \(error!.localizedDescription)")
                    return
                }
                do {
                    
                    let passivesDict = try JSONDecoder().decode([String: Passive].self, from: data)
                    
                   
                    
                    let passives = Array(passivesDict.values)
                    
                    self.passives = passives
                    
                    
                   
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }.resume()
            
        }
        
        
    }
    
    func fetchTypes() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/types.json") {
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
    }

    
    func fetchTraits() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/traits.json") {
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
    }

    
    func fetchFireModes() {
        if let url = URL(string: "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/fire_modes.json") {
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
    }
    
    func fetchAutomatonEnemies() {
            guard let url = URL(string: "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/enemies/automatonEnemies.json") else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    let decodedEnemies = try JSONDecoder().decode([Enemy].self, from: data)
                    DispatchQueue.main.async {
                        self?.automatonEnemies = decodedEnemies
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }.resume()
        }
    
    func fetchTerminidsEnemies() {
            guard let url = URL(string: "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/enemies/terminidEnemies.json") else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    let decodedEnemies = try JSONDecoder().decode([Enemy].self, from: data)
                    DispatchQueue.main.async {
                        self?.terminidsEnemies = decodedEnemies
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
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
    
    enum WeaponCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case primary = "Primary"
        case secondary = "Secondary"
        case grenades = "Grenades"
        
        var id: String { self.rawValue }
    }
    
    enum ArmourCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case helmet = "Helmets"
        case body = "Body"
        case cloak = "Cloaks"
        
        var id: String { self.rawValue }
    }
    
    enum ArmourSortCriteria: String, CaseIterable, Identifiable {
        case staminaRegen = "Stamina Regen"
        case armourRating = "Armour Rating"
        case speed = "Speed"

        var id: ArmourSortCriteria { self }
    }
    
}

