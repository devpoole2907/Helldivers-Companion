//
//  NavigationPather.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI

@Observable
class NavigationPather {
    var navigationPath: NavigationPath = NavigationPath() // hold nav path
    var scrollPosition: Int? = 0 // control scroll position in views
    
    func popToRoot() {
        self.navigationPath = NavigationPath()
    }
    
}
