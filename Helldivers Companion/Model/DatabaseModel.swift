//
//  DatabaseModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import Foundation
import SwiftUI

@MainActor
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
    func storeCost(for itemName: String, slot: Int) -> Int? {
        return storeRotation?.items.first { $0.name == itemName && $0.slot == String(slot) }?.storeCost
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
    // at least theyre dynamically fetched now
    
    @Published var warBondCollections: [String: FixedWarBond] = [:]
    
    //enemies for bestiary
    @Published var automatonEnemies: [Enemy] = []
    @Published var terminidsEnemies: [Enemy] = []
    @Published var illuminateEnemies: [Enemy] = []
    
    let netManager = NetworkManager.shared
    
    
    private var timer: Timer?
    
    enum ItemToFetch: CaseIterable {
        case primaryWeapons
        case secondaryWeapons
        case grenades
        case boosters
        case passives
        case armours
        case stratagems
        case automatons
        case terminids
        case illuminate
        case traits
        case fireModes
        case weaponTypes
        case armourSlots
        
        var urlString: String {
            switch self {
            case .primaryWeapons:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/primary.json"
            case .secondaryWeapons:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/secondary.json"
            case .grenades:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/grenades.json"
            case .boosters:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/boosters.json"
            case .passives:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/armor/passive.json"
            case .armours:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/armor/armor.json"
            case .stratagems:
                return "https://api-hellhub-collective.koyeb.app/api/stratagems?limit=100"
            case .automatons:
                return "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/enemies/automatonEnemiesUpdated.json"
            case .terminids:
                return "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/enemies/terminidEnemiesUpdated.json"
            case .illuminate:
                return "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/enemies/illuminateEnemies.json"
            case .traits:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/traits.json"
            case .fireModes:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/fire_modes.json"
            case .weaponTypes:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/weapons/types.json"
            case .armourSlots:
                return "https://raw.githubusercontent.com/helldivers-2/json/master/items/armor/slot.json"
            }
        }
    }
    
    func fetchItems(for type: ItemToFetch) async {
        do {
            switch type {
            case .primaryWeapons:
                let items: [Weapon] = try await fetchItems(from: type.urlString)
                self.primaryWeapons = items
            case .secondaryWeapons:
                let items: [Weapon] = try await fetchItems(from: type.urlString)
                self.secondaryWeapons = items
            case .grenades:
                let items: [Grenade] = try await fetchItems(from: type.urlString)
                self.grenades = items
            case .boosters:
                let items: [Booster] = try await fetchItems(from: type.urlString)
                self.boosters = items
            case .passives:
                let passives: [Passive] = try await fetchItems(from: type.urlString)
                self.passives = passives
            case .armours:
                let armours: [Armour] = try await fetchItems(from: type.urlString)
                self.helmets = armours.filter({ $0.slot == 0 })
                self.chests = armours.filter({ $0.slot == 2 })
                self.cloaks = armours.filter({ $0.slot == 1 })
            case .stratagems:
                let decodedData: DecodedStratagemData = try await netManager.fetchData(from: type.urlString)
                self.decodedStrats = decodedData.data
            case .automatons:
                let enemies: [Enemy] = try await netManager.fetchData(from: type.urlString)
                self.automatonEnemies = enemies
            case .terminids:
                let enemies: [Enemy] = try await netManager.fetchData(from: type.urlString)
                self.terminidsEnemies = enemies
            case .illuminate:
                let enemies: [Enemy] = try await netManager.fetchData(from: type.urlString)
                self.illuminateEnemies = enemies
            case .traits:
                let traits = try await fetchWeaponData(from: type.urlString) { rawTraits in
                    self.transformDictionaryToModel(rawData: rawTraits) { id, value in
                        return Trait(id: id, description: value)
                    }
                }
                self.traits = traits
                print("Fetched weapon traits")
            case .fireModes:
                let fireModes = try await fetchWeaponData(from: type.urlString) { rawFireModes in
                    self.transformDictionaryToModel(rawData: rawFireModes) { id, value in
                        return FireMode(id: id, mode: value)
                    }
                    
                }
                self.fireModes = fireModes
                print("Fetched firing modes")
            case .weaponTypes:
                let types = try await fetchWeaponData(from: type.urlString) { rawTypes in
                    self.transformDictionaryToModel(rawData: rawTypes) { id, name in
                        return WeaponType(id: id, name: name)
                    }
                }
                self.types = types
            case .armourSlots:
                let slots = try await fetchWeaponData(from: type.urlString) { rawSlots in
                    self.transformDictionaryToModel(rawData: rawSlots) { id, value in
                        return ArmourSlot(id: id, name: value)
                    }
                    
                }
                self.armourSlots = slots
                print("fetched armour slots")
            }
        } catch {
            print("Failed to fetch \(type): \(error)")
        }
    }
    
    
    func startUpdating() {
        Task {
         
                // fetch armour slots first
                await fetchItems(for: .armourSlots)
                print("Fetched armour slots")
                
                // try fetch and remap store rotation separately
                do {
                    let storeRotation = try await fetchAndRemapStoreRotation(with: self.armourSlots)
                    await MainActor.run {
                        withAnimation(.bouncy) {
                            self.storeRotation = storeRotation
                        }
                    }
                } catch {
                    print("Failed to fetch store rotation: \(error)")
                }
                
     
                for itemType in ItemToFetch.allCases {
                    await fetchItems(for: itemType)
                }
                
                await fetchAllWarBonds()
        
                setupTimer()
           
        }
    }
    
    private func setupTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                do {
                    if let storeRotation = try await self.fetchAndRemapStoreRotation(with: self.armourSlots) {
                        await MainActor.run {
                            withAnimation(.bouncy) {
                                self.storeRotation = storeRotation
                            }
                        }
                        
                    }
                    
                } catch {
                    print("Error fetching data: \(error)")
                }
            }
        }
    }
    
    
    // FETCH AND TRANSFORM FUNCS
    
    func fetchItems<T: Decodable>(from urlString: String) async throws -> [T] {
        let decodedData: [String: T] = try await netManager.fetchData(from: urlString)
        return Array(decodedData.values)
    }
    
    private func fetchWeaponData<T: Codable>(from urlString: String, transform: @escaping ([String: String]) -> [T]) async throws -> [T] {
        let rawData: [String: String] = try await netManager.fetchData(from: urlString)
        return transform(rawData)
    }
    
    func transformDictionaryToModel<T: Codable>(rawData: [String: String], transform: @escaping (Int, String) -> T?) -> [T] {
        return rawData.compactMap { (key, value) -> T? in
            guard let id = Int(key) else {
                print("Invalid key \(key), expected an integer")
                return nil
            }
            return transform(id, value)
        }
    }
    
    
    // STORE ROTATION
    
    private func fetchAndRemapStoreRotation(with slots: [ArmourSlot]) async throws -> SuperStoreResponse? {
        
        if var storeRotation = try await fetchStoreRotation() {
            storeRotation.items = remapStoreRotationSlots(slots: slots, items: storeRotation.items)
            print("Fetched store rotation, remapping slots to match armour fetch")
            return storeRotation
        }
        return nil
        
    }
    
    func fetchStoreRotation() async throws -> SuperStoreResponse? {
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/storeRotation.json"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("WarMonitoriOS/3.1", forHTTPHeaderField: "User-Agent")
        request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Application-Contact")
        request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Super-Contact")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let decodedResponse = try decoder.decode(SuperStoreResponse.self, from: data)
        return decodedResponse
        
        
    }
    
    private func remapStoreRotationSlots(slots: [ArmourSlot], items: [StoreItem]) -> [StoreItem] {
        return items.map { item in
            var newItem = item
            if let slot = slots.first(where: { $0.name.lowercased() == item.slot.lowercased() }) {
                newItem.slot = String(slot.id)  // convert slot id to string, store items will hold their slots as strings
            }
            return newItem
        }
    }
    
    
    // WAR BONDS
    
    func fetchWarBondDetails(from urlString: String) async throws -> [String: WarBondDetails] {
        return try await netManager.fetchData(from: urlString)
    }
    
    func fetchAllWarBonds() async {
        do {
            let files = try await netManager.fetchFileList(from: "https://api.github.com/repos/helldivers-2/json/contents/warbonds")
                    print("fetched war bond file list: \(files.count)")
            print("fetched war bond file list: \(files.count)")
            for file in files {
                guard let url = URL(string: file.downloadUrl) else {
                    print("Invalid URL: \(file.downloadUrl)")
                    continue
                }
                
                do {
                    print("Fetching war bond details from URL: \(url)")
                    let warBondDetails: [String: WarBondDetails] = try await fetchWarBondDetails(from: url.absoluteString)
                    let warBonds = warBondDetails.map { (key, details) -> WarBond in
                        let warBondName = file.name
                            .replacingOccurrences(of: "_", with: " ")
                            .replacingOccurrences(of: ".json", with: "")
                            .capitalized
                        return WarBond(name: warBondName, medalsToUnlock: details.medalsToUnlock, items: details.items)
                    }
                    
                    DispatchQueue.main.async {
                        self.updateWarBondCollection(with: warBonds, for: file.name)
                    }
                } catch {
                    print("Failed to fetch war bond details from \(url): \(error)")
                }
            }
        } catch {
            print("Failed to fetch war bonds: \(error)")
        }
    }
    
    private func updateWarBondCollection(with warBonds: [WarBond], for fileName: String) {
        let fixedWarBond = FixedWarBond(warbondPages: warBonds)
        DispatchQueue.main.async {
            self.warBondCollections[fileName] = fixedWarBond
        }
    }
    
    
    
    
    func warBond(for itemId: Int) -> WarBond? {
        for (_, fixedWarBond) in self.warBondCollections {
            for warBond in fixedWarBond.warbondPages {
                if warBond.items.contains(where: { $0.itemId == itemId }) {
                    return warBond
                }
            }
        }
        return nil
    }
    
    func fixedWarBond(for itemId: Int) -> FixedWarBond? {
        for (_, fixedWarBond) in self.warBondCollections {
            if fixedWarBond.warbondPages.contains(where: { warBond in
                warBond.items.contains(where: { $0.itemId == itemId })
            }) {
                return fixedWarBond
            }
        }
        return nil
    }
    
    
    func itemMedalCost(for itemId: Int) -> Int? {
        guard let warBond = warBond(for: itemId) else { return nil }
        return warBond.items.first { $0.itemId == itemId }?.medalCost
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

