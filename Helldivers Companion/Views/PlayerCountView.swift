//
//  PlayerCountView.swift
//  Helldivers Companion
//
//  Created by James Poole on 11/04/2024.
//

import SwiftUI
import TipKit

struct PlayerCountView: View {
    
#if os(iOS)
@available(iOS 17.0, *)
    private var tip: PlayerCountTip {
        PlayerCountTip()
}
#endif
    
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    var showFullSize: Bool = false
    
    var fontSize: CGFloat {
        if showFullSize {
            return 30
        } else {
            return 14
        }
    }
    
    var imageSize: CGFloat {
        if showFullSize {
            return 30
        } else {
            return 10
        }
    }
    
    var playerCounter: some View {
        
        HStack(spacing: 4) {
            
            Image("diver").resizable().aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
                .padding(.bottom, 1.8)
            
            Text(showFullSize ? "\(viewModel.totalPlayerCount)" : "\(viewModel.formattedPlayerCount)")
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
                .font(Font.custom("FSSinclair-Bold", size: fontSize))
            
        }
        
    }

    var body: some View {
        
        if #available(iOS 17.0, *) {
            
            Button(action: {
                if !showFullSize {
                    viewModel.showPlayerCount.toggle()
                }
            }){
                playerCounter
                
            }
#if os(iOS)
            .popoverTip(tip)
            .onTapGesture {
                tip.invalidate(reason: .actionPerformed)
            }
            #endif
            
        } else {
            playerCounter
        }
       
    }
}
