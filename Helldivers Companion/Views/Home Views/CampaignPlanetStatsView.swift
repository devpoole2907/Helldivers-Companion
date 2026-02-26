//
//  CampaignPlanetStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct CampaignPlanetStatsView: View {
    
    let context: PlanetContext
    var showExtraStats: Bool = true
    var isWidget = false

    @State private var pulsate = false
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    // Meridia dark energy bar — still needs live viewModel access
    var showEnergyBar: Bool {
        context.planet.index == 64 && viewModel.configData.meridiaEvent
    }
    
    var darkEnergyResource: GlobalResource? {
        guard let resources = viewModel.status?.globalResources else { return nil }
        return resources.first { $0.id32 == 194773219 }
    }
    
    var darkEnergyProgress: Double {
        guard let resource = darkEnergyResource else { return 0 }
        return Double(resource.currentValue) / Double(resource.maxValue)
    }

    var computedLiberation: Double {
        showEnergyBar ? darkEnergyProgress * 100 : context.displayPercentage
    }

    var liberationText: String {
        if showEnergyBar { return "ACCUMULATED" }
        return context.liberationText
    }

    // Convenience accessors from context
    private var planet: UpdatedPlanet { context.planet }
    private var factionColor: Color { context.factionColor }
    private var factionImage: String { context.factionImageName }

#if os(iOS)
    let helldiverImageSize: CGFloat = 25
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 10
    
#elseif os(watchOS)
    let helldiverImageSize: CGFloat = 10
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 4
    
