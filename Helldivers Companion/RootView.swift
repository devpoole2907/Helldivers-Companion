//
//  RootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            
            ContentView()
                .tabItem {
                    Image(systemName: "globe.americas.fill")
                }
            
            GameView()
                .tabItem {
                    Image(systemName: "scope")
                }
            
            
        }
    }
}

#Preview {
    RootView()
}

extension View {
    func getRect()->CGRect {
        return UIScreen.main.bounds
    }
}
