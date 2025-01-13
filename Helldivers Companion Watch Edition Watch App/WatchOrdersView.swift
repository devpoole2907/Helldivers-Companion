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
                    
                    if let mo = viewModel.majorOrder {
                        // Eradication Tasks (Type 3)
                                               if mo.isEradicateType, let eradicationProgresses = mo.eradicationProgress {
                                                   ForEach(eradicationProgresses.indices, id: \.self) { index in
                                                       let progressData = eradicationProgresses[index]
                                                       MajorOrderBarProgressView(
                                                           progress: progressData.progress,
                                                           barColor: mo.faction?.color ?? .white,
                                                           progressString: progressData.progressString
                                                       )
                                                   }
                                               }
                                               
                                               // Defense Tasks (Type 12)
                                               if mo.isDefenseType, let defenseProgresses = mo.defenseProgress {
                                                   ForEach(defenseProgresses.indices, id: \.self) { index in
                                                       let progressData = defenseProgresses[index]
                                                       MajorOrderBarProgressView(
                                                           progress: progressData.progress,
                                                           barColor: .white,
                                                           progressString: progressData.progressString
                                                       )
                                                   }
                                               }
                                               
                                               // Net Quantity Tasks (Type 15)
                                               if mo.isNetQuantityType, let netQuantityProgresses = mo.netQuantityProgress {
                                                   ForEach(netQuantityProgresses.indices, id: \.self) { index in
                                                       let progressData = netQuantityProgresses[index]
                                                       
                                                       // Example TaskStatusView for net quantity
                                                       TaskStatusView(
                                                           taskName: "Liberate more planets than are lost",
                                                           isCompleted: false,
                                                           nameSize: smallFont,
                                                           boxSize: 10
                                                       )
                                                       
                                                       MajorOrderBarProgressView(
                                                           progress: progressData.progress,
                                                           barColor: .blue,
                                                           progressString: progressData.progressString,
                                                           primaryColor: .red
                                                       )
                                                   }
                                               }
                                               
                                               // liberation Tasks (Type 11) also includes 13
                                               
                                               if mo.isLiberationType, !viewModel.updatedTaskPlanets.isEmpty {
                                                   TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                                               }
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
