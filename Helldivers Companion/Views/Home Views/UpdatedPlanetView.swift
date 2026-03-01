//
//  UpdatedPlanetView.swift
//  Helldivers Companion
//
//  Created by James Poole on 18/04/2024.
//

import SwiftUI
import Charts
import WidgetKit

// this is used for the app only (not widgets), it needs to be cleaned up a LOTTT of old code lying around from the original planetview
struct UpdatedPlanetView: View {
    
    @Environment(PlanetsDataModel.self) var viewModel
    
    @Environment(NavigationPather.self) var navPather
    
    let planetIndex: Int
    
    var showImage = true
    var showExtraStats = true
    var isWidget = false
    
    var isInMapView = false // map view uses navigation view not navigationstack, due to the zoomable package/modifier not working in stack. so this is a workaround that allows us to change the navigationlink styling to the older deprecated way if we are in the map view

    var body: some View {
        if let context = viewModel.context(for: planetIndex) {
            UpdatedPlanetContentView(
                context: context,
                showImage: showImage,
                showExtraStats: showExtraStats,
                isWidget: isWidget,
                isInMapView: isInMapView,
                planetHistory: viewModel.planetHistory[context.planet.name] ?? [],
                isMajorOrderTarget: context.isMajorOrderTarget
            )
            .onTapGesture {
                navPather.navigationPath.append(context.planet.index)
            }
        }
    }
}

/// Purely presentational — receives everything it needs, no view model lookups.
private struct UpdatedPlanetContentView: View {

    let context: PlanetContext
    var showImage = true
    var showExtraStats = true
    var isWidget = false
    var isInMapView = false
    var planetHistory: [UpdatedPlanetDataPoint]
    var isMajorOrderTarget: Bool

    @Environment(NavigationPather.self) var navPather

    private var raceIconSize: CGFloat { LayoutConstants.raceIconSize }
    private var spacingSize: CGFloat { LayoutConstants.spacingSize }
    private var zStackAlignment: Alignment { LayoutConstants.zStackAlignment }

    private var formattedPlanetImageName: String {
        PlanetImageFormatter.formattedPlanetImageName(for: context.planet)
    }

    var body: some View {
        VStack {
            VStack(spacing: showExtraStats ? 6 : 2) {
                headerWithImage
                CampaignPlanetStatsView(
                    context: context,
                    showExtraStats: showExtraStats,
                    isWidget: isWidget
                )
            }
        }.padding(5)
            .background {
                if isWidget {
                    Color.clear
                } else {
                    Color.black
                }
            }
        // red border if its super earth and current active in campaign
            .border(context.isActive && context.planet.index == 0 ? .red : context.factionColor, width: isWidget ? 0 : 2)
    }

    var planetNameAndIcon: some View {
        return Group {
            Image(context.factionImageName).resizable().aspectRatio(contentMode: .fill)
                .frame(width: raceIconSize, height: raceIconSize)
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: -7) {
            HStack(spacing: 2){
                Text(context.planet.name).textCase(.uppercase).foregroundStyle(context.factionColor)
                    .font(Font.custom("FSSinclair", size: largeFont))
                    .padding(.top, 3)
                    .shadow(radius: 5)
#if os(iOS)
                    .lineLimit(2)
#elseif os(watchOS)
                    .lineLimit(1)
#endif
                    .multilineTextAlignment(.leading)
                    .lineSpacing(0)
                if !isWidget {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                        .opacity(0.7)
                        .bold()
                        .font(.footnote)
                } else {
                    Image(systemName: context.liberationType == .defense ? "shield.lefthalf.filled" : "target")
                        .font(.footnote)
                        .padding(.leading, 2)
                        .foregroundStyle(.white)
                }
            }
                if let timeRemaining = context.liberationTimeRemaining {
                    
                    #if os(iOS)
                    Group {
                        Text("\(context.liberationType == .defense ? "DEFENDED" : "LIBERATION") IN: ")
                        + Text(timeRemaining, style: .relative)
                        
                        
                    }.font(Font.custom("FSSinclair-Bold", size: smallFont))
                        .foregroundStyle(.gray)
                    #else
                    // let it vertically stack
                    Group {
                        Text("\(context.liberationType == .defense ? "DEFENDED" : "LIBERATION") IN: ")
                        Text(timeRemaining, style: .relative)
                            .padding(.top, 1)
                        
                        
                    }.font(Font.custom("FSSinclair-Bold", size: smallFont))
                        .foregroundStyle(.gray)
                    
                    
                    #endif
                    
                }
            
        } .shadow(radius: 3)
            
        }
    }

    var headerWithImage: some View {
        ZStack(alignment: .bottom){
            
            if showImage {
                ZStack(alignment: zStackAlignment){
                    ZStack(alignment: .bottom) {
                        
                        planetaryImage
                        
                        DarkGradientOverlay(maxHeight: 80)
                        
                    }
                    
                    HStack(spacing: 8) {
                        
                        if isMajorOrderTarget {
                            Image("orderstar").resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(Color(red: 49/255, green: 49/255, blue: 49/255))
                                .frame(width: weatherIconSize, height: weatherIconSize)
                                .offset(x: 0, y: -0.5)
                                .whiteCircleBackground()
                        }
                        
                 
#if os(iOS)
                        // dont show spacer on watchos
                        Spacer()
                    
                        #endif
                    // show weather icons
                    if let weathers = context.planet.hazards as [Environmental]? {

                            ForEach(weathers, id: \.name) { weather in
                                if weather.name.lowercased() != "none" {
                                    Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                                    
                                        .frame(width: weatherIconSize, height: weatherIconSize)
                                        .whiteCircleBackground()
                                }
                            }
                    }
                        
                        // show any galactic effect:
                        
                        if let effects = context.planet.galacticEffects {
        
                            ForEach(effects, id: \.galacticEffectId) { effect in
                                
                                if let imageName = effect.imageName {
                                    Image(imageName).resizable()
                                        .renderingMode(.template)
                                        .foregroundStyle(Color(red: 49/255, green: 49/255, blue: 49/255))
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: weatherIconSize - 2, height: weatherIconSize - 2)
                                        .offset(x: imageName == "sciencecenter" ? -1 : 0, y: 0)
                                        .whiteCircleBackground()
                                }
                                
                            }
                            
                        }
                        
                    }.opacity(0.7)
                    
                        .padding(5)
                    
                    
                    
                }
                
            
            }
            
     
                HStack(alignment: .center) {
                    
#if os(iOS)
                    if isWidget {
                        planetNameAndIcon
                    } else {
                        NavigationLink(value: context.planet.index) {
                            planetNameAndIcon
                        }
                    }
                    // map view isnt coming to the watch so no need to change the nav link method there
#else
                    
                    Button(action: {
                        navPather.navigationPath.append(context.planet.index)
                    }){
                        planetNameAndIcon
                    }.buttonStyle(PlainButtonStyle())
                    
#endif
                    
                    Spacer()
                    
                    if !showExtraStats {
                        HStack(spacing: spacingSize) {
                            
                            Image("diver").resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            Text("\(context.planet.statistics.playerCount)").textCase(.uppercase)
                                .foregroundStyle(.white).bold()
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .padding(.top, 3)
                            
                        }.padding(.trailing, 4)
                    }
                    
                }.padding(.horizontal, 5)
                    .padding(.vertical, 2)
            
            
            
        }.helldiversBorder()
    }
    
    var planetaryImage: some View {
        Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
    }
    
}
