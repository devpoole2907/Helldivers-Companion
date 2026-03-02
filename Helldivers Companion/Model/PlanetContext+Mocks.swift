//
//  PlanetContext+Mocks.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/03/2026.
//

#if DEBUG
import Foundation

// MARK: - UpdatedPlanet mocks

extension UpdatedPlanetStatistics {
    static var mock: UpdatedPlanetStatistics {
        UpdatedPlanetStatistics(
            missionsWon: 142300,
            missionsLost: 18700,
            missionTime: 9_800_000,
            terminidKills: 4_200_000,
            automatonKills: 310_000,
            illuminateKills: 0,
            bulletsFired: 88_500_000,
            bulletsHit: 24_300_000,
            timePlayed: 14_400_000,
            deaths: 620_000,
            revives: 210_000,
            friendlies: 14_200,
            missionSuccessRate: 88,
            accuracy: 27,
            playerCount: 124500
        )
    }

    static var mockAutomaton: UpdatedPlanetStatistics {
        UpdatedPlanetStatistics(
            missionsWon: 87200,
            missionsLost: 22100,
            missionTime: 6_300_000,
            terminidKills: 0,
            automatonKills: 2_100_000,
            illuminateKills: 0,
            bulletsFired: 54_000_000,
            bulletsHit: 18_900_000,
            timePlayed: 9_700_000,
            deaths: 410_000,
            revives: 130_000,
            friendlies: 8_900,
            missionSuccessRate: 79,
            accuracy: 35,
            playerCount: 89300
        )
    }
}

extension UpdatedPlanet {
    static var mockTerminid: UpdatedPlanet {
        UpdatedPlanet(
            index: 5,
            name: "Malevelon Creek",
            sector: "Barnard",
            biome: Biome(name: "jungle", description: "Dense jungle terrain"),
            hazards: [],
            hash: 1_234_567,
            position: Position(x: -0.42, y: 0.31),
            waypoints: [3, 7],
            maxHealth: 1_000_000,
            health: 548_000,
            disabled: false,
            initialOwner: "Terminids",
            currentOwner: "Terminids",
            regenPerSecond: 1388.89,
            event: nil,
            statistics: .mock,
            regions: nil,
            galacticEffects: nil,
            taskProgress: nil
        )
    }

    static var mockAutomaton: UpdatedPlanet {
        UpdatedPlanet(
            index: 12,
            name: "Cyberstan",
            sector: "Lacaille",
            biome: Biome(name: "tundra", description: "Frozen wasteland"),
            hazards: [],
            hash: 9_876_543,
            position: Position(x: 0.18, y: -0.55),
            waypoints: [8, 11],
            maxHealth: 1_000_000,
            health: 272_000,
            disabled: false,
            initialOwner: "Automaton",
            currentOwner: "Automaton",
            regenPerSecond: 2777.78,
            event: nil,
            statistics: .mockAutomaton,
            regions: nil,
            galacticEffects: nil,
            taskProgress: nil
        )
    }

    /// Terminid planet with an active defense event
    static var mockDefending: UpdatedPlanet {
        var planet = UpdatedPlanet.mockTerminid
        planet.event = UpdatedPlanetEvent(
            id: 1,
            eventType: 1,
            faction: "Terminids",
            health: 450_000,
            maxHealth: 1_000_000,
            startTime: "2026-03-02T08:00:00.000Z",
            endTime: "2026-03-02T20:00:00.000Z",
            campaignId: 101,
            jointOperationIds: [],
            globalResourceId: nil
        )
        return planet
    }
}

// MARK: - PlanetContext mocks

