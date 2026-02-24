//
//  Booster.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct Booster: Codable, DetailItem {
    let id: String
    var name: String
    var description: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idKey = container.codingPath.last!.stringValue
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description
    }
    
}
