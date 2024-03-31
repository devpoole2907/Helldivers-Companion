//
//  ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI

struct ContentViewWatchVersion: View {
    
    @StateObject var viewModel = PlanetsViewModel()
    
    @StateObject var purchaseManager = StoreManager()
    
    @State private var currentTab: Tab = .home
    
    var body: some View {
       
        TabView(selection: $currentTab) {
            
            AboutView().environmentObject(viewModel)
                .environmentObject(purchaseManager)
                .tag(Tab.about)
            
            GameViewWatch().environmentObject(purchaseManager)
                .tag(Tab.game)
            
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
        
        .fullScreenCover(isPresented: $purchaseManager.showTips) {
            NavigationStack {
                ScrollView {
                    TipJarView()
                }
            }
            
        }
        
        
        .onAppear {
            
            viewModel.startUpdating()

        }
        
    }
}

#Preview {
    ContentViewWatchVersion()
}

