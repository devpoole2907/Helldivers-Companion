//
//  OrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct OrderView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack(alignment: .top) {

        VStack(spacing: 12) {
            
            
            
            VStack(spacing: 12) {
                Text(viewModel.majorOrder?.setting.taskDescription ?? "Stand by.").font(Font.custom("FS Sinclair Bold", size: 24))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.majorOrder?.setting.overrideBrief ?? "Await further orders from Super Earth High Command.").font(Font.custom("FS Sinclair", size: 18))
                    .foregroundStyle(Color(red: 164, green: 177, blue: 183))
                    .padding(5)
                    .multilineTextAlignment(.center)
                
                if !viewModel.updatedTaskPlanets.isEmpty {
                    TasksView(taskPlanets: viewModel.updatedTaskPlanets)
                }
                
                
            }
            if let majorOrderRewardValue = viewModel.majorOrder?.setting.reward.amount, majorOrderRewardValue > 0 {
                RewardView(rewardType: viewModel.majorOrder?.setting.reward.type, rewardValue: majorOrderRewardValue)
            }
            
            if let majorOrderTimeRemaining = viewModel.majorOrder?.expiresIn,  majorOrderTimeRemaining > 0 {
                MajorOrderTimeView(timeRemaining: majorOrderTimeRemaining)
            }
            
        }.padding(.top, 40)
                .padding() 
            #if os(iOS)
                .frame(width: UIScreen.main.bounds.width - 44)
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
    OrderView().environmentObject(PlanetsViewModel())
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
                
         
                    HStack {
                        Rectangle().frame(width: boxSize, height: boxSize).foregroundStyle(planet.taskProgress == 1 ? Color.yellow : Color.black)
                            .border(planet.taskProgress == 1 ? Color.black : Color.yellow)
                        Text(planet.name).font(Font.custom("FS Sinclair", size: nameSize)).foregroundStyle(.white)
                    }
                              
                
                
                
                
            }
            
        }
        
    }
}
