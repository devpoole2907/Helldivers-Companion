//
//  WatchOrdersView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct WatchOrdersView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    var body: some View {
        NavigationStack {

            ScrollView {
                VStack(spacing: 12) {
                    Text(viewModel.majorOrder?.setting.taskDescription ?? "Stand by.").bold()
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("FSSinclair", size: 18))
                        .foregroundStyle(.yellow)
                    
                    Text(viewModel.majorOrder?.setting.overrideBrief ?? "Await further orders from Super Earth High Command.").bold()
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("FSSinclair", size: 16))

                    if let isEradication = viewModel.majorOrder?.isEradicateType, let eradicationProgress = viewModel.majorOrder?.eradicationProgress, let barColor = viewModel.majorOrder?.faction?.color, let progressString = viewModel.majorOrder?.progressString {

                        // eradicate campaign
                        MajorOrderBarProgressView(progress: eradicationProgress, barColor: barColor, progressString: progressString)

                    } else if let isDefenseType = viewModel.majorOrder?.isDefenseType, let defenseProgress = viewModel.majorOrder?.defenseProgress, let progressString = viewModel.majorOrder?.progressString {       // defense campaign
                        
                        MajorOrderBarProgressView(progress: defenseProgress, barColor: .white, progressString: progressString)
                        
                  

                    } else if !viewModel.updatedTaskPlanets.isEmpty { // lib type
                        TasksView(taskPlanets: viewModel.updatedTaskPlanets)
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
                if #available(watchOS 10, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("MAJOR ORDER").textCase(.uppercase)  .font(Font.custom("FSSinclair-Bold", size: largeFont))
                    }
                }
            }
       
            
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
