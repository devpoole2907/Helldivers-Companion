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
        guard let idKey = container.codingPath.last?.stringValue else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Missing coding path key for id"))
        }
        id = idKey
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description
    }
    
}
