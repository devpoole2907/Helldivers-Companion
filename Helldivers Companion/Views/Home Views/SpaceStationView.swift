//
//  SpaceStationView.swift
//  Helldivers Companion
//
//  Created by James Poole on 18/01/2025.
//


import SwiftUI

struct SpaceStationView: View {
    var spaceStationExpiration: Date
    var activeTactical: (String, String)? = nil
    var isWidget: Bool
    var showFullInfo: Bool = false
    
    var body: some View {
            ZStack {
        
                Image("dss")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: -1, y: 1)
                    .offset(y: 30)
                    .frame(maxHeight: showFullInfo ? .infinity : (isWidget ? 50 : 60))
                    .clipped()
                
           
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
                            
                            if !showFullInfo && activeTactical != nil {
                                tacticalActionView
                            }
                        }
                      
                        .padding(.leading, 24)
                        
                        if showFullInfo && activeTactical != nil {
                            
                            tacticalActionView.padding(.vertical, 4)
                            
                        }
                    }
                    .padding(.horizontal)
                    if showFullInfo {
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
        }
    
    var tacticalActionView: some View {
        VStack(alignment: .leading) {
            Text(activeTactical?.0 ?? "".uppercased())
                .font(Font.custom("FSSinclair", size: smallFont))
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
                .padding(.horizontal, 8).background(Color.yellow).foregroundStyle(Color.black)
            
            if showFullInfo {
                Text(activeTactical?.1 ?? "")
                    .font(Font.custom("FSSinclair", size: smallFont))
                    .foregroundStyle(.white)
                    .allowsTightening(true)
                    .padding(.top, 2)
            }
        }
    }
    
}
