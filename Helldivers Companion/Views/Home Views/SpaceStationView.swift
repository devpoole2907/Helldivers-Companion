//
//  SpaceStationView.swift
//  Helldivers Companion
//
//  Created by James Poole on 18/01/2025.
//


import SwiftUI

struct SpaceStationView: View {
    var spaceStationExpiration: Date
    var spaceStationDetails: SpaceStationDetails? = nil
    var isWidget: Bool
    var showFullInfo: Bool = false
    
    var body: some View {
            ZStack {
        
                if !showFullInfo {
                    Image("dss")
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(x: -1, y: 1)
                        .offset(y: 30)
                        .frame(maxHeight: showFullInfo ? .infinity : (isWidget ? 50 : 60))
                        .clipped()
                    
                }
                
           
                LinearGradient(
                    gradient: Gradient(colors: [.black, .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.multiply)
                .frame(maxHeight: showFullInfo ? .infinity : (isWidget ? 50 : 60))
                
   
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                 
                        HStack(spacing: 3) {
                            Image("dssIcon")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                            
                            Text("Democracy Space Station".uppercased())
                                .font(Font.custom("FSSinclair", size: mediumFont))
                                .bold()
                                .foregroundStyle(.cyan)
                                .lineLimit(1)
                                .allowsTightening(true)
                                .padding(.top, 1)
                        }
                        
                     
                        HStack(spacing: 8) {
                            HStack(spacing: 3) {
                                Text("-- FTL in:").bold()
                                Text(spaceStationExpiration, style: .timer)
                            }  .font(Font.custom("FSSinclair", size: smallFont))
                                .foregroundStyle(.white)
                            
                            // TODO: build small version of first currently active tactical name and expire time, otherwise blank
                            if !showFullInfo && spaceStationDetails != nil {
                               // tacticalActionView
                            }
                        }
                      
                        .padding(.leading, 24)
                        
                        if showFullInfo, let spaceStationDetails = spaceStationDetails {
                         // loop through and show status of each tactical
                            ForEach(spaceStationDetails.tacticalActions, id: \.id32) { tacticalAction in
                                TacticalActionView(tacticalAction: tacticalAction, showFullInfo: showFullInfo)
                                                            .padding(.vertical, 4)
                                                    }
                            
                        }
                    }
                    .padding(.horizontal)
                    if showFullInfo {
                        Spacer()
                    }
                }.padding(showFullInfo ? 8 : 0)
            }
            .frame(maxWidth: .infinity)
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
        }
    
}

struct TacticalActionView: View {
    let tacticalAction: TacticalAction
    let showFullInfo: Bool
    
    var costProgress: Double? {
        guard let cost = tacticalAction.cost.first else { return nil }
        let targetValue = Double(cost.targetValue)
        let currentValue = Double(cost.currentValue)
        
        guard targetValue > 0 else { return nil } // no div by zero
        
        // clamp progress between 0 and 1
        return min(max(currentValue / targetValue, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(tacticalAction.name.uppercased())
                    .font(Font.custom("FSSinclair", size: smallFont))
                    .bold()
                    .lineLimit(1)
                    .allowsTightening(true)
                    .padding(.horizontal, 8)
                    .background(Color.yellow)
                    .foregroundStyle(Color.black)
                
               // cost icon here maybe?
                
            }
            
            if showFullInfo {
                
                // status here
                HStack {
                    Text("\(tacticalAction.status)")
                    
                    if let costProgress = costProgress {
                        Text(String(format: "%.2f%%", costProgress * 100)) // Converts to percentage
                            .font(Font.custom("FSSinclair", size: smallFont))
                            .foregroundStyle(.green)
                    }
                    
                    
                }
                
                
                Text(tacticalAction.strategicDescription)
                    .font(Font.custom("FSSinclair", size: 12))
                    .foregroundStyle(.white)
                    .allowsTightening(true)
            }
        }
    }
}
