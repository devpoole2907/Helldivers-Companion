//
//  Faction.swift
//  Helldivers Companion
//
//  Created by James Poole on 23/02/2026.
//

import SwiftUI

enum Faction: Int64, CaseIterable, Codable, Hashable {
    case human = 1, terminid = 2, automaton = 3, illuminate = 4, unknown = -1
    
    init(ownerString: String){
        switch ownerString.lowercased() {
        case "human", "humans":
            self = .human
        case "terminid", "terminids":
            self = .terminid
        case "automaton", "automatons":
            self = .automaton
        case "illuminate":
            self = .illuminate
        default:
            self = .unknown
        }
    }
    
    init(id: Int64) {
        self = Faction(rawValue: id) ?? .unknown
    }
    
    var displayName: String {
        switch self {
        case .human:
            return "Super Earth"
        case .terminid:
            return "Terminids"
        case .automaton:
            return "Automatons"
        case .illuminate:
            return "Illuminate"
        default:
            return "Unknown"
        }
    }
    
    var color: Color {
        switch self {
        case .human:
            .cyan
        case .terminid:
                .yellow
        case .automaton:
                .red
        case .illuminate:
                .purple
        default:
                .gray
        }
    }
    
    var imageName: String {
        switch self {
            case .human:
            return "human"
        case .terminid:
            return "terminid"
        case .automaton:
            return "automaton"
        case .illuminate:
            return "illuminate"
        default:
            return "human"
        }
    }
    
    var isEnemy: Bool {
        switch self {
        case .human, .unknown:
            return false
        default:
            return true
        }
    }
    
    
    
    
}
