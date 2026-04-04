//
//  PersonalOrder.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct PersonalOrder: Codable {
    let id32: Int64
    let progress: [Int64]? // optional progress
    let expiresIn: Int64 // time in seconds until expiration
    let setting: Setting
    
    var allRewards: [Setting.Reward] { setting.allRewards }

    enum CodingKeys: String, CodingKey {
        case id32
        case progress
        case expiresIn
        case setting
    }
}
