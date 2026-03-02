//
//  GlobalResourceID.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/03/2026.
//

enum GlobalResourceID: Int64 {
    case fleetStrength = 175685818
    case darkEnergy    = 194773219
}

extension Array where Element == GlobalResource {
    func resource(for id: GlobalResourceID) -> GlobalResource? {
        first { $0.id32 == id.rawValue }
    }
}
