//
//  GalaxyInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct GalaxyInfoView: View {
    
    var galaxyStats: GalaxyStats? {
        
        return viewModel.galaxyStats

    }
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    @State var showIlluminateStats = true // for redacted animation
    @State var showRedactedText = false
    
    #if os(iOS)
    let missionsWonSize: CGFloat = 45
    let missionsLostSize: CGFloat = 35
    let successRateSize: CGFloat = 25
    let dividerWidth: CGFloat = 300
    let missionsLostTextSize: CGFloat = 12
    let successRateTextSize: CGFloat = 10
    
    let killsSize: CGFloat = 35
    
    let bugKillsStackSpacing: CGFloat = -10
    let automatonKillsStackSpacing: CGFloat = -8
    let illuminateKillsStackSpacing: CGFloat = -6
    
    let extraStatSplitter = " " // space on ios, to keep it one line
    
    #else
    
    let missionsWonSize: CGFloat = 26
    let dividerWidth: CGFloat = 100
    let missionsLostSize: CGFloat = 26
    let successRateSize: CGFloat = 24
    let missionsLostTextSize: CGFloat = 12
    let successRateTextSize: CGFloat = 12
    let killsSize: CGFloat = 22
    
    let bugKillsStackSpacing: CGFloat = -2
    let automatonKillsStackSpacing: CGFloat = -2
    let illuminateKillsStackSpacing: CGFloat = -2
    
    let extraStatSplitter = "\n" // newline on watchos, to keep it two lines
    
    #endif
    
    
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            
            if let missionsWon = galaxyStats?.missionsWon {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: -10) {
                        Text("\(missionsWon)").textCase(.uppercase).font(Font.custom("FSSinclair", size: missionsWonSize))
                        Text("Missions won").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: mediumFont))
                            .foregroundStyle(.cyan)
                    }
                }
            }
            
            if let missionsLost = galaxyStats?.missionsLost {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: -8) {
                        Text("\(missionsLost)").textCase(.uppercase).font(Font.custom("FSSinclair", size: missionsLostSize))
                        Text("Missions lost").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: missionsLostTextSize))
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if let successRate = galaxyStats?.missionSuccessRate {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: -6) {
                        Text("\(successRate)%").textCase(.uppercase).font(Font.custom("FSSinclair", size: successRateSize))
                        Text("Success rate").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: successRateTextSize))
                            .foregroundStyle(.cyan)
                    }
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
              //  .padding(.bottom, 2)
            
            if let bugKills = galaxyStats?.bugKills {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: bugKillsStackSpacing) {
                        Text("\(bugKills)").textCase(.uppercase).font(Font.custom("FSSinclair", size: killsSize))
                        Text("Terminids killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont)).bold()
                            .foregroundStyle(.yellow)
                    }
                }
            }
            
            if let automatonKills = galaxyStats?.automatonKills {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: automatonKillsStackSpacing) {
                        Text("\(automatonKills)").textCase(.uppercase).font(Font.custom("FSSinclair", size: killsSize))
                        Text("Automatons killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont)).bold()
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if let illuminateKills = galaxyStats?.illuminateKills, showIlluminateStats {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: illuminateKillsStackSpacing) {
                        Text("\(illuminateKills)").textCase(.uppercase).font(Font.custom("FSSinclair", size: killsSize))
                        Text(!showRedactedText ? "Illuminates killed" : "[REDACTED] killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont)).bold()
                            .foregroundStyle(showRedactedText ? .red : .purple)
                            .shake(times: CGFloat(viewModel.redactedShakeTimes))
                    }
                }
                
                .onAppear {
                    // redact the info if the illuminates are not enabled in the config
                    if !viewModel.showIlluminateUI {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        withAnimation(.bouncy(duration: 0.3)) {
                            viewModel.redactedShakeTimes += 1 
                            showRedactedText = true
                        }
                        
                    }
                    
               
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            // hide illuminate
                            withAnimation(.bouncy(duration: 0.5)) {
                                showIlluminateStats = false
                            }
                        }
                    }
                    
                }
                
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
                .padding(.bottom, 4)
            
            if let bulletsFired = galaxyStats?.bulletsFired {
                HStack {
                    Text("Bullets\(extraStatSplitter)Fired").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFired)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let bulletsHit = galaxyStats?.bulletsHit {
                HStack {
                    Text("Bullets\(extraStatSplitter)Hit").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let accuracy = galaxyStats?.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
          //  RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let helldiversLost = galaxyStats?.deaths {
                HStack {
                    Text("Helldivers\(extraStatSplitter)Lost").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let friendlyKills = galaxyStats?.friendlies {
                HStack {
                    Text("Friendly\(extraStatSplitter)Kills").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(friendlyKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            
            
            
            
        }.shadow(radius: 3.0)
        
    }
}
