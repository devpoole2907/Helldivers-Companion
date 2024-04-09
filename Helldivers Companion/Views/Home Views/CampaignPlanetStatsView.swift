//
//  CampaignPlanetStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI

struct CampaignPlanetStatsView: View {
    
    var liberation: Double
    var liberationType: LiberationType
    
    var showExtraStats: Bool
    
    var planetName: String
    
    var planet: UpdatedPlanet? = nil
    
    var factionColor: Color // color is passed to this view as widgets dont have the required state to calculate the color from the view model
    var factionImage: String // same reason as above
    
    var playerCount: Int64 = 347246
    
    var isWidget = false
    
    var eventExpirationTime: Date? = nil
    
    var isActive = true // if accessed from galaxy map, planet view wont need to display all info if the planet isnt in a campaign
    
    @State private var pulsate = false
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
#if os(iOS)
let helldiverImageSize: CGFloat = 25
    let raceIconSize: CGFloat = 25
    let spacingSize: CGFloat = 10
    
#elseif os(watchOS)
    let helldiverImageSize: CGFloat = 10
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 4
    
    #endif
    
    var body: some View {
        

        VStack(spacing: 0) {
            
            VStack {
                HStack {
                    
                    // health bar
                    
                    RectangleProgressBar(value: liberation / 100, secondaryColor: factionColor)
                    
                        .padding(.horizontal, 6)
                        .padding(.trailing, 2)
                    
                    
                }.frame(height: showExtraStats ? 34 : 30)
                    .foregroundStyle(Color.clear)
                    .border(Color.orange, width: 2)
                    .padding(.horizontal, 4)
            }  .padding(.vertical, 5)
            
            Rectangle()
                .fill(.white)
                .frame(height: 1)
            
            VStack {
                HStack{
                    // funky zstack stuff for the widget, because the text.datestyle is so wide by default
                    ZStack {
                        HStack {
                            Text("\(liberation, specifier: "%.3f")% \(liberationType == .liberation ? "Liberated" : "Defended")").textCase(.uppercase)
                                .foregroundStyle(.white).bold()
                                .font(Font.custom("FS Sinclair", size: showExtraStats ? mediumFont : smallFont))
                                .multilineTextAlignment(.leading)
                            if isWidget && !showExtraStats, let _ = eventExpirationTime {
                                Spacer()
                            }
                        }
                        
                        if isWidget && !showExtraStats, let eventExpirationTime = eventExpirationTime {
                            HStack {
                                Spacer()
                                Text(eventExpirationTime, style: .timer)
                                    .font(Font.custom("FS Sinclair", size: smallFont))
                                    .foregroundStyle(.red)
                                    .monospacedDigit()
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    if let liberationRate = viewModel.averageLiberationRate(for: planetName), viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet?.index }) {
                        Spacer()
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .padding(.top, 2)
                            Text("\(liberationRate, specifier: "%.2f")% / h")
                                .foregroundStyle(.white)
                                .font(Font.custom("FS Sinclair", size: showExtraStats ? mediumFont : smallFont))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                }   .padding(.horizontal)
                
            }
            .frame(maxWidth: .infinity)
            .background {
                //    Color.black
            }
            .padding(.vertical, 5)
            
            
            
            
        }
        .border(Color.white)
        .padding(4)
        .border(Color.gray)
        
    
        
        
        if showExtraStats {
            HStack {
                
                if isActive { // dont show this section if planet isnt in a campaign (accessed via galaxy map)
                
                HStack(alignment: .center, spacing: spacingSize) {
                    
                    if liberationType == .liberation {
                        
                        Image(factionImage).resizable().aspectRatio(contentMode: .fit)
                            .frame(width: raceIconSize, height: raceIconSize)
                        
                        if let regenPerSecond = planet?.regenPerSecond, let maxHealth = planet?.maxHealth {
                           
                            let regenPerHour = regenPerSecond * 3600.0
                            let regenPercent = (regenPerHour / Double(maxHealth)) * 100
                            Text(String(format: "-%.1f%% / h", regenPercent))
                                .foregroundStyle(factionColor).bold()
                                .font(Font.custom("FS Sinclair", size: mediumFont))
                                .padding(.top, 3)
                            
                        }
                        
                    } else {
                        VStack(spacing: -5) {
                            Text("DEFEND") .font(Font.custom("FS Sinclair", size: largeFont)).bold()
                            
                            // defense is important, so pulsate
                                .foregroundStyle(isWidget ? .red : (pulsate ? .red : .white))
                                .opacity(isWidget ? 1.0 : (pulsate ? 1.0 : 0.0))
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulsate)
                            
                                .onAppear {
                                    pulsate = true
                                }
                            if let eventExpirationTime = eventExpirationTime {
                                Text(eventExpirationTime, style: .timer)
                                    .font(Font.custom("FS Sinclair", size: mediumFont))
                                    .multilineTextAlignment(.center)
                                // .frame(maxWidth: .infinity)
                            }
                        }.padding(.vertical, 6)
                        
                    }
                    
                }.frame(maxWidth: .infinity)
                
                Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                    .padding(.vertical, 10)
                
            }
            
            HStack(spacing: spacingSize) {
                
                
                Image("diver").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: helldiverImageSize, height: helldiverImageSize)
                Text("\(playerCount)").textCase(.uppercase)
                    .foregroundStyle(.white).bold()
                    .font(Font.custom("FS Sinclair", size: mediumFont))
                    .padding(.top, 3)
                
            }  .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 30)
            
            
        }
        
        .background {
          //  Color.black
        }
        .padding(.horizontal)
        .border(Color.white)
        .padding(4)
        .border(Color.gray)
        
    }
        
        
    }
    
    
}

