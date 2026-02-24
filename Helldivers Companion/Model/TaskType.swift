//
//  TaskType.swift
//  Helldivers Companion
//
//  Gives names to the magic integers used for Setting.Task.type
//  and Setting.Task.valueTypes throughout the API.
//

import Foundation

/// The kind of objective a Setting.Task represents.
/// Raw values match the integers the API sends in `Setting.Task.type`.
enum TaskType: Int, CaseIterable, Codable, Sendable {
    case extract = 2
    case eradicate = 3
    case secondaryObjective = 4
    case missionExtract = 7
    case liberation = 11
    case defense = 12
    case liberationAlt = 13
    case netQuantity = 15

    /// Both `.liberation` and `.liberationAlt` are liberation orders.
    var isLiberation: Bool { self == .liberation || self == .liberationAlt }
}

/// The semantic meaning of each position in Setting.Task.valueTypes / values.
/// Raw values match the integers the API sends in the `valueTypes` array.
enum TaskValueType: Int, Sendable {
    case raceId = 1
    case goal = 3
    case unitId = 4
    case itemId = 5
    case locationType = 11
    case planetIndex = 12
}

// MARK: - Setting.Task Convenience

extension Setting.Task {

    /// Typed version of the raw `type` integer. Returns nil for unknown types.
    var taskType: TaskType? { TaskType(rawValue: type) }

    /// Look up a value by its semantic type instead of a magic index.
    /// Returns 0 when the requested type isn't present — same fallback
    /// the existing `parsedValues[key] ?? 0` code used.
    func value(for vt: TaskValueType) -> Int64 {
        guard let i = valueTypes.firstIndex(of: vt.rawValue), i < values.count else { return 0 }
        return values[i]
    }
}
