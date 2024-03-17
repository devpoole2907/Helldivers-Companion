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
            
            NavigationStack {
                
              //  OrderView()
            
                    Text(viewModel.majorOrderString).bold()
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                Spacer()
                
  
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("MAJOR ORDER").textCase(.uppercase).fontWeight(.heavy)
                    }
                }
           
                
                .navigationBarTitleDisplayMode(.inline)
            }
            
        }.background {
            Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
        }
        
    }
}

#Preview {
    ContentViewWatchVersion()
}
