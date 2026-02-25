//
//  Weapon.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct Weapon: Codable, Hashable, DetailItem {
    let id: String
    var name: String
    var description: String
    var type: Int? // only for primaries-
    var damage: Int
    var capacity: Int
    var recoil: Int
    var fireRate: Int
    var fireMode: [Int]
    var traits: [Int]
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let idKey = container.codingPath.last?.stringValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Missing coding path key for id"))
        }
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        damage = try container.decode(Int.self, forKey: .damage)
        capacity = try container.decode(Int.self, forKey: .capacity)
        recoil = try container.decode(Int.self, forKey: .recoil)
        fireRate = try container.decode(Int.self, forKey: .fireRate)
        fireMode = try container.decode([Int].self, forKey: .fireMode)
        traits = try container.decode([Int].self, forKey: .traits)
    }
}

struct Grenade: Codable, Hashable, DetailItem {
    let id: String
    var name: String
    var description: String
    var damage: Int
    var penetration: Int?
    var outerRadius: Int?
    var fuseTime: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let idKey = container.codingPath.last?.stringValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Missing coding path key for id"))
        }
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        damage = try container.decode(Int.self, forKey: .damage)
        penetration = try container.decode(Int.self, forKey: .penetration)
        outerRadius = try container.decode(Int.self, forKey: .outerRadius)
        fuseTime = try container.decode(Double.self, forKey: .fuseTime)
    }
    
}




struct WeaponType: Codable {
    var id: Int
    var name: String
}

struct Trait: Codable {
    var id: Int
    var description: String
}

struct FireMode: Codable {
    var id: Int
    var mode: String
}
