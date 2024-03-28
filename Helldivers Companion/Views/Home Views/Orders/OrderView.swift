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
        
        ZStack(alignment: .top) {

        VStack(spacing: 12) {
            
            
            
            VStack(spacing: 12) {
                Text(viewModel.majorOrder?.setting.taskDescription ?? "Stand by.").font(Font.custom("FS Sinclair", size: 24))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.majorOrder?.setting.overrideBrief ?? "Await further orders from Super Earth High Command.").font(Font.custom("FS Sinclair", size: 18))
                    .foregroundStyle(Color.cyan)
                    .padding(5)
                
                if !viewModel.taskPlanets.isEmpty {
                    TasksView(taskPlanets: viewModel.taskPlanets)
                }
                
                
            }
            if let majorOrderRewardValue = viewModel.majorOrder?.setting.reward.amount, majorOrderRewardValue > 0 {
                RewardView(rewardType: viewModel.majorOrder?.setting.reward.type, rewardValue: majorOrderRewardValue)
            }
            
            if let majorOrderTimeRemaining = viewModel.majorOrder?.expiresIn,  majorOrderTimeRemaining > 0 {
                MajorOrderTimeView(timeRemaining: majorOrderTimeRemaining)
            }
            
        }.padding(.top, 40)
                .padding()  .background {
            Color.black
        }
            
        //  .padding(.horizontal)
            
            ZStack(alignment: .center) {
                Image("MajorOrdersBanner").resizable()
#if os(iOS)
                    .frame(width: UIScreen.main.bounds.width - 20, height: 45)
#endif
                    .offset(CGSize(width: 5, height: 0))
               //     .clipShape(Rectangle())
                //   .border(Color.white, width: 2)
                // .padding(.bottom)
                    .opacity(0.8)
                
                
                
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Image(systemName: "scope").bold()
                    
                    Text("MAJOR ORDER").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 24))
                    
                }.padding(.trailing, 60)
                
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
    
    var taskPlanets: [PlanetStatus]
    
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
        
        
        LazyVGrid(columns: columns) {
            ForEach(taskPlanets, id: \.self) { planetStatus in
                
         
                    HStack {
                        Rectangle().frame(width: boxSize, height: boxSize).foregroundStyle(planetStatus.liberation == 100 ? Color.yellow : Color.black)
                            .border(planetStatus.liberation == 100 ? Color.black : Color.yellow)
                        Text(planetStatus.planet.name).font(Font.custom("FS Sinclair", size: nameSize)).foregroundStyle(.white)
                    }
                              
                
                
                
                
            }
            
        }
        
    }
}
