//
//  UpdatedCampaign.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct UpdatedCampaign: Codable, Hashable {
    
    static func == (lhs: UpdatedCampaign, rhs: UpdatedCampaign) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
    var id: Int
    var planet: UpdatedPlanet
    var type: Int
    var count: Int64
    var faction: String
}
