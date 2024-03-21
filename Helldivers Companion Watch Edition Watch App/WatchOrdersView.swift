//
//  WatchOrdersView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

struct WatchOrdersView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    var body: some View {
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
                
                if viewModel.majorOrderTimeRemaining > 0 {
                    
                    MajorOrderTimeView(timeRemaining: viewModel.majorOrderTimeRemaining)
                    
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
    }
}

#Preview {
    WatchOrdersView()
}
