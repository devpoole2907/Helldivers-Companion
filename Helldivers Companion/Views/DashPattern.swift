//
//  DashPattern.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/04/2024.
//

import Foundation

class DashPattern {

    var dashPatterns: [UUID: [CGFloat]] = [:]  // dict to store dash patterns indexed by stratagem.id for the row backgrounds
        
    func dashPattern(for stratagem: Stratagem? = nil) -> [CGFloat] {
        if let stratagem = stratagem, let pattern = dashPatterns[stratagem.id] {
            return pattern
        } else {
            // create new random pattern
            let newPattern = [CGFloat.random(in: 50...70), CGFloat.random(in: 5...20)]
            if let stratagem = stratagem {
                dashPatterns[stratagem.id] = newPattern
            }
            return newPattern
        }
    }
    
    
}
