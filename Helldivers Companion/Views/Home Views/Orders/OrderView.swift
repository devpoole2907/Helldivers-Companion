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
                
                if let isEradication = viewModel.majorOrder?.isEradicateType, let eradicationProgress = viewModel.majorOrder?.eradicationProgress, let barColor = viewModel.majorOrder?.faction?.color, let progressString = viewModel.majorOrder?.progressString {
                    
                    
                    // eradicate campaign
                   
                   MajorOrderBarProgressView(progress: eradicationProgress, barColor: barColor, progressString: progressString)

                } else if let isDefenseType = viewModel.majorOrder?.isDefenseType, let defenseProgress = viewModel.majorOrder?.defenseProgress, let progressString = viewModel.majorOrder?.progressString {       // defense campaign
                    
                    MajorOrderBarProgressView(progress: defenseProgress, barColor: .white, progressString: progressString)
                    
              
                    // temp fix for broken orders sept 2024
                } else if !viewModel.updatedTaskPlanets.isEmpty { // liberation/type 11
                    TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                } else if let orderType = viewModel.majorOrder?.setting.type, orderType == 4, let progress = viewModel.majorOrder?.progress.first {
                    
                    let maxProgressValue: Double = 10 // assumes 10 is the max value either way for normalization (planets cpatured or lost)
                    let normalizedProgress: Double = 1 - (Double(progress) + maxProgressValue) / (2 * maxProgressValue)
                    
                    TaskStatusView(
                            taskName: "Liberate more planets than are lost during the order duration.",
                            isCompleted: false,
                            nameSize: smallFont,
                            boxSize: 10
                        )
                    
                    MajorOrderBarProgressView(progress: normalizedProgress, barColor: .blue, progressString: "\(progress)", primaryColor: .red)
                }
                
                
            }
            
            if let firstReward = viewModel.majorOrder?.allRewards.first, firstReward.amount > 0 {
                RewardView(rewards: viewModel.majorOrder?.allRewards ?? [])
            }
            
            if let majorOrderTimeRemaining = viewModel.majorOrder?.expiresIn,  majorOrderTimeRemaining > 0 {
                MajorOrderTimeView(timeRemaining: majorOrderTimeRemaining)
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
                
                TaskStatusView(taskName: planet.name, isCompleted: planet.taskProgress == 1, nameSize: nameSize, boxSize: boxSize)
                
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
                
                .foregroundStyle(.black)
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

    var body: some View {
        HStack {
            Rectangle()
                .frame(width: boxSize, height: boxSize)
                .foregroundStyle(isCompleted ? Color.yellow : Color.black)
                .border(isCompleted ? Color.black : Color.yellow)
            Text(taskName)
                .font(Font.custom("FSSinclair", size: nameSize))
                .foregroundStyle(.white)
        }
    }
}