extension PlanetContext {
    /// Standard liberation campaign — 45% liberated, active, with rate data
    static var mockLiberation: PlanetContext {
        PlanetContext(
            planet: .mockTerminid,
            faction: .terminid,
            ownerFaction: .terminid,
            isActive: true,
            isDefending: false,
            campaignType: nil,
            liberationType: .liberation,
            liberationPercentage: 45.2,
            liberationRate: 1.3,
            liberationTimeRemaining: Date().addingTimeInterval(3600 * 12),
            eventExpiration: nil,
            eventTotalDuration: nil,
            invasionLevel: nil,
            eventHealth: nil,
            eventMaxHealth: nil,
            fleetStrengthProgress: nil,
            fleetStrengthResource: nil,
            spaceStation: nil,
            spaceStationDetails: nil,
            spaceStationExpiration: nil,
            matchingRegions: [],
            isMajorOrderTarget: false,
            taskProgress: nil,
            warTime: nil
        )
    }

    /// Active defense — 4 hours remaining, 55% defended
    static var mockDefense: PlanetContext {
        PlanetContext(
            planet: .mockDefending,
            faction: .terminid,
            ownerFaction: .human,
            isActive: true,
            isDefending: true,
            campaignType: nil,
            liberationType: .defense,
            liberationPercentage: 55.0,
            liberationRate: nil,
            liberationTimeRemaining: nil,
            eventExpiration: Date().addingTimeInterval(3600 * 4),
            eventTotalDuration: 3600 * 12,
            invasionLevel: 3,
            eventHealth: 450_000,
            eventMaxHealth: 1_000_000,
            fleetStrengthProgress: nil,
            fleetStrengthResource: nil,
            spaceStation: nil,
            spaceStationDetails: nil,
            spaceStationExpiration: nil,
            matchingRegions: [],
            isMajorOrderTarget: false,
            taskProgress: nil,
            warTime: nil
        )
    }

    /// Almost done — 99.9% liberated, Automaton planet, major order target
    static var mockAlmostLiberated: PlanetContext {
        PlanetContext(
            planet: .mockAutomaton,
            faction: .automaton,
            ownerFaction: .automaton,
            isActive: true,
            isDefending: false,
            campaignType: nil,
            liberationType: .liberation,
            liberationPercentage: 99.9,
            liberationRate: 2.1,
            liberationTimeRemaining: Date().addingTimeInterval(60),
            eventExpiration: nil,
            eventTotalDuration: nil,
            invasionLevel: nil,
            eventHealth: nil,
            eventMaxHealth: nil,
            fleetStrengthProgress: nil,
            fleetStrengthResource: nil,
            spaceStation: nil,
            spaceStationDetails: nil,
            spaceStationExpiration: nil,
            matchingRegions: [],
            isMajorOrderTarget: true,
            taskProgress: nil,
            warTime: nil
        )
    }

    /// Inactive human-controlled planet — no campaign
    static var mockInactive: PlanetContext {
        PlanetContext(
            planet: .mockTerminid,
            faction: .human,
            ownerFaction: .human,
            isActive: false,
            isDefending: false,
            campaignType: nil,
            liberationType: .liberation,
            liberationPercentage: 100.0,
            liberationRate: nil,
            liberationTimeRemaining: nil,
            eventExpiration: nil,
            eventTotalDuration: nil,
            invasionLevel: nil,
            eventHealth: nil,
            eventMaxHealth: nil,
            fleetStrengthProgress: nil,
            fleetStrengthResource: nil,
            spaceStation: nil,
            spaceStationDetails: nil,
            spaceStationExpiration: nil,
            matchingRegions: [],
            isMajorOrderTarget: false,
            taskProgress: nil,
            warTime: nil
        )
    }
}

// MARK: - PlanetsDataModel preview helpers

extension PlanetsDataModel {
    /// Returns a model pre-seeded with mock contexts so views that call
    /// `viewModel.context(for:)` work in Xcode Previews without a live fetch.
    static func preview(contexts: [PlanetContext]) -> PlanetsDataModel {
        let model = PlanetsDataModel()
        model.seedForPreview(contexts: contexts)
        return model
    }
}
#endif
