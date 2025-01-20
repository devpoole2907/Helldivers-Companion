//
//  PersonalOrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/01/2025.
//


import SwiftUI

struct PersonalOrderView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack(alignment: .top) {

        VStack(spacing: 12) {
            
            // this all needs to be refactored, never properly went back after discovering new MO types a while ago
            
            VStack(spacing: 12) {
                Text(viewModel.majorOrder?.setting.taskDescription ?? "Stand by.").font(Font.custom("FSSinclair-Bold", size: 24))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.majorOrder?.setting.overrideBrief ?? "Await further orders from Super Earth High Command.").font(Font.custom("FSSinclair", size: 18))
                    .foregroundStyle(Color(red: 164, green: 177, blue: 183))
                    .padding(5)
                    .multilineTextAlignment(.center)
                
                if let mo = viewModel.majorOrder {
                    
                    // MARK: - Eradication Tasks (Type 3)
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
                    
                    // MARK: - Defense Tasks (Type 12)
                                        if mo.isDefenseType, let defenseProgresses = mo.defenseProgress {
                                            ForEach(defenseProgresses.indices, id: \.self) { index in
                                                let progressData = defenseProgresses[index]
                                                MajorOrderBarProgressView(
                                                    progress: progressData.progress,
                                                    barColor: mo.faction?.color ?? .white,
                                                    progressString: progressData.progressString
                                                )
                                            }
                                        }
                    
                    // MARK: - Net Quantity Tasks (Type 15)
                                        if mo.isNetQuantityType, let netQuantityProgresses = mo.netQuantityProgress {
                                            ForEach(netQuantityProgresses.indices, id: \.self) { index in
                                                let progressData = netQuantityProgresses[index]
                                                
                                                // Optional Task Status for net quantity
                                                TaskStatusView(
                                                    taskName: "Liberate more planets than are lost",
                                                    isCompleted: false,
                                                    nameSize: 16,
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
                    
                    // MARK: - Liberation Tasks (Type 11)
                                        // Using your existing logic for updatedTaskPlanets
                                        if mo.isLiberationType, !viewModel.updatedTaskPlanets.isEmpty {
                                            TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                                        }
                    
                }
                
            }
            
            if let firstReward = viewModel.personalOrder?.allRewards.first, firstReward.amount > 0 {
                if #available(watchOS 9.0, *) {
                    RewardView(rewards: viewModel.personalOrder?.allRewards ?? [])
            }
            }
            
            if let personalOrderTimeRemaining = viewModel.personalOrder?.expiresIn,  personalOrderTimeRemaining > 0 {
                OrderTimeView(timeRemaining: personalOrderTimeRemaining, orderType: .personal)
            }
            
        }.padding(.top, 40)
                .padding()
            #if os(iOS)
                .frame(width: isIpad ? 560 : UIScreen.main.bounds.width - 44)
                .frame(minHeight: 300)
            #endif
                .background {
            Color.black
        }
            
      
        
    }
        .border(Color.white)
        .padding(4)
        .border(Color.gray)
         
        
    
        
    }
}
