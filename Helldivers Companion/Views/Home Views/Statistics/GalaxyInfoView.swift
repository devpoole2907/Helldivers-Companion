//
//  GalaxyInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

struct GalaxyInfoView: View {
    
    var galaxyStats: GalaxyStats? = nil
    
    let showIlluminate: Bool
    
    
    #if os(iOS)
    let missionsWonSize: CGFloat = 50
    let missionsLostSize: CGFloat = 40
    let successRateSize: CGFloat = 30
    let dividerWidth: CGFloat = 300
    let missionsLostTextSize: CGFloat = 16
    let successRateTextSize: CGFloat = 14
    
    let killsSize: CGFloat = 40
    
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
        VStack(alignment: .trailing, spacing: 5) {
            
            if let missionsWon = galaxyStats?.missionsWon {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: -10) {
                        Text("\(missionsWon)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: missionsWonSize))
                        Text("Missions won").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                            .foregroundStyle(.cyan)
                    }
                }
            }
            
            if let missionsLost = galaxyStats?.missionsLost {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: -8) {
                        Text("\(missionsLost)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: missionsLostSize))
                        Text("Missions lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: missionsLostTextSize))
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if let successRate = galaxyStats?.missionSuccessRate {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: -6) {
                        Text("\(successRate)%").textCase(.uppercase).font(Font.custom("FS Sinclair", size: successRateSize))
                        Text("Success rate").textCase(.uppercase).font(Font.custom("FS Sinclair", size: successRateTextSize))
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
                        Text("\(bugKills)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: killsSize))
                        Text("Terminids killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                            .foregroundStyle(.yellow)
                    }
                }
            }
            
            if let automatonKills = galaxyStats?.automatonKills {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: automatonKillsStackSpacing) {
                        Text("\(automatonKills)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: killsSize))
                        Text("Automatons killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if let illuminateKills = galaxyStats?.illuminateKills, showIlluminate {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: illuminateKillsStackSpacing) {
                        Text("\(illuminateKills)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: killsSize))
                        Text("Illuminates killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                            .foregroundStyle(.cyan)
                    }
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
                .padding(.bottom, 4)
            
            if let bulletsFied = galaxyStats?.bulletsFired {
                HStack {
                    Text("Bullets\(extraStatSplitter)Fired").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFied)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let bulletsHit = galaxyStats?.bulletsHit {
                HStack {
                    Text("Bullets\(extraStatSplitter)Hit").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let accuracy = galaxyStats?.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
          //  RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let helldiversLost = galaxyStats?.deaths {
                HStack {
                    Text("Helldivers\(extraStatSplitter)Lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let friendlyKills = galaxyStats?.friendlies {
                HStack {
                    Text("Friendly\(extraStatSplitter)Kills").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(friendlyKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            
            
            
            
        }.shadow(radius: 3.0)
        
    }
}

#Preview {
    GalaxyInfoView(showIlluminate: true)
}
