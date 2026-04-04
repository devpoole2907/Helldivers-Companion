//
//  PlanetsDataModel+Cache.swift
//  Helldivers Companion
//
//  Created by James Poole on 04/04/2026.
//

import Foundation

// MARK: - Cached Snapshot

/// A lightweight Codable snapshot of the core war state.
/// Written atomically to the App Group container after each successful refresh.
/// Loaded synchronously at launch to provide instant UI while the network catches up.
struct CachedWarSnapshot: Codable {
    var campaigns: [UpdatedCampaign]
    var defenseCampaigns: [UpdatedCampaign]
    var planets: [UpdatedPlanet]
    var sortedSectors: [String]
    var groupedBySector: [String: [UpdatedPlanet]]
    var spaceStations: [SpaceStation]
    var firstSpaceStationDetails: SpaceStationDetails?
    var majorOrders: [MajorOrder]
    var taskPlanets: [UpdatedPlanet]
    var personalOrder: PersonalOrder?
    var status: StatusResponse?
    var warTime: Int64?
    var configData: RemoteConfigDetails?
    var galaxyStats: GalaxyStats?
    var savedAt: Date
}

// MARK: - Snapshot File URL

extension PlanetsDataModel {
    /// URL in the App Group container where the snapshot is stored.
    static var snapshotFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.poole.james.HelldiversCompanion")?
            .appendingPathComponent("warSnapshot.json")
    }
}

// MARK: - Save / Load

extension PlanetsDataModel {

    /// Captures the current state into a snapshot and writes it to disk
    /// on a background thread so encoding + I/O don't block the main actor.
    func saveSnapshot() {
        guard let url = Self.snapshotFileURL else { return }

        // Capture all values on the main actor (cheap struct copies).
        let snapshot = CachedWarSnapshot(
            campaigns: updatedCampaigns,
            defenseCampaigns: updatedDefenseCampaigns,
            planets: updatedPlanets,
            sortedSectors: updatedSortedSectors,
            groupedBySector: updatedGroupedBySectorPlanets,
            spaceStations: spaceStations,
            firstSpaceStationDetails: firstSpaceStationDetails,
            majorOrders: majorOrders,
            taskPlanets: updatedTaskPlanets,
            personalOrder: personalOrder,
            status: status,
            warTime: warTime,
            configData: configData,
            galaxyStats: galaxyStats,
            savedAt: Date()
        )

        // Encode and write on a background thread.
        Task.detached(priority: .utility) {
            do {
                let data = try JSONEncoder().encode(snapshot)
                try data.write(to: url, options: .atomicWrite)
                print("Snapshot saved to disk (\(data.count) bytes).")
            } catch {
                print("Failed to save snapshot: \(error)")
            }
        }
    }

    /// Loads the on-disk snapshot and populates all @Observable properties immediately,
    /// then sets `isLoading = false` so the UI renders without waiting for the network.
    /// Returns `true` if valid cached data was found and applied.
    @discardableResult
    func loadSnapshot() -> Bool {
        guard let url = Self.snapshotFileURL,
              let data = try? Data(contentsOf: url),
              let snapshot = try? JSONDecoder().decode(CachedWarSnapshot.self, from: data)
        else {
            return false
        }

        // Discard snapshots older than 24 hours — stale data is worse than a spinner
        guard snapshot.savedAt > Date().addingTimeInterval(-86_400) else {
            print("Snapshot too old, ignoring.")
            return false
        }

        print("Loading snapshot from disk (saved at \(snapshot.savedAt)).")

        updatedCampaigns = snapshot.campaigns
        updatedDefenseCampaigns = snapshot.defenseCampaigns
        updatedPlanets = snapshot.planets
        updatedSortedSectors = snapshot.sortedSectors
        updatedGroupedBySectorPlanets = snapshot.groupedBySector
        spaceStations = snapshot.spaceStations
        firstSpaceStationDetails = snapshot.firstSpaceStationDetails
        majorOrders = snapshot.majorOrders
        updatedTaskPlanets = snapshot.taskPlanets
        personalOrder = snapshot.personalOrder
        status = snapshot.status
        if let wt = snapshot.warTime { warTime = wt }
        if let config = snapshot.configData {
            configData = config
            showIlluminateUI = config.showIlluminate
        }
        if let stats = snapshot.galaxyStats { galaxyStats = stats }
        lastUpdatedDate = snapshot.savedAt

        if !hasSetSelectedPlanet {
            selectedPlanet = snapshot.campaigns.first?.planet
            hasSetSelectedPlanet = true
        }

        rebuildDerivedState()

        return true
    }
}
