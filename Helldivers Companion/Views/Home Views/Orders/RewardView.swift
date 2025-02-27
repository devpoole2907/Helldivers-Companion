//
//  RewardView.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct RewardView: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    var rewards: [Setting.Reward]
    var widgetMode = false
    
    var imageSize: CGFloat {
        return widgetMode ? 20 : (rewards.count > 1 ? 18 : 26)
    }
    
    var rewardImage: some View {
        if #available(iOS 18, watchOS 11, *) {
            return Image("medalSymbol")
                .resizable()
                .widgetAccentedRenderingMode(.desaturated)
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
        } else {
            return Image("medalSymbol")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
        }
    }
    
    var body: some View {
        VStack(spacing: widgetMode ? 2 : 6) {
            
            if !(widgetMode && rewards.count > 1) {
                Text("Reward")
                    .textCase(.uppercase)
                    .font(Font.custom("FSSinclair", size: widgetMode ? 14 : 18))
                    .foregroundStyle(.white)
            }
            
            
            ForEach(rewards, id: \.id32) { reward in
                HStack(spacing: 4) {
                    // duct tape, as the current major order response when creating this says the reward is medals - its not, its requistions. mdeal rewards should never be over 1000 anyway so this will work for now.
                    if reward.type == 1 && reward.amount < 1000 {
                        rewardImage
                    } else {
                        VStack(spacing: 2) {
                            Text("R")
                                .font(Font.custom("FSSinclair", size: widgetMode || rewards.count > 1 ? 14 : 18))
                                .padding(.horizontal, 4)
                                .foregroundStyle(Color.black)
                                .background(Color.yellow)
                            Rectangle()
                                .frame(width: 18, height: 4)
                                .foregroundStyle(Color.yellow)
                        }
                    }
                    
                    Text("\(reward.amount)")
                        .font(Font.custom("FSSinclair", size: widgetMode ? 20 : (rewards.count > 1 ? 20 : 26)))
#if os(watchOS)
                        .bold()
                        .shadow(radius: 3)
#endif
                        .foregroundStyle(reward.type == 1 ? .white : .yellow)
                }
#if os(iOS)
                .padding(.vertical, (widgetMode && rewards.count > 1) ? 5 : 10)
                .padding(.horizontal, 18)
                .background(Color.black.opacity(widgetRenderingMode == .accented ? 0.2 : 1))
#endif
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, (widgetMode && rewards.count > 1) ? 5 : 10)
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

