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
           
                if let personalOrder = viewModel.personalOrder {
                    ForEach(personalOrder.setting.tasks, id: \.self) { task in
                            Text(task.description)
                                .font(Font.custom("FSSinclair-Bold", size: 18))
                                .foregroundStyle(.white)
                                .padding(5)
                                .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Stand by.")
                        .font(Font.custom("FSSinclair-Bold", size: 24))
                        .foregroundStyle(Color.yellow)
                        .textCase(.uppercase)
                        .multilineTextAlignment(.center)
                    
                    Text("Await further orders from Super Earth High Command.")
                        .font(Font.custom("FSSinclair", size: 18))
                        .foregroundStyle(Color(red: 164/255, green: 177/255, blue: 183/255))
                        .padding(5)
                        .multilineTextAlignment(.center)
                }
                
            
            
            if let firstReward = viewModel.personalOrder?.allRewards.first, firstReward.amount > 0 {
                if #available(watchOS 9.0, *) {
                    RewardView(rewards: viewModel.personalOrder?.allRewards ?? [])
            }
            }
            
            if let personalOrderTimeRemaining = viewModel.personalOrder?.expiresIn,  personalOrderTimeRemaining > 0 {
                OrderTimeView(timeRemaining: personalOrderTimeRemaining, orderType: .personal)
            }
            
        }.padding(.top, 30)
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
