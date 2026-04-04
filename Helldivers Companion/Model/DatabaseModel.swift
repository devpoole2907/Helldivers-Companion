//
//  DatabaseModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import Foundation
import SwiftUI

@MainActor @Observable
class DatabaseModel {
    
    var decodedStrats: [DecodedStratagem] = []
    var primaryWeapons: [Weapon] = []
    var secondaryWeapons: [Weapon] = []
    var grenades: [Grenade] = []
    var types: [WeaponType] = []
    var traits: [Trait] = []
    var fireModes: [FireMode] = []
    var boosters: [Booster] = []
    
    var helmets: [Armour] = []
    var cloaks: [Armour] = []
    var chests: [Armour] = []
    
    private(set) var allArmour: [Armour] = []
    private(set) var allWeapons: [Weapon] = []

    private func rebuildDerivedCollections() {
        allArmour = helmets + cloaks + chests
        allWeapons = primaryWeapons + secondaryWeapons
    }

    // fetch item costs in the store
    func storeCost(for itemName: String, slot: Int) -> Int? {
        return storeRotation?.items.first { $0.name == itemName && $0.slot == String(slot) }?.storeCost
    }
    
    var armourSlots: [ArmourSlot] = []
    var passives: [Passive] = []
    
    var searchText = "" // for search bars
    var selectedWeaponCategory: WeaponCategory = .all // for weapons list
    var selectedArmourCategory: ArmourCategory = .all // for armour list
    
    var sortCriteria: ArmourSortCriteria = .staminaRegen
    
    var storeRotation: SuperStoreResponse?
    
    // war bonds
    // TODO: warbonds are totally screwed up here i misunderstood the data structures, for now ive duct taped it but its completely RINSED how all this works lmaoo
    // at least theyre dynamically fetched now
    
    var warBondCollections: [String: FixedWarBond] = [:]
    
    // enemies for bestiary
    var automatonEnemies: [Enemy] = []
    var terminidsEnemies: [Enemy] = []
    var illuminateEnemies: [Enemy] = []
    
    @ObservationIgnored let netManager = NetworkManager.shared
    
    @ObservationIgnored private var timer: Timer?
    
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
                self.rebuildDerivedCollections()
            case .secondaryWeapons:
                let items: [Weapon] = try await fetchItems(from: type.urlString)
                self.secondaryWeapons = items
                self.rebuildDerivedCollections()
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
                self.rebuildDerivedCollections()
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
            // 1. Fetch armour slots first — needed by store rotation remap
            await fetchItems(for: .armourSlots)
            print("Fetched armour slots")
            
            // 2. Fetch store rotation (depends on armourSlots) and all remaining
            //    items in parallel using a task group.
            let slotsSnapshot = self.armourSlots
            await withTaskGroup(of: Void.self) { group in
                // Store rotation depends on armourSlots but is independent of other items
                group.addTask {
                    do {
                        let storeRotation = try await self.fetchAndRemapStoreRotation(with: slotsSnapshot)
                        await MainActor.run {
                            withAnimation(.bouncy) {
                                self.storeRotation = storeRotation
                            }
                        }
                    } catch {
                        print("Failed to fetch store rotation: \(error)")
                    }
                }
                
                // All item types except armourSlots (already fetched above)
                for itemType in ItemToFetch.allCases where itemType != .armourSlots {
                    group.addTask {
                        await self.fetchItems(for: itemType)
                    }
                }
                
                // War bonds in the same group
                group.addTask {
                    await self.fetchAllWarBonds()
                }
            }
            
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
                    let warBonds = warBondDetails.map { (_, details) -> WarBond in
                        let warBondName = file.name
                            .replacingOccurrences(of: "_", with: " ")
                            .replacingOccurrences(of: ".json", with: "")
                            .capitalized
                        return WarBond(name: warBondName, medalsToUnlock: details.medalsToUnlock, items: details.items)
                    }
                    
                    self.updateWarBondCollection(with: warBonds, for: file.name)
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
        warBondCollections[fileName] = fixedWarBond
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
