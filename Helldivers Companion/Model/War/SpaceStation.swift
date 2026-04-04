//
//  SpaceStation.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct SpaceStation: Codable, Equatable {
    let id32: Int64
    let planet: UpdatedPlanet
    let electionEnd: String
    let flags: Int
    
    var electionEndDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // try parse w fractional seconds
        if let parsedDate = dateFormatter.date(from: electionEnd) {
            return parsedDate
        } else {
            // fallback no fractional secs
            dateFormatter.formatOptions = [.withInternetDateTime]
            return dateFormatter.date(from: electionEnd)
        }
    }
    
}

struct SpaceStationDetails: Codable, Equatable {
    let id32: Int64
    let planetIndex: Int
    let lastElectionId: String?
    let currentElectionId: String?
    let nextElectionId: String?
    let currentElectionEndWarTime: Int
    let flags: Int
    let tacticalActions: [SpaceStationTacticalAction]
}

struct SpaceStationTacticalAction: Codable, Equatable {
    let id32: Int64
    let mediaId32: Int64
    let name: String
    let description: String
    let strategicDescription: String
    let status: Int
    let statusExpireAtWarTimeSeconds: Int
    let cost: [SpaceStationActionCost]
    let effectIds: [Int]
    let activeEffectIds: [Int]
}

struct SpaceStationActionCost: Codable, Equatable {
    let id: String
    let itemMixId: Int64
    let targetValue: Double
    let currentValue: Double
    let deltaPerSecond: Double
    let maxDonationAmount: Int
    let maxDonationPeriodSeconds: Int
}
