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
@available(watchOS 9.0, *)
struct UpdatedPlanetView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    @EnvironmentObject var navPather: NavigationPather
    
    let planetIndex: Int
    
    var factionName: String? = nil // this is for widgets as they cannot access some conditions in the planets view model image function
    var factionColor: Color? = nil // this is for widgets as they cannot access some conditions in the planets view model color function
    var showImage = true
    var showExtraStats = true
    var isWidget = false
    
    var isInMapView = false // map view uses navigation view not navigationstack, due to the zoomable package/modifier not working in stack. so this is a workaround that allows us to change the navigationlink styling to the older deprecated way if we are in the map view

    var isActive: Bool {
        viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet?.index }) // map view needs this, as it shows planet view for all planets even if they arent actively in a campaign. used to hide additional info such as liberation %
    }
    
    private var planet: UpdatedPlanet? {
            viewModel.updatedPlanets.first(where: { $0.index == planetIndex })
        }
    
    private var defenseCampaign: UpdatedCampaign? {
            guard let planet = planet else { return nil }
            return viewModel.updatedDefenseCampaigns.first(where: { $0.planet.index == planet.index })
        }
        
        private var eventExpirationTime: Date? {
            defenseCampaign?.planet.event?.expireTimeDate
        }
    
    private var liberationType: LiberationType {
        
        (defenseCampaign != nil) ? .defense : .liberation
        
    }
    
    private var spaceStationExpirationTime: Date? {
        return viewModel.spaceStations.first { spaceStation in
            spaceStation.planet.index == planet?.index
        }?.electionEndDate
    }
    
    private var liberationPercentage: Double? {
        
        if !viewModel.updatedCampaigns.contains(where: { $0.planet.index == planetIndex }), planet?.currentOwner.lowercased() == "humans" {
            return 100.0
        }
        
       
            return defenseCampaign?.planet.event?.percentage ?? planet?.percentage
        

       
    }
    
    private var liberationTimeRemaining: Date? {
        
        guard let planet = planet else { return nil }
        
        let currentLiberation = planet.event?.percentage ?? planet.percentage
        
        guard let liberationRate = viewModel.currentLiberationRate(for: planet.name), liberationRate > 0 else {
            return nil
        }
        
        let remainingPercentage = 100.0 - currentLiberation
            let timeRemaining = (remainingPercentage / liberationRate) * 3600
          
        let liberationDate = Date().addingTimeInterval(timeRemaining)
        
        return liberationDate
          
    }
    
    

#if os(iOS)
    let raceIconSize: CGFloat = 25
    let spacingSize: CGFloat = 10
    
    let zStackAlignment: Alignment = .topTrailing
    
#elseif os(watchOS)
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 4
    let zStackAlignment: Alignment = .topLeading
