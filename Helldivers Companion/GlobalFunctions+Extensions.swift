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
