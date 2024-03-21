//
//  OrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct OrderView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    
    var body: some View {
        
   
        VStack(spacing: 12) {
                
            VStack(spacing: 12) {
                Text(viewModel.majorOrderTitle).font(Font.custom("FS Sinclair", size: 24))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.majorOrderBody).font(Font.custom("FS Sinclair", size: 18))
                    .foregroundStyle(Color.cyan)
                    .padding(5)
                
                if !viewModel.taskPlanets.isEmpty {
                    TasksView().environmentObject(viewModel)
                }
                
                
            }.frame(maxHeight: .infinity)
            if viewModel.majorOrderRewardValue > 0 {
                RewardView(rewardType: viewModel.majorOrderRewardType, rewardValue: viewModel.majorOrderRewardValue)
            }
            
            if viewModel.majorOrderTimeRemaining > 0 {
                MajorOrderTimeView(timeRemaining: viewModel.majorOrderTimeRemaining)
            }
            
            }  .frame(maxWidth: .infinity) .padding()  .background {
                Color.black
            }
          //  .padding(.horizontal)
          
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
     
        
        
    }
}

#Preview {
    OrderView().environmentObject(PlanetsViewModel())
}


struct TasksView: View {
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    let columns = [
           GridItem(.flexible()),
           GridItem(.flexible()),
       ]
    
    var body: some View {
        
        
        LazyVGrid(columns: columns) {
            ForEach(viewModel.taskPlanets, id: \.self) { planetStatus in
                
         
                    HStack {
                        Rectangle().frame(width: 10, height: 10).foregroundStyle(planetStatus.liberation == 100 ? Color.yellow : Color.black)
                            .border(planetStatus.liberation == 100 ? Color.black : Color.yellow)
                        Text(planetStatus.planet.name).font(Font.custom("FS Sinclair", size: mediumFont))
                    }
                              
                
                
                
                
            }
            
        }
        
    }
}
