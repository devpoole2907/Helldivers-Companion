//
//  MajorOrder.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//

import Foundation


struct MajorOrder: Decodable {
    let id32: Int64 // this must be int64 to run on watchOS!
    let progress: [Int64]
    let expiresIn: Int64 // this must be int64 to run on watchOS!
    let setting: Setting
    
    // MARK: - Task filtering via TaskType enum
    
    func tasks(ofType type: TaskType) -> [Setting.Task] {
        setting.tasks.filter { $0.taskType == type }
    }
    
    func hasTasks(ofType type: TaskType) -> Bool {
        setting.tasks.contains { $0.taskType == type }
    }
    
    var hasLiberationTasks: Bool {
        setting.tasks.contains { $0.taskType?.isLiberation == true }
    }
    
    var extractionProgress: [(description: AttributedString, progress: Double, progressString: String)]? {
        guard hasTasks(ofType: .extract) else { return nil }
        return tasks(ofType: .extract).compactMap { task in
            let goal = task.value(for: .goal)
            guard goal > 0,
                  let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex]
            else {
                return nil
            }
            
            let progressValue = Double(currentProgress) / Double(goal)
            let progressString = "\(currentProgress)/\(goal)"
            return (task.description, progressValue, progressString)
        }
    }
    
    var missionExtractProgress: [(description: AttributedString, progress: Double, progressString: String)]? {
        guard hasTasks(ofType: .missionExtract) else { return nil }
        return tasks(ofType: .missionExtract).compactMap { task in
            let goal = task.value(for: .goal)
            guard goal > 0,
                  let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex] else {
                return nil
            }

            let progressValue = Double(currentProgress) / Double(goal)
            let progressString = "\(currentProgress)/\(goal) (\(String(format: "%.1f", progressValue * 100))%)"
            return (task.description, progressValue, progressString)
        }
    }
    
    var eradicationProgress: [(progress: Double, progressString: String)]? {
        guard hasTasks(ofType: .eradicate) else { return nil }
        return tasks(ofType: .eradicate).compactMap { task in
            let goal = task.value(for: .goal)
            guard goal > 0,
                  let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex]
            else {
                return nil
            }
            
            let progressValue = Double(currentProgress) / Double(goal)
            let progressString = "\(currentProgress)/\(goal) (\(String(format: "%.1f", progressValue * 100))%)"
            return (progressValue, progressString)
        }
    }
    
    var defenseProgress: [(progress: Double, progressString: String)]? {
        guard hasTasks(ofType: .defense) else { return nil }
        return tasks(ofType: .defense).compactMap { task in
            let goal = task.value(for: .goal)
            guard goal > 0,
                  let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex]
            else {
                return nil
            }
            
            let progressValue = Double(currentProgress) / Double(goal)
            let progressString = "\(currentProgress)/\(goal) (\(String(format: "%.1f", progressValue * 100))%)"
            return (progressValue, progressString)
        }
    }
    
    var netQuantityProgress: [(progress: Double, progressString: String)]? {
        guard hasTasks(ofType: .netQuantity) else { return nil }
        return tasks(ofType: .netQuantity).compactMap { task in
            guard let taskIndex = setting.tasks.firstIndex(of: task),
                  let currentProgress = progress[safe: taskIndex]
            else {
                return nil
            }
            
            let maxProgressValue: Double = 10
            let normalizedProgress = 1 - (Double(currentProgress) + maxProgressValue) / (2 * maxProgressValue)
            
            let progressString = "\(currentProgress) (normalized: \(String(format: "%.1f", normalizedProgress * 100))%)"
            return (normalizedProgress, progressString)
        }
    }
    
    var faction: Faction? {
        if let first = tasks(ofType: .eradicate).first {
            return Faction(rawValue: first.value(for: .raceId)) ?? .unknown
        } else if let first = tasks(ofType: .defense).first {
            return Faction(rawValue: first.value(for: .raceId)) ?? .unknown
        } else {
            return nil
        }
    }
    
    var allRewards: [Setting.Reward] { setting.allRewards }
    
    enum CodingKeys: String, CodingKey {
        case id32
        case progress
        case expiresIn
        case setting
    }
    
    
}
