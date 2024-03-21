//
//  OrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct OrderView: View {
    
    var majorOrderTitle: String = "Stand by."
    var majorOrderBody: String = "Await further orders from Super Earth High Command."
    var rewardValue: Int = 25
    var rewardType: Int = 1
    var endsIn: Int = 0
    
    var body: some View {
        
   
        VStack(spacing: 12) {
                
            VStack(spacing: 12) {
                Text(majorOrderTitle).font(Font.custom("FS Sinclair", size: 24))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                
                Text(majorOrderBody).font(Font.custom("FS Sinclair", size: 18))
                    .foregroundStyle(Color.cyan)
                    .padding(5)
                
                
            }.frame(maxHeight: .infinity)
            if rewardValue > 0 {
                RewardView(rewardType: rewardType, rewardValue: rewardValue)
            }
            
            if endsIn > 0 {
                MajorOrderTimeView(timeRemaining: endsIn)
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
    OrderView()
}


