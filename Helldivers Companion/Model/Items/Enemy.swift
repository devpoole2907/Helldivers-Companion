//
//  Enemy.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct Enemy: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    var description: String
    var recommendedStratagems: [Stratagem]
    var imageUrl: String

    enum CodingKeys: String, CodingKey {
        case name, description, recommendedStratagems, imageUrl
    }
    
    // custom decoder to map string names to stratagems
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        
        // decode array of stratagem names
        let stratagemNames = try container.decode([String].self, forKey: .recommendedStratagems)
        
        // map names to global stratagems
        self.recommendedStratagems = stratagemNames.compactMap { name in
            globalStratagems.first { $0.name == name }
        }
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
}
