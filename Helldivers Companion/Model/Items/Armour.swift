//
//  Armour.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct Armour: Codable, Hashable, DetailItem {
    let id: String
    let name: String
    var description: String? = nil
    let type: Int
    let slot: Int
    let armourRating: Int
    let speed: Int
    let staminaRegen: Int
    let passive: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idKey = container.codingPath.last!.stringValue
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        type = try container.decode(Int.self, forKey: .type)
        slot = try container.decode(Int.self, forKey: .slot)
        armourRating = try container.decode(Int.self, forKey: .armourRating)
        speed = try container.decode(Int.self, forKey: .speed)
        staminaRegen = try container.decode(Int.self, forKey: .staminaRegen)
        passive = try container.decode(Int.self, forKey: .passive)
    }
    
    init(id: String, name: String, description: String? = nil, type: Int, slot: Int, armourRating: Int, speed: Int, staminaRegen: Int, passive: Int) {
            self.id = id
            self.name = name
            self.description = description
            self.type = type
            self.slot = slot
            self.armourRating = armourRating
            self.speed = speed
            self.staminaRegen = staminaRegen
            self.passive = passive
        }
    
    enum CodingKeys: String, CodingKey {
        // NOTE: everything gets decoded from snake case, in the data the armour rating is actually armor_rating/stamina_regen etc
        case name, description, type, slot, armourRating = "armorRating", speed, staminaRegen = "staminaRegen", passive
    }
}

struct ArmourSlot: Codable {
    
    var id: Int
    var name: String
    
}

struct Passive: Codable, Identifiable {
    var id: Int
    let name: String
    let description: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let idKey = container.codingPath.last!.stringValue
        
        guard let id = Int(idKey) else {
                    throw DecodingError.dataCorruptedError(forKey: .id,
                      in: container,
                      debugDescription: "ID not an int")
                }
                self.id = id
        
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
    }
    
    enum CodingKeys: String, CodingKey {
            case id, name, description
        }
    
}
