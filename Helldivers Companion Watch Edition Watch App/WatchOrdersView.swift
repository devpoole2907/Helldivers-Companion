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
                    Text(viewModel.majorOrder?.setting.taskDescription ?? "Stand by.").bold()
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("FS Sinclair", size: 18))
                        .foregroundStyle(.yellow)
                    
                    Text(viewModel.majorOrder?.setting.overrideBrief ?? "Await further orders from Super Earth High Command.").bold()
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("FS Sinclair", size: 16))

                    if !viewModel.taskPlanets.isEmpty {
                        TasksView(taskPlanets: viewModel.taskPlanets)
                    }
                    
                }.frame(maxHeight: .infinity)
                if let majorOrderRewardValue = viewModel.majorOrder?.setting.reward.amount, majorOrderRewardValue > 0 {
                    RewardView(rewardType: viewModel.majorOrder?.setting.reward.type, rewardValue: majorOrderRewardValue)
                    
                }
                
                if let majorOrderTimeRemaining = viewModel.majorOrder?.expiresIn,  majorOrderTimeRemaining > 0 {
                    MajorOrderTimeView(timeRemaining: majorOrderTimeRemaining)
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
