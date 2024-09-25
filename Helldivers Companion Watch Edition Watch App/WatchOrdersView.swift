//
//  WatchOrdersView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct WatchOrdersView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
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
                        
                  

                    } else if let isNetQuantityType = viewModel.majorOrder?.isNetQuantityType, isNetQuantityType == true, let progress = viewModel.majorOrder?.progress.first {
                        
                        let maxProgressValue: Double = 10 // assumes 10 is the max value either way for normalization (planets cpatured or lost)
                        let normalizedProgress: Double = 1 - (Double(progress) + maxProgressValue) / (2 * maxProgressValue)
                        
                        TaskStatusView(
                                taskName: "Liberate more planets than are lost during the order duration.",
                                isCompleted: false,
                                nameSize: smallFont,
                                boxSize: 10
                            )
                        
                        MajorOrderBarProgressView(progress: normalizedProgress, barColor: .blue, progressString: "\(progress)", primaryColor: .red)
                    } else if !viewModel.updatedTaskPlanets.isEmpty { // lib type
                        TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                    }
                    
                }.frame(maxHeight: .infinity)
               
                if let firstReward = viewModel.majorOrder?.allRewards.first, firstReward.amount > 0 {
                    RewardView(rewards: viewModel.majorOrder?.allRewards ?? [])
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
