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
                VStack(spacing: 24) {
                    ForEach(viewModel.majorOrders, id: \.id32) { mo in
                        VStack(spacing: 12) {
                            Text(mo.setting.taskDescription)
                                .bold()
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                .font(Font.custom("FSSinclair", size: 18))
                                .foregroundStyle(.yellow)

                            Text(mo.setting.overrideBrief)
                                .bold()
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                .font(Font.custom("FSSinclair", size: 16))

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

                            if mo.isNetQuantityType, let netQuantityProgresses = mo.netQuantityProgress {
                                ForEach(netQuantityProgresses.indices, id: \.self) { index in
                                    let progressData = netQuantityProgresses[index]
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

                            if mo.isLiberationType, !viewModel.updatedTaskPlanets.isEmpty {
                                TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                            }

                            if let firstReward = mo.allRewards.first, firstReward.amount > 0 {
                                RewardView(rewards: mo.allRewards)
                            }

                            if mo.expiresIn > 0 {
                                OrderTimeView(timeRemaining: mo.expiresIn)
                            }
                        }
                        .padding(.bottom)
                    }
                }
                .frame(maxHeight: .infinity)
                Spacer()
            }
            .scrollContentBackground(.hidden)
            

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
