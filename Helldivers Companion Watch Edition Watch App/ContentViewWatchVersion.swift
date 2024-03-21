//
//  ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI

struct ContentViewWatchVersion: View {
    
    @StateObject var viewModel = PlanetsViewModel()
    
    var body: some View {
       
        TabView {
            
            ContentView().environmentObject(viewModel)
            
            WatchOrdersView().environmentObject(viewModel)
            
            NewsView()
 
           
                
                .navigationBarTitleDisplayMode(.inline)
            
        }.background {
            Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
        }
        
    }
}

#Preview {
    ContentViewWatchVersion()
}
