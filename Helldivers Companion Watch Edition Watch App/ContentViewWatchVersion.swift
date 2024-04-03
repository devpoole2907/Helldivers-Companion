//
//  ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI

struct ContentViewWatchVersion: View {
    
    @StateObject var viewModel = PlanetsViewModel()
    
    @StateObject var contentNavPather = NavigationPather()
    
    @StateObject var statsNavPather = NavigationPather()
    
    @StateObject var newsNavPather = NavigationPather()
    
    @StateObject var gameModel = StratagemHeroModel()
    
    @State private var currentTab: Tab = .home
    
    var body: some View {
       
        TabView(selection: $currentTab) {
            
            AboutView().environmentObject(viewModel)
            
                .tag(Tab.about)
            
            GameViewWatch().environmentObject(gameModel)
                .tag(Tab.game)
            
            ContentView().environmentObject(viewModel).environmentObject(contentNavPather)
                .tag(Tab.home)
            
            WatchOrdersView().environmentObject(viewModel)
                .tag(Tab.orders)
            
            WatchGalaxyStatsView().environmentObject(viewModel).environmentObject(statsNavPather)
                .tag(Tab.stats)
            
            WatchNewsView().environmentObject(newsNavPather).environmentObject(viewModel)
                .tag(Tab.news)
 
           
                
                .navigationBarTitleDisplayMode(.inline)
            
        }.background {
            Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
        }
   
        
        .onAppear {
            
            viewModel.startUpdating()
            
            gameModel.preloadAssets()

        }
        
    }
}

#Preview {
    ContentViewWatchVersion()
}