#endif
    
    private var planetData: [UpdatedPlanetDataPoint] {
        viewModel.planetHistory[planet?.name ?? ""] ?? []
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planet)
        
    }
    
    private var factionImage: String {
        
        if let imageName = factionName {
            return imageName
        }
        
        // if faction name is nil, we must be in the app - faction is only passed to this view as a widget because widgets cannot access all conditions for this function - unless it is liberating (not defense), liberating campaigns can access the required conditionals so no faction image or color is passed to this view in that case either
        
        return viewModel.getImageNameForPlanet(planet)
        
    }
    
    private var foreColor: Color {
        
        if let color = factionColor {
            return color
        }
        
        // see above computed prop comments for more info, its the same reasoning
        // if faction color is nil, we must be in the app - faction is only passed to this view as a widget because widgets cannot access all conditions for this function
        
        return viewModel.getColorForPlanet(planet: planet)
        
    }
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: showExtraStats ? 6 : 2) {
                
                headerWithImage
                    
                CampaignPlanetStatsView(liberation: liberationPercentage ?? 100.0, liberationType: liberationType, showExtraStats: showExtraStats, planetName: planet?.name, planet: planet, factionColor: foreColor, factionImage: factionImage, playerCount: planet?.statistics.playerCount, isWidget: isWidget, eventExpirationTime: eventExpirationTime, spaceStationExpiration: spaceStationExpirationTime, isActive: isActive)
                    
                
                
                
                
                
            }.onTapGesture {
                // nav to planet info view if tapped anywhere
                if let planet = planet {
                    navPather.navigationPath.append(planet.index)
                }
                
            }
            
            
        }.padding(5)
            .background {
                if isWidget {
                    Color.clear
                } else {
                    Color.black
                }
            }
            .border(foreColor, width: isWidget ? 0 : 2)
     
    }
    
    var planetNameAndIcon: some View {
        return Group {
            Image(factionImage).resizable().aspectRatio(contentMode: .fill)
                .frame(width: raceIconSize, height: raceIconSize)
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: -7) {
            HStack(spacing: 2){
                Text(planet?.name ?? "Unknown").textCase(.uppercase).foregroundStyle(foreColor)
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
                    Image(systemName: liberationType == .defense ? "shield.lefthalf.filled" : "target")
                        .font(.footnote)
                        .padding(.leading, 2)
                        .foregroundStyle(.white)
                }
                
                
                
                
            }
                if let timeRemaining = liberationTimeRemaining {
                    
                    #if os(iOS)
                    Group {
                        Text("\(liberationType == .defense ? "DEFENDED" : "LIBERATION") IN: ")
                        + Text(timeRemaining, style: .relative)
                        
                        
                    }.font(Font.custom("FSSinclair-Bold", size: smallFont))
                        .foregroundStyle(.gray)
                    #else
                    // let it veritically stack
                    Group {
                        Text("\(liberationType == .defense ? "DEFENDED" : "LIBERATION") IN: ")
                        Text(timeRemaining, style: .relative)
                            .padding(.top, 1)
                        
                        
                    }.font(Font.custom("FSSinclair-Bold", size: smallFont))
                        .foregroundStyle(.gray)
                    
                    
                    #endif
                    
                }
            
        } .shadow(radius: 3)
                .animation(.bouncy, value: viewModel.planetHistory.count)
            
        }
    }
    
    var headerWithImage: some View {
        ZStack(alignment: .bottom){
            
            if showImage {
       
                    
                    // this really messes with the widgets so ive done it in an... odd way
                    ZStack(alignment: zStackAlignment){
                        ZStack(alignment: .bottom) {
                            
                            planetaryImage
                            
                            
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blendMode(.multiply)
                            
                            .frame(maxHeight: 80)
                            
                        }
                        
                        // show weather icons
                        if let weathers = planet?.hazards {
                            
                         
                            
                            HStack(spacing: 8) {
                                ForEach(weathers, id: \.name) { weather in
                                    if weather.name.lowercased() != "none" {
                                        Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                                        
                                            .frame(width: weatherIconSize, height: weatherIconSize)
                                            .padding(4)
                                            .background{
                                                Circle().foregroundStyle(Color.white)
                                                    .shadow(radius: 3.0)
                                            }
                                    }
                                }
                            }.opacity(0.7)
                            
                                .padding(5)
                            
                            
                            
                            
                        }
                        
                        
                    }
                    
                
            }
            
     
                HStack(alignment: .center) {
                    
#if os(iOS)
                    if isWidget {
                        planetNameAndIcon
                    }  else {
                        NavigationLink(value: planet?.index) {
                            planetNameAndIcon
                        }
                    }
                    // map view isnt coming to the watch so no need to change the nav link method there
#else
                    
                    Button(action: {
                        if let planet = planet {
                            navPather.navigationPath.append(planet.index)
                        }
                        
                    }){
                        planetNameAndIcon
                    }.buttonStyle(PlainButtonStyle())
                    
#endif
                    
                    Spacer()
                    
                    if !showExtraStats {
                        HStack(spacing: spacingSize) {
                            
                            
                            Image("diver").resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            Text("\(planet?.statistics.playerCount)").textCase(.uppercase)
                                .foregroundStyle(.white).bold()
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .padding(.top, 3)
                            
                            
                        }.padding(.trailing, 4)
                    }
                    
                }.padding(.horizontal, 5)
                    .padding(.vertical, 2)
                
            
            
            
        }.border(Color.white)
            .padding(4)
            .border(Color.gray)
    }
    
    var planetaryImage: some View {
        
        Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
        
        
        
        
        
    }
    
}
