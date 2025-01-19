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
    var warTime: Int64? = nil
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
                                TacticalActionView(tacticalAction: tacticalAction, warTime: warTime, showFullInfo: showFullInfo)
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
    var warTime: Int64? = nil
    let showFullInfo: Bool
    
    var costProgress: Double? {
        guard let cost = tacticalAction.cost.first else { return nil }
        let targetValue = Double(cost.targetValue)
        let currentValue = Double(cost.currentValue)
        
        guard targetValue > 0 else { return nil } // no div by zero
        
        // clamp progress between 0 and 1
        return min(max(currentValue / targetValue, 0), 1)
    }
    
    var expirationDate: Date? {
        guard let warTime = warTime else { print("no war time")
            return nil }
        let secondsFromNow = Int64(tacticalAction.statusExpireAtWarTimeSeconds) - warTime
        guard secondsFromNow > 0 else { return nil }
        return Date().addingTimeInterval(TimeInterval(secondsFromNow))
    }
    
    var costType: String? {
        guard let cost = tacticalAction.cost.first else { return nil }
        switch cost.itemMixId {

        case 3992382197:
            return "commonSample"
        case 3608481516:
            return "requisitionSlip"
        case 2985106497:
            return "rareSample"
        default:
            return nil
            
        }
    }
    
    var costDetails: String? {
            guard let cost = tacticalAction.cost.first else { return nil }
            let currentValue = Int(cost.currentValue)
            let targetValue = Int(cost.targetValue)
            return "\(currentValue / 1_000)K / \(targetValue / 1_000)K"
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
                HStack(spacing: 8) {
                                    switch tacticalAction.status {
                                    case 1: // cost progress
                                        HStack(spacing: 5) {
                                            if let costProgress = costProgress, let costDetails = costDetails {
                                                if let costType = costType {
                                                    Image(costType).resizable().aspectRatio(contentMode: .fill).frame(width: costType == "requisitionSlip" ? 40 : 12, height: costType == "requisitionSlip" ? 40 : 12)
                                                }
                                                Group {
                                                    Text(String(format: "%.2f%%", costProgress * 100))
                                                        .foregroundStyle(.green)
                                                    
                                                    Divider().foregroundStyle(.white)
                                                        .frame(width: 3, height: 10)
                                                    
                                                    Text(costDetails)
                                                   
                                                        .foregroundStyle(.white)
                                                }
                                                .font(Font.custom("FSSinclair", size: smallFont))
                                                .padding(.top, 1)
                                                
                                            } else {
                                                Text("No progress available")
                                                    .font(Font.custom("FSSinclair", size: smallFont))
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                    case 2:
                                        if let expirationDate = expirationDate {
                                            Group {
                                                Text("ACTIVE FOR:").bold()
                                                Text(expirationDate, style: .timer)
                                            }
                                                .font(Font.custom("FSSinclair", size: smallFont))
                                                .foregroundStyle(.cyan)
                                        } else {
                                            Text("Timer unavailable")
                                                .font(Font.custom("FSSinclair", size: smallFont))
                                                .foregroundStyle(.gray)
                                        }
                                    case 3: // active and cooldown, time until expired
                                        if let expirationDate = expirationDate {
                                            Group {
                                                Text("AVAILABLE IN:").bold()
                                                Text(expirationDate, style: .timer)
                                                
                                            }
                                                .font(Font.custom("FSSinclair", size: smallFont))
                                                .foregroundStyle(.red)
                                        } else {
                                            Text("Timer unavailable")
                                                .font(Font.custom("FSSinclair", size: smallFont))
                                                .foregroundStyle(.gray)
                                        }
                                    default: // fall back
                                        Text("Status: \(tacticalAction.status)")
                                            .font(Font.custom("FSSinclair", size: smallFont))
                                            .foregroundStyle(.gray)
                                    }
                                }
                
                if let description = removeHTMLTags(from: tacticalAction.strategicDescription) {
                    Text(description)
                        .font(Font.custom("FSSinclair", size: 12))
                        .foregroundStyle(.white)
                        .allowsTightening(true)
                }
                
            
            }
        }
    }
}
