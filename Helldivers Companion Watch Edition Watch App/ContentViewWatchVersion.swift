//
//  ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI
import Haptics
struct ContentViewWatchVersion: View {
    
    @State var viewModel = PlanetsDataModel()
    
    @State var contentNavPather = NavigationPather()
    
    @State var statsNavPather = NavigationPather()
    
    @State var newsNavPather = NavigationPather()
    
    @State var settingsNavPather = NavigationPather()
    
    @State var gameModel = StratagemHeroModel()
    
    @State private var currentTab: Tab = .home
    
    var body: some View {
       
        TabView(selection: $currentTab) {
            
            AboutView().environment(viewModel).environment(settingsNavPather)
            
                .tag(Tab.about)
            
            GameViewWatch().environment(gameModel)
                .tag(Tab.game)
            
            ContentView().environment(viewModel).environment(contentNavPather)
                .tag(Tab.home)
            
            WatchOrdersView().environment(viewModel)
                .tag(Tab.orders)
            
            if #available(watchOS 10, *) {
            WatchGalaxyStatsView().environment(viewModel).environment(statsNavPather)
                .tag(Tab.stats)
            
        
                WatchNewsView().environment(newsNavPather).environment(viewModel)
                    .tag(Tab.news)
                
                
                
                
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                
                
                Text("Update to watchOS 10.0 for the complete War Monitor experience.")
                    .multilineTextAlignment(.center)
                    .tag(Tab.news)
                
            }
            
        }.conditionalBackground(viewModel: viewModel)
        
        
        .hapticFeedback(.selection, trigger: contentNavPather.navigationPath)
            .hapticFeedback(.selection, trigger: statsNavPather.navigationPath)
   
        
        .onAppear {
            
            viewModel.startUpdating()
            
            gameModel.preloadAssets()

        }
        
    }
}