#endif
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Show the HP row for any active defense event.
            // Type-3 (illuminate fleet) uses fleetStrengthResource for the value;
            // all other types use invasionLevel + eventHealth/eventMaxHealth.
            let isType3Event = planet.event?.eventType == 3
            let showHPRow = isType3Event
                ? context.fleetStrengthResource != nil
                : (context.invasionLevel != nil && context.eventHealth != nil && context.eventMaxHealth != nil)

            if showHPRow {
                VStack {

                    HStack(spacing: 0) {

                        // Only show invasion level for non-type-3 events
                        if !isType3Event, let invasionLevel = context.invasionLevel {
                            Text("INVASION LEVEL: \(invasionLevel)")
                                .foregroundStyle(.white).bold()
                                .font(Font.custom("FSSinclair", size: smallFont))
                            Spacer()
                        }

                        Text("HP")
                            .foregroundStyle(factionColor).bold()
                            .font(Font.custom("FSSinclair", size: smallFont))
                            .padding(.horizontal, 2)

                        if isType3Event, let fleet = context.fleetStrengthResource {
                            Text("\(fleet.currentValue)/\(fleet.maxValue)")
                                .foregroundStyle(.gray)
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .shadow(radius: 3)
                        } else if let health = context.eventHealth, let maxHealth = context.eventMaxHealth {
                            Text("\(health)/\(maxHealth)")
                                .foregroundStyle(.gray)
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .shadow(radius: 3)
                        }
                    }
                    .kerning(-1)
                    .padding(.top, 2)
                    .lineLimit(1)

                }
                .padding(.horizontal, 10)
                .dynamicTypeSize(...DynamicTypeSize.small)

                Rectangle()
                    .fill(.white)
                    .frame(height: 1)
            }
            
       
            
            VStack {
                VStack(spacing: 4) {
                    
                    if showEnergyBar {
                        
                        MiniRectangleProgressBar(value: darkEnergyProgress, primaryColor: .purple, secondaryColor: .black, height: 26)
                            .padding(.horizontal, 6)
                            .padding(.trailing, 2)
                    } else {
                        
                        // health bar
                        RectangleProgressBar(value: context.displayPercentage / 100, secondaryColor: context.eventExpiration != nil ? .cyan : factionColor, height: 8)
                        
                            .padding(.horizontal, 6)
                            .padding(.trailing, 2)
                        
                        // defense remaining bar
                        if let defenseTime = planet.event?.totalDuration, let eventExpiration = context.eventExpiration {
                            
                            let remainingTime = eventExpiration.timeIntervalSince(Date())
                            
                            let percentageRemaining = (remainingTime / defenseTime)
                            
                            RectangleProgressBar(value: 1 - percentageRemaining, primaryColor: factionColor, secondaryColor: factionColor, height: 8)
                                .padding(.horizontal, 6)
                                .padding(.trailing, 2)
                        }
                        
                    }
                    
                    
                }
                .padding(.vertical, 5)
                    .foregroundStyle(Color.clear)
                    .border(showEnergyBar ? Color.clear : Color.orange, width: 2)
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
                                Text("\(computedLiberation, specifier: "%.3f")% \(liberationText)").textCase(.uppercase)
                                    .foregroundStyle(.white).bold()
                                    .font(Font.custom("FSSinclair", size: showExtraStats ? mediumFont : smallFont))
                                    .multilineTextAlignment(.leading)
                                if isWidget && !showExtraStats, context.eventExpiration != nil {
                                    Spacer()
                                }
                            }
                            
                            if isWidget && !showExtraStats, let eventExpiration = context.eventExpiration {
                                HStack {
                                    Spacer()
                                    Text(eventExpiration, style: .timer)
                                        .font(Font.custom("FSSinclair", size: smallFont))
                                        .foregroundStyle(.red)
                                        .monospacedDigit()
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        
                        if !isWidget {
                            if planet.event?.eventType != 3 { // TODO: save history for globalresources to api cache!!!
                                if let liberationRate = context.liberationRate, context.isActive {
                                    Spacer()
                                    HStack(alignment: .top, spacing: 4) {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .padding(.top, 2)
                                        Text("\(liberationRate, specifier: "%.2f")% / h")
                                            .foregroundStyle(.white)
                                            .font(Font.custom("FSSinclair", size: showExtraStats ? mediumFont : smallFont))
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }   .padding(.horizontal)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                
            }
        .border(Color.white)
        .padding(4)
        .border(Color.gray)
            
            
     
            
            // regions, show first region
            
        if let planetRegions = planet.regions {
                
                
                RegionListView(
                    regions: planetRegions,
                    showOnlyTopRegion: true, factionColor: factionColor, horizPadding: 10
                )
                  .frame(maxHeight: 44)
                .padding(.vertical, 5)
                
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
               .frame(maxHeight: 50)
            
            
        }
      
        if showExtraStats, let spaceStationExpiration = context.spaceStationExpiration {
            SpaceStationView(spaceStationExpiration: spaceStationExpiration, spaceStationDetails: context.spaceStationDetails, warTime: context.warTime, isWidget: isWidget)
            
        }
        
        if showExtraStats {
            HStack {
                
                if context.isActive { // dont show this section if planet isnt in a campaign (accessed via galaxy map)
                    
                    HStack(alignment: .center, spacing: spacingSize) {
                        
                        if context.liberationType == .liberation {
                            
                            Image(factionImage).resizable().aspectRatio(contentMode: .fit)
                                .frame(width: raceIconSize, height: raceIconSize)
                            
                            if let regenPerHour = regenPerHour {
                                
                                Text(String(format: "-%.1f%% / h", regenPerHour))
                                    .foregroundStyle(factionColor).bold()
                                    .font(Font.custom("FSSinclair", size: mediumFont))
                                    .padding(.top, 2)
                                    .dynamicTypeSize(.small)
                                
                            }
                            
                        } else {
                            Spacer()
                            VStack(spacing: -5) {
                                // only show defend text on defense type events (this is so duct taped holy)
                                if planet.event?.eventType != 3 {
                                    Text("DEFEND") .font(Font.custom("FSSinclair", size: mediumFont)).bold()
                                        .scaledToFit()
                                    
                                    // defense is important, so pulsate
                                        .foregroundStyle(isWidget ? .red : (pulsate ? .red : .white))
                                        .opacity(isWidget ? 1.0 : (pulsate ? 1.0 : 0.4))
                                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulsate)
                                        .dynamicTypeSize(.small)
                                        .onAppear {
                                            pulsate = true
                                        }
                                    
                                }
                                if let eventExpiration = context.eventExpiration {
                                    Text(eventExpiration, style: .timer)
                                        .font(Font.custom("FSSinclair", size: mediumFont))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.white)
                                        .dynamicTypeSize(.small)
                                    
                                }
                            } .frame(maxWidth: .infinity).padding(.vertical, 6)
                            
                            Spacer()
                            
                        }
                        
                    }.frame(maxWidth: .infinity)
                        .padding(.leading, -5)
                    
                    Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                        .padding(.vertical, 10)
                    
                }
                
                HStack(spacing: spacingSize) {
                    
                    Image("diver").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: helldiverImageSize, height: helldiverImageSize)
                    Text("\(context.planet.statistics.playerCount)").textCase(.uppercase)
                        .foregroundStyle(.white).bold()
                        .font(Font.custom("FSSinclair", size: mediumFont))
                        .padding(.top, 2)
                        .dynamicTypeSize(.small)
                    
                    
                } .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: 30)
                
#if os(iOS)
    // show player count % if greater than 0
   if viewModel.totalPlayerCount > 0, context.planet.statistics.playerCount > 0 {
    
                
                Rectangle().frame(width: 1, height: 15).foregroundStyle(Color.white)
                    .padding(.vertical, 10)
                
       HStack(spacing: spacingSize) {
           
           let playerPercent = (Double(context.planet.statistics.playerCount) / Double(viewModel.totalPlayerCount)) * 100
           
           Text("\(String(format: "%.0f", playerPercent))%")  .font(Font.custom("FSSinclair", size: smallFont))
               .dynamicTypeSize(.small)
               .padding(.top, 2)
        
               .frame(maxWidth: .infinity)
               .padding(.leading, 2)
       }        .padding(.vertical, 10)
           .frame(maxWidth: 40, minHeight: 30)
        
    }
    #endif
                        
                
                
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

    private var regenPerHour: Double? {
        guard context.liberationType == .liberation else { return nil }
        let regenPerSecond = planet.regenPerSecond
        guard planet.maxHealth > 0 else { return nil }
        let regenPerHourAbs = regenPerSecond * 3600.0
        return (regenPerHourAbs / Double(planet.maxHealth)) * 100
    }
    
    
}
