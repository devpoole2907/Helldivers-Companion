//
//  WarBond.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct WarBond: Hashable {
    static func == (lhs: WarBond, rhs: WarBond) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var name: String
    var medalsToUnlock: Int
    var items: [WarBondItem]
    
}

struct WarBondSection: Hashable {
    var sectionId: Int
    var medalsToUnlock: Int
    var items: [WarBondItem]
}

struct WarBondDetails: Decodable {
    var medalsToUnlock: Int
    var items: [WarBondItem]
}

struct WarBondItem: Decodable, Hashable {
    var itemId: Int
    var medalCost: Int
}

struct FixedWarBond: Hashable {
    
    var id = UUID()
    var warbondPages: [WarBond]
    
    
}
