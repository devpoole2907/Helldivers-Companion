//
//  GlobalFunctions.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import Foundation
import SwiftUI

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




    
    // computed prop for api language fetching, determine whether
    var apiSupportedLanguage: String {
        // List of fully localized languages in the API with their corresponding full locales
        let languageToLocaleMapping = [
            "de": "de-DE",
            "en": "en-US",
            "es": "es-ES",
            "fr": "fr-FR",
            "it": "it-IT",
            "pl": "pl-PL",
            "ru": "ru-RU"
        ]

        // Get the preferred language code from the system settings
        let preferredLanguageCode = Locale.preferredLanguages.first?.prefix(2) ?? "en"

        // Check if the preferred language prefix is supported
        if let fullLocale = languageToLocaleMapping[String(preferredLanguageCode)] {
            return fullLocale
        }

        // Default to English (United States) if the preferred language is not fully supported
        return "en-US"
    }
    



