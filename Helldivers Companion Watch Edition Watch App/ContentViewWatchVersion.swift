//
//  ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI

struct ContentViewWatchVersion: View {
    
    @StateObject var viewModel = PlanetsViewModel()
    
    @State private var currentTab: Tab = .home
    
    var body: some View {
       
        TabView(selection: $currentTab) {
            
            AboutView().environmentObject(viewModel)
                .tag(Tab.about)
            
            GameViewWatch()
                .tag(Tab.game)
                .background {
                    Color.black.ignoresSafeArea()
                }
            
            ContentView().environmentObject(viewModel)
                .tag(Tab.home)
            
            WatchOrdersView().environmentObject(viewModel)
                .tag(Tab.orders)
            
            NewsView()
                .tag(Tab.news)
 
           
                
                .navigationBarTitleDisplayMode(.inline)
            
        }.background {
            Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
        }
        
    }
}

#Preview {
    ContentViewWatchVersion()
}

