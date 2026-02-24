//
//  RemoteConfigDetails.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct RemoteConfigDetails: Decodable {
    var alert: String?
    var prominentAlert: String?
    var season: String
    var showIlluminate: Bool
    var apiAddress: String
    var startedAt: String // temporarily we will now store the start date statically
    var meridiaEvent: Bool // temporary measure, to show meridia energy bar via config - hardcoded at this stage to only work for index 64 planet (meridia)
    
    func convertStartedAtToDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        print("Attempting to convert date: \(startedAt)")
        return dateFormatter.date(from: startedAt)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case alert, prominentAlert, season, showIlluminate, apiAddress, startedAt, meridiaEvent
    }
    // default init
    init(alert: String, prominentAlert: String?, season: String, showIlluminate: Bool, apiAddress: String, startedAt: String, meridiaEvent: Bool) {
        self.alert = alert
        self.prominentAlert = prominentAlert
        self.season = season
        self.showIlluminate = showIlluminate
        self.apiAddress = apiAddress
        self.startedAt = startedAt
        self.meridiaEvent = meridiaEvent
    }
    
    // set prominent alert to nil if its empty
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alert = try container.decode(String.self, forKey: .alert)
        
        let prominentAlertValue = try container.decode(String.self, forKey: .prominentAlert)
        prominentAlert = prominentAlertValue.isEmpty ? nil : prominentAlertValue
        season = try container.decode(String.self, forKey: .season)
        showIlluminate = try container.decode(Bool.self, forKey: .showIlluminate)
        apiAddress = try container.decode(String.self, forKey: .apiAddress)
        startedAt = try container.decode(String.self, forKey: .startedAt)
        meridiaEvent = try container.decode(Bool.self, forKey: .meridiaEvent)
    }
    
}
