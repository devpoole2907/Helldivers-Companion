//
//  CampaignPlanetStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct CampaignPlanetStatsView: View {
    
    var showEnergyBar: Bool {
        planet?.index == 64 && viewModel.configData.meridiaEvent // hardcoded to meridia at this stage
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
        showEnergyBar ? darkEnergyProgress * 100 : liberation
    }
    
    var liberationText: String {
        if showEnergyBar {
            return "ACCUMULATED"
        }
        // event type 3 is liberation
        if planet?.event?.eventType == 3 {
            return "Liberated"
        }
        
        switch liberationType {
        case .liberation:
            return "Liberated"
        case .defense:
            return "Defended"
        }
        
    }
    
    var liberation: Double
    var liberationType: LiberationType
    
    var showExtraStats: Bool = true
    
    var planetName: String?
    
    var planet: UpdatedPlanet? = nil
    
    var factionColor: Color // color is passed to this view as widgets dont have the required state to calculate the color from the view model
    var factionImage: String // same reason as above
    
    var playerCount: Int64?
    
    var isWidget = false
    
    var eventExpirationTime: Date? = nil
    
    var invasionLevel: Int64? = nil
    var maxHealth: Int64? = nil
    var health: Int64? = nil
    
    var spaceStationExpiration: Date? = nil
    var spaceStationDetails: SpaceStationDetails? = nil
    var warTime: Int64? = nil
    
    var isActive = true // if accessed from galaxy map, planet view wont need to display all info if the planet isnt in a campaign
    
    var campaignType: Int? = 0
    
    var matchingRegions: [PlanetRegion] = []
    
    @State private var pulsate = false
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
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
        
        if campaignType != 3 { // campaign type 3 e.g super earth with all its own cities etc doesnt need to show health bars etc
        
        VStack(spacing: 0) {
            
            // TODO: figure out invasion levels for illuminate events/type 3
            
            if let invasionLevel = invasionLevel, let health = health, let maxHealth = maxHealth {
                VStack {
                    
                    HStack(spacing: 0) {
                        
                        // only show invasion level if not event type 3
                        if planet?.event?.eventType != 3 {
                            
                            Text("INVASION LEVEL: \(invasionLevel)")
                                .foregroundStyle(.white).bold()
                                .font(Font.custom("FSSinclair", size: smallFont))
                            Spacer()
                            
                        }
                        
                        // use health and maxhealth here, otherwise use fleet max value and current value
                        
                        Text("HP")    .foregroundStyle(factionColor).bold()
                            .font(Font.custom("FSSinclair", size: smallFont))
                            .padding(.horizontal, 2)
                        
                        
                        if planet?.event?.eventType == 3,
                           let fleet = viewModel.fleetStrengthResource {
                            Text("\(fleet.currentValue)/\(fleet.maxValue)")
                                .foregroundStyle(.gray)
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .shadow(radius: 3)
                        } else {
                            Text("\(health)/\(maxHealth)")
                                .foregroundStyle(.gray)
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .shadow(radius: 3)
                        }
                    } .kerning(-1)
                        .padding(.top, 2)
                        .lineLimit(1)
                  
                    
                }  .padding(.horizontal, 10)
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
                        
                        RectangleProgressBar(value: liberation / 100, secondaryColor: eventExpirationTime != nil ? .cyan : factionColor, height: 8)
                        
                            .padding(.horizontal, 6)
                            .padding(.trailing, 2)
                        
                        // defense remaining bar
                        if let defenseTime = planet?.event?.totalDuration, let eventExpirationTime = eventExpirationTime {
                            
                            let remainingTime = eventExpirationTime.timeIntervalSince(Date())
                            
                            let percentageRemaining = (remainingTime / defenseTime)
                            
                            RectangleProgressBar(value: 1 - percentageRemaining, primaryColor: factionColor, secondaryColor: factionColor, height: 8)
                                .padding(.horizontal, 6)
                                .padding(.trailing, 2)
                        }
                        
                    }
                    
                    
                }
               // .frame(height: showExtraStats ? 34 : 30)
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
                                if isWidget && !showExtraStats, let _ = eventExpirationTime {
                                    Spacer()
                                }
                            }
                            
                            if isWidget && !showExtraStats, let eventExpirationTime = eventExpirationTime {
                                HStack {
                                    Spacer()
                                    Text(eventExpirationTime, style: .timer)
                                        .font(Font.custom("FSSinclair", size: smallFont))
                                        .foregroundStyle(.red)
                                        .monospacedDigit()
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        
                        if !isWidget {
                            if planet?.event?.eventType != 3 { // TODO: save history for globalresources to api cache!!!
                                if let liberationRate = viewModel.currentLiberationRate(for: planetName ?? ""), viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet?.index }) {
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
            
            
        } else {
            
            // regions, show first region
            
            if !matchingRegions.isEmpty {
                
                
                RegionListView(
                    regions: matchingRegions,
                    regionNames: regionNamesByPlanet,
                    showOnlyTopRegion: true, horizPadding: 10
                )
                  .frame(maxHeight: 44)
                .padding(.vertical, 5)
                
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
               .frame(maxHeight: 50)
            }
            
        }
      
        
        // TODO: early draft for dss view
        
        if showExtraStats, let spaceStationExpiration = spaceStationExpiration {
            SpaceStationView(spaceStationExpiration: spaceStationExpiration, spaceStationDetails: spaceStationDetails, warTime: warTime, isWidget: isWidget)
            
        }
        
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
                                    .font(Font.custom("FSSinclair", size: mediumFont))
                                    .padding(.top, 2)
                                    .dynamicTypeSize(.small)
                                
                            }
                            
                        } else {
                            Spacer()
                            VStack(spacing: -5) {
                                // only show defend text on defense type events (this is so duct taped holy)
                                if planet?.event?.eventType != 3 {
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
                                if let eventExpirationTime = eventExpirationTime {
                                    Text(eventExpirationTime, style: .timer)
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
                    Text("\(planet?.statistics.playerCount ?? 0)").textCase(.uppercase)
                        .foregroundStyle(.white).bold()
                        .font(Font.custom("FSSinclair", size: mediumFont))
                        .padding(.top, 2)
                        .dynamicTypeSize(.small)
                    
                    
                } .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: 30)
                
#if os(iOS)
    // show player count % if greater than 0
   if let playerCount = planet?.statistics.playerCount, playerCount > 0, viewModel.totalPlayerCount > 0 {
    
                
                Rectangle().frame(width: 1, height: 15).foregroundStyle(Color.white)
                    .padding(.vertical, 10)
                
       HStack(spacing: spacingSize) {
           
           let playerPercent = (Double(playerCount) / Double(viewModel.totalPlayerCount)) * 100
           
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
    
    
}

