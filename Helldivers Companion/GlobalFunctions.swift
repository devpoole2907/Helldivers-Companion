//
//  GlobalFunctions.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import Foundation

// format major order remaining seconds
func formatDuration(seconds: Int) -> String {
    let secondsPerMinute = 60
    let minutesPerHour = 60
    let hoursPerDay = 24

    let totalMinutes = seconds / secondsPerMinute
    let totalHours = totalMinutes / minutesPerHour
    let days = totalHours / hoursPerDay
    let remainingHours = totalHours % hoursPerDay

    if days > 0 {
        return "\(days)D \(remainingHours)H"
    } 
        return "\(remainingHours)H"
    
    
   
}
