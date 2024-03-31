//
//  CampaignPlanetStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI

struct CampaignPlanetStatsView: View {
    
    var liberation: Double
    var bugOrAutomaton: EnemyType
    var liberationType: LiberationType
    
    var showExtraStats: Bool
    
    var planetName: String
    
    var playerCount: Int = 347246
    
    var isWidget = false
    
    var terminidRate: String
    var automatonRate: String
    
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
                    
                    RectangleProgressBar(value: liberation / 100, secondaryColor: bugOrAutomaton == .terminid ? Color.yellow : Color.red)
                    
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
                    Text("\(liberation, specifier: "%.3f")% \(liberationType == .liberation ? "Liberated" : "Defended")").textCase(.uppercase)
                        .foregroundStyle(.white).bold()
                        .font(Font.custom("FS Sinclair", size: showExtraStats ? mediumFont : smallFont))
                        .multilineTextAlignment(.leading)
                    
                    if let liberationRate = viewModel.averageLiberationRate(for: planetName) {
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
            
            HStack(alignment: .center, spacing: spacingSize) {
                
                if liberationType == .liberation {
                    
                    Image(bugOrAutomaton.rawValue).resizable().aspectRatio(contentMode: .fit)
                        .frame(width: raceIconSize, height: raceIconSize)
                    
                    Text(bugOrAutomaton == .terminid ? "\(terminidRate) / h" : "\(automatonRate) / h").foregroundStyle(bugOrAutomaton == .terminid ? Color.yellow : Color.red).bold()
                        .font(Font.custom("FS Sinclair", size: mediumFont))
                        .padding(.top, 3)
                    
                } else {
                    Text("DEFEND") .font(Font.custom("FS Sinclair", size: largeFont))
                    
                    // defense is important, so pulsate
                        .foregroundStyle(isWidget ? .white : (pulsate ? .red : .white))
                        .opacity(isWidget ? 1.0 : (pulsate ? 1.0 : 0.0))
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulsate)
                    
                        .onAppear {
                                        pulsate = true
                                    }
                        
                }
                
            }.frame(maxWidth: .infinity)
            
            Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                .padding(.vertical, 10)
            
            
            HStack(spacing: spacingSize) {
                
                
                Image("diver").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: helldiverImageSize, height: helldiverImageSize)
                Text("\(playerCount)").textCase(.uppercase)
                    .foregroundStyle(.white).bold()
                    .font(Font.custom("FS Sinclair", size: mediumFont))
                    .padding(.top, 3)
                
            }.frame(maxWidth: .infinity)
            
            
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

