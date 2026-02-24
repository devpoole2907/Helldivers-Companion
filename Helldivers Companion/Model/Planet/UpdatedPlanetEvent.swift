//
//  UpdatedPlanetEvent.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct UpdatedPlanetEvent: Decodable {
    
    var id: Int
    var eventType: Int64
    var faction: String
    var health: Int64
    var maxHealth: Int64
    var startTime: String
    var endTime: String
    var campaignId: Int64
    var jointOperationIds: [Int64]
    var globalResourceId: Int64?
    
    // computed prop for invasion level
    
    var invasionLevel: Int64? {
        maxHealth / 50000
    }
    
    // computed prop for defense
    var percentage: Double {
        maxHealth > 0 ? (1 - (Double(health) / Double(maxHealth))) * 100 : 0
    }
    // computed prop to get event duration
    var totalDuration: Double? {
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let startTime = dateFormatter.date(from: startTime), let endTime = dateFormatter.date(from: endTime) {
            return endTime.timeIntervalSince(startTime)
        } else {
            // try parsing without fractional seconds if first attempt fails
            dateFormatter.formatOptions = [.withInternetDateTime]
            if let startTime = dateFormatter.date(from: startTime),
               let endTime = dateFormatter.date(from: endTime) {
                return endTime.timeIntervalSince(startTime)
            }
            
        }
        
      return nil
        
        
    }
    
    var expireTimeDate: Date? {
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let endTime = dateFormatter.date(from: endTime) {
            return endTime
            
        } else {
            // same as above
            dateFormatter.formatOptions = [.withInternetDateTime]
            if let endTime = dateFormatter.date(from: endTime) {
                return endTime
            }
        }
        
        return nil
        
        
    }
    
    
}
