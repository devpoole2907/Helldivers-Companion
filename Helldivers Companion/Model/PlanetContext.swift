//
//  PlanetContext.swift
//  Helldivers Companion
//
//  Created by James Poole on 26/02/2026.
//

import SwiftUI

/// Pre-computed snapshot of everything UI needs for a planet.
/// Equatable is compiler-synthesized — every stored field is compared automatically.
/// Built once per refresh cycle in PlanetsDataModel.rebuildContexts() and
/// accessed by all views via viewModel.context(for:).
struct PlanetContext: Identifiable, Equatable {
    var id: Int { planet.index }
    let planet: UpdatedPlanet

    // Faction
    let faction: Faction
    let ownerFaction: Faction

    // Campaign state
    let isActive: Bool
    let isDefending: Bool
    let campaignType: Int?

    // Liberation
    let liberationType: LiberationType
    let liberationPercentage: Double
    let liberationRate: Double?
    let liberationTimeRemaining: Date?

    // Defense event
    let eventExpiration: Date?
    let eventTotalDuration: Double?
    let invasionLevel: Int64?
    let eventHealth: Int64?
    let eventMaxHealth: Int64?

    // Fleet strength (event type 3)
    let fleetStrengthProgress: Double?
    let fleetStrengthResource: GlobalResource?

    // Space station
    let spaceStation: SpaceStation?
    let spaceStationDetails: SpaceStationDetails?
    let spaceStationExpiration: Date?

    // Regions, major order, war time
    let matchingRegions: [Region]
    let isMajorOrderTarget: Bool
    let taskProgress: Int64?
    let warTime: Int64?

    // Derived
    var factionColor: Color { faction.color }
    var factionImageName: String { faction.imageName }

    var displayPercentage: Double {
        if let fp = fleetStrengthProgress, planet.event?.eventType == 3 {
            return (1.0 - fp) * 100
        }
        return liberationPercentage
    }

    var liberationText: String {
        if planet.event?.eventType == 3 { return "Liberated" }
        return liberationType == .defense ? "Defended" : "Liberated"
    }

    var defenseTimeProgress: Double? {
        guard let total = eventTotalDuration, let exp = eventExpiration else { return nil }
        let remaining = exp.timeIntervalSince(Date())
        guard total > 0 else { return nil }
        return 1.0 - (remaining / total)
    }

    // NOTE: No custom == implementation — compiler-synthesized compares all stored fields.
}

extension PlanetContext {
    /// Build a context from raw data without a view model — used by widgets and
    /// other contexts where PlanetsDataModel is not available.
    static func forWidget(
        planet: UpdatedPlanet,
        campaigns: [UpdatedCampaign],
        defenseCampaigns: [UpdatedCampaign],
        spaceStations: [SpaceStation] = [],
        fleetStrengthResource: GlobalResource? = nil,
        warTime: Int64? = nil
    ) -> PlanetContext {
        let defense = defenseCampaigns.first { $0.planet.index == planet.index }
        let isActive = campaigns.contains { $0.planet.index == planet.index }
        let isDefending = defense != nil

        let faction: Faction = {
            if let ef = defense?.planet.event?.faction, !ef.isEmpty { return Faction(ownerString: ef) }
            return Faction(ownerString: planet.currentOwner)
        }()

        let fleetProgress: Double = {
            guard let r = fleetStrengthResource else { return 0 }
            return Double(r.currentValue) / Double(r.maxValue)
        }()

        let libPct: Double = {
            if !isActive && planet.currentOwner.lowercased() == "humans" { return 100.0 }
            if defense?.planet.event?.eventType == 3, fleetStrengthResource != nil {
                return (1.0 - fleetProgress) * 100
            }
            return defense?.planet.event?.percentage ?? planet.percentage
        }()

        let station = spaceStations.first { $0.planet.index == planet.index }

        return PlanetContext(
            planet: planet,
            faction: faction,
            ownerFaction: Faction(ownerString: planet.currentOwner),
            isActive: isActive,
            isDefending: isDefending,
            campaignType: campaigns.first { $0.planet.index == planet.index }?.type,
            liberationType: isDefending ? .defense : .liberation,
            liberationPercentage: libPct,
            liberationRate: nil,
            liberationTimeRemaining: nil,
            eventExpiration: defense?.planet.event?.expireTimeDate,
            eventTotalDuration: defense?.planet.event?.totalDuration,
            invasionLevel: defense?.planet.event?.invasionLevel,
            eventHealth: defense?.planet.event?.health,
            eventMaxHealth: defense?.planet.event?.maxHealth,
            fleetStrengthProgress: fleetStrengthResource != nil ? fleetProgress : nil,
            fleetStrengthResource: fleetStrengthResource,
            spaceStation: station,
            spaceStationDetails: nil,
            spaceStationExpiration: station?.electionEndDate,
            matchingRegions: planet.regions ?? [],
            isMajorOrderTarget: false,
            taskProgress: planet.taskProgress,
            warTime: warTime
        )
    }
}
