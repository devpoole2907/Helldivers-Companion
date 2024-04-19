//
//  RewardView.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

struct RewardView: View {
    
    var rewardType: Int? = 1
    var rewardValue: Int = 0
    
    var widgetMode = false
    
    var imageSize: CGFloat {
        return widgetMode ? 20 : 26
    }
    
    var body: some View {
        VStack(spacing: widgetMode ? 2 : 6) {
            Text("Reward").textCase(.uppercase).font(Font.custom("FSSinclair", size: widgetMode ? 14 : 18)).foregroundStyle(.white)
            
            HStack(spacing: 4) {
                
                if rewardType == 1 {
                    Image("medalSymbol").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                } else {
                    VStack(spacing: 2){
                        Text("R").font(Font.custom("FSSinclair", size: smallFont)).padding(.horizontal, 4).foregroundStyle(Color.black).background(Color.yellow)
                        Rectangle().frame(width: 18, height: 4)
                            .foregroundStyle(Color.yellow)
                    }
                }
                
                Text("\(rewardValue)").font(Font.custom("FSSinclair", size: widgetMode ? 20 : 26))
                #if os(watchOS)
                    .bold()
                    .shadow(radius: 3)
                #endif
                    .foregroundStyle(rewardType == 1 ? .white : .yellow)
                
            }
            #if os(iOS)
            .padding(.vertical, 10)
                .padding(.horizontal, 30).background {
                    Color.black
            }
            #endif
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            AngledLinesShape()
                .stroke(lineWidth: 3)
                .foregroundColor(.white)
                .opacity(0.2)
                .clipped()
        )
        .padding(.horizontal, 14)
        
    }
    
    
    
}

#Preview {
    RewardView()
}
