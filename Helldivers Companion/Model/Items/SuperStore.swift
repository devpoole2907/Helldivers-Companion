//
//  SuperStore.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation

struct SuperStoreResponse: Decodable {
    var expireTime: Date?
    var items: [StoreItem]
}

struct StoreItem: Codable, Identifiable {
    static func == (lhs: StoreItem, rhs: StoreItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UUID
    var name: String
    var description: String
    var type: String
    var slot: String
    var armorRating: Int
    var speed: Int
    var staminaRegen: Int
    var passive: StoreItemPassive
    var storeCost: Int?
    
    enum CodingKeys: String, CodingKey {
           case name
           case description
           case type
           case slot
           case armorRating
           case speed
           case staminaRegen
           case passive
           case storeCost
       }
       
       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           name = try container.decode(String.self, forKey: .name)
           description = try container.decode(String.self, forKey: .description)
           type = try container.decode(String.self, forKey: .type)
           slot = try container.decode(String.self, forKey: .slot)
           armorRating = try container.decode(Int.self, forKey: .armorRating)
           speed = try container.decode(Int.self, forKey: .speed)
           staminaRegen = try container.decode(Int.self, forKey: .staminaRegen)
           passive = try container.decode(StoreItemPassive.self, forKey: .passive)
           storeCost = try container.decodeIfPresent(Int.self, forKey: .storeCost)
           id = UUID()
       }
    
}

struct StoreItemPassive: Codable {
    var name: String
    var description: String
}
