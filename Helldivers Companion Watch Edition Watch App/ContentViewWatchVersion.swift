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

                ScrollView {
                    VStack(spacing: 12) {
                        Text(viewModel.majorOrderTitle).bold()
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .font(Font.custom("FS Sinclair", size: 18))
                            .foregroundStyle(.yellow)
                        
                        Text(viewModel.majorOrderBody).bold()
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .font(Font.custom("FS Sinclair", size: 16))
                    }.frame(maxHeight: .infinity)
                    if viewModel.majorOrderRewardValue > 0 {
                        
                        RewardView(rewardType: viewModel.majorOrderRewardType, rewardValue: viewModel.majorOrderRewardValue)
                        
                    }
                    
                    
                    Spacer()
                }.scrollContentBackground(.hidden)
                
  
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("MAJOR ORDER").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: largeFont))
                    }
                }
           
                
                .navigationBarTitleDisplayMode(.inline)
            }
            
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
