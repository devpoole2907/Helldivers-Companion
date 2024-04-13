//
//  GlobalFunctions.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import Foundation

// format major order remaining seconds, using binary integer to support int64 also
func formatDuration<T: BinaryInteger>(seconds: T) -> String {
    let secondsPerMinute: T = 60
    let minutesPerHour: T = 60
    let hoursPerDay: T = 24

    let totalMinutes = seconds / secondsPerMinute
    let totalHours = totalMinutes / minutesPerHour
    let days = totalHours / hoursPerDay
    let remainingHours = totalHours % hoursPerDay

    if days > 0 {
        return "\(days)D \(remainingHours)H"
    } 
        return "\(remainingHours)H"
    
    
   
}

// so people dont lose high scores, have migrated to new user defaults instance for app groups/high score widget
func migrateUserDefaults() {
    let oldUserDefaults = UserDefaults.standard
    if let newUserDefaults = UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion") {

 
    let keysToMigrate = ["highScore"]

    // check if migration needed
        if oldUserDefaults.bool(forKey: "isMigrationDone") == false {
            for key in keysToMigrate {
                if let value = oldUserDefaults.object(forKey: key) {
                    newUserDefaults.set(value, forKey: key)
                }
            }
            newUserDefaults.set(true, forKey: "isMigrationDone")
            newUserDefaults.synchronize()
        }
    }
}

let dashPattern: [CGFloat] = [CGFloat.random(in: 50...70), CGFloat.random(in: 5...20)]
