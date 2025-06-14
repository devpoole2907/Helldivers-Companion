//
//  OrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct OrderView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack(alignment: .top) {

        ScrollView {
            VStack(spacing: 12) {
                if viewModel.majorOrders.isEmpty {
                    VStack(spacing: 12) {
                        Text("Stand by.")
                            .font(Font.custom("FSSinclair-Bold", size: 24))
                            .foregroundStyle(Color.yellow)
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)

                        Text("Await further orders from Super Earth High Command.")
                            .font(Font.custom("FSSinclair", size: 18))
                            .foregroundStyle(Color(red: 164, green: 177, blue: 183))
                            .padding(5)
                            .multilineTextAlignment(.center)
                    }.padding(.top, 30)
                } else {
                    ForEach(viewModel.majorOrders, id: \.id32) { mo in
                    VStack(spacing: 12) {
                        Text(mo.setting.taskDescription)
                            .font(Font.custom("FSSinclair-Bold", size: 24))
                            .foregroundStyle(Color.yellow)
                            .textCase(.uppercase)
                            .multilineTextAlignment(.center)

                        Text(mo.setting.overrideBrief)
                            .font(Font.custom("FSSinclair", size: 18))
                            .foregroundStyle(Color(red: 164, green: 177, blue: 183))
                            .padding(5)
                            .multilineTextAlignment(.center)

                        if mo.isExtractType, let extractionProgress = mo.extractionProgress {
                            ForEach(extractionProgress.indices, id: \.self) { index in
                                let progressData = extractionProgress[index]
                                VStack(spacing: 2){
                                    Text(progressData.description)
                                        .font(Font.custom("FSSinclair-Bold", size: smallFont))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                    MajorOrderBarProgressView(
                                        progress: progressData.progress,
                                        barColor: Color(red: 164, green: 177, blue: 183),
                                        progressString: progressData.progressString
                                    )
                                }
                            }
                        }

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
                                let taskDescription = mo.defenseTasks[index].description
                                VStack(spacing: 2) {
                                    Text(taskDescription)
                                        .font(Font.custom("FSSinclair-Bold", size: smallFont))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                    MajorOrderBarProgressView(
                                        progress: progressData.progress,
                                        barColor: mo.faction?.color ?? .white,
                                        progressString: progressData.progressString
                                    )
                                }
                            }
                        }

                        if mo.isNetQuantityType, let netQuantityProgresses = mo.netQuantityProgress {
                            ForEach(netQuantityProgresses.indices, id: \.self) { index in
                                let progressData = netQuantityProgresses[index]
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

                        if mo.isLiberationType, !viewModel.updatedTaskPlanets.isEmpty {
                            TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                        }

                        if mo.isMissionExtractType, let missionExtractProgresses = mo.missionExtractProgress {
                            ForEach(missionExtractProgresses.indices, id: \.self) { index in
                                let progressData = missionExtractProgresses[index]
                                VStack(spacing: 2){
                                    Text(progressData.description)
                                        .font(Font.custom("FSSinclair-Bold", size: smallFont))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                    MajorOrderBarProgressView(
                                        progress: progressData.progress,
                                        barColor: Color.purple,
                                        progressString: progressData.progressString
                                    )
                                }
                            }
                        }

                        if let firstReward = mo.allRewards.first, firstReward.amount > 0 {
                            if #available(watchOS 9.0, *) {
                                RewardView(rewards: mo.allRewards)
                            }
                        }

                        if mo.expiresIn > 0 {
                            OrderTimeView(timeRemaining: mo.expiresIn)
                        }
                    }
                    }
                }
            }
            .padding(.top, 15)
            .padding()
        }.scrollContentBackground(.hidden)
    #if os(iOS)
                .frame(maxHeight: viewModel.majorOrders.isEmpty ? 200 : UIScreen.main.bounds.height * 0.6)
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

#Preview {
    OrderView().environmentObject(PlanetsDataModel())
}


struct TasksView: View {
    
    var taskPlanets: [UpdatedPlanet]
    
    var isWidget = false
    
    let columns = [
           GridItem(.flexible(maximum: 190)),
           GridItem(.flexible(maximum: 190)),
       ]
    
    var nameSize: CGFloat {
        return isWidget ? 14 : mediumFont
    }
    
    var boxSize: CGFloat {
        return isWidget ? 7 : 10
    }
    
    var body: some View {
        
       // curently using task progress from major order response
        LazyVGrid(columns: columns) {
            ForEach(taskPlanets, id: \.self) { planet in
                
                TaskStatusView(taskName: planet.name, isCompleted: planet.taskProgress == 1, nameSize: nameSize, boxSize: boxSize, planet: planet)
                
            }
            
        }
        
    }
}

struct MajorOrderBarProgressView: View {
    
    var progress: Double
    var barColor: Color
    var progressString: String
    var isWidget = false
    var primaryColor: Color = .cyan
    
    var body: some View {
        
        ZStack {
            RectangleProgressBar(value: progress, primaryColor: primaryColor, secondaryColor: barColor)
                .frame(height: 16)
            
            Text("\(progressString)")
            #if os(iOS)
                .font(Font.custom("FSSinclair", size: isWidget ? 8 : 16))
            #else
                .font(Font.custom("FSSinclair", size: 10))
            
            #endif
                
                .foregroundStyle(Color.black)
                .minimumScaleFactor(0.6)
            
        }.padding(.bottom, 10)
            .padding(.horizontal, 14)
        
        
    }
    
}

struct TaskStatusView: View {
    var taskName: String
    var isCompleted: Bool
    var nameSize: CGFloat
    var boxSize: CGFloat
    var planet: UpdatedPlanet? = nil

    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .frame(width: boxSize, height: boxSize)
                    .foregroundStyle(isCompleted ? Color.yellow : Color.black)
                    .border(isCompleted ? Color.black : Color.yellow)
                VStack(alignment: .leading, spacing: 4) {
                    Text(taskName)
                        .font(Font.custom("FSSinclair", size: nameSize))
                        .foregroundStyle(.white)
                    if let planetProgressPercent = planet?.planetProgressPercent {
                        RectangleProgressBar(value: planetProgressPercent / 100, primaryColor: .cyan, secondaryColor: .orange, height: 4)
                            .frame(maxWidth: 40)
                    }
                    
                    
                }
            }
            
        }
    }
}
