//
//  PLanetLookup.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

// conv planetPositions into a dict for quick lookup in personal orders
let planetPositionLookup: [Int64: PlanetPosition] = {
    var dict = [Int64: PlanetPosition]()
    for p in planetPositions {
        dict[Int64(p.index)] = p
    }
    return dict
}()
