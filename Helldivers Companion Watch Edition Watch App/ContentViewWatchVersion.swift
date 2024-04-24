//
//  ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI
import Haptics

struct ContentViewWatchVersion: View {
    
    @StateObject var viewModel = PlanetsViewModel()
    
    @StateObject var contentNavPather = NavigationPather()
    
    @StateObject var statsNavPather = NavigationPather()
    
    @StateObject var newsNavPather = NavigationPather()
    
    @StateObject var settingsNavPather = NavigationPather()
    
    @StateObject var gameModel = StratagemHeroModel()
    
    @State private var currentTab: Tab = .home
    
    var body: some View {
       
        TabView(selection: $currentTab) {
            
            AboutView().environmentObject(viewModel).environmentObject(settingsNavPather)
            
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
            
        }.conditionalBackground(viewModel: viewModel)
        
        
        .hapticFeedback(.selection, trigger: contentNavPather.navigationPath)
            .hapticFeedback(.selection, trigger: statsNavPather.navigationPath)
   
        
        .onAppear {
            
            viewModel.startUpdating()
            
            gameModel.preloadAssets()

        }
        
    }
}

#Preview {
    ContentViewWatchVersion()
}

