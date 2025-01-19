//
//  PlanetInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct PlanetInfoView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var navPath: NavigationPather
    
    @State private var infoType: InfoType = .warEffort
    
    @State var showIlluminateStats = true // for redacted animation
    @State var showRedactedText = false
    
    let planetIndex: Int
    
    private var planetData: [UpdatedPlanetDataPoint] {
        viewModel.planetHistory[planet?.name ?? ""] ?? []
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planet)
        
    }
    
    // to determine if it is currently in a campaign
    private var campaign: Bool {
        viewModel.updatedCampaigns.contains(where: { $0.planet.name == planet?.name })
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
    
    
    private var activeSpaceStation: SpaceStation? {
        return viewModel.spaceStations.first { spaceStation in
            spaceStation.planet.index == planet?.index
        }
    }
    
    private var activeSpaceStationDetails: SpaceStationDetails? {
        guard let activeSpaceStation = activeSpaceStation else { return nil }
        return viewModel.firstSpaceStationDetails?.id32 == activeSpaceStation.id32 ? viewModel.firstSpaceStationDetails : nil
    }
    
    private var spaceStationExpirationTime: Date? {
        return activeSpaceStation?.electionEndDate
    }
    private var liberationType: LiberationType {
        
        (defenseCampaign != nil) ? .defense : .liberation
        
    }
    
    private var liberationPercentage: Double? {
        defenseCampaign?.planet.event?.percentage ?? planet?.percentage
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
    
    #if os(watchOS)
    
    let dividerWidth: CGFloat = 100
    let smallerDividerWidth: CGFloat = 80
    let horizPadding: CGFloat = 5
    let extraStatSplitter = "\n" // split by new line on watchos
    
    #else
    
    let dividerWidth: CGFloat = 300
    let smallerDividerWidth: CGFloat = 200
    let horizPadding: CGFloat = 20
    let extraStatSplitter = " " // split by space on ios
    
    #endif
    
    var body: some View {
        ScrollView {
            
            
            imageWithSectorName
            
            if let spaceStationExpiration = spaceStationExpirationTime {
                SpaceStationView(spaceStationExpiration: spaceStationExpiration, spaceStationDetails: activeSpaceStationDetails, warTime: viewModel.warTime, isWidget: false, showFullInfo: true)
                    .padding(.horizontal)
            }
         
            
            VStack(alignment: .leading, spacing: 14) {
                
                // dont show if not currently fighting
                if campaign {
                    
                    CustomSegmentedPicker(selection: $infoType, items: InfoType.allCases)
                        .frame(maxWidth: .infinity)
                    
                        .padding(.bottom, 40)
                    
                }
                
           
                
                
                // dont show this data if the planet isnt a current campaign
                if campaign && infoType == .warEffort {
                    HistoryChart(liberationType: liberationType, planetData: planetData, factionColor: viewModel.getColorForPlanet(planet: planet)).environmentObject(viewModel)
                        .shadow(radius: 5.0)
                    VStack(alignment: .center, spacing: 2) {
                        if let timeRemaining = liberationTimeRemaining {
                            Group {
                                Text("\(liberationType == .defense ? "DEFENDED" : "LIBERATION") IN: ")
                                + Text(timeRemaining, style: .relative)
                                
                                
                            }.font(Font.custom("FSSinclair-Bold", size: smallFont))
                                .foregroundStyle(.white)
                                .shadow(radius: 5.0)
                            
                        }
                        CampaignPlanetStatsView(liberation: liberationPercentage ?? 0.0, liberationType: liberationType, planetName: planet?.name, planet: planet, factionColor: viewModel.getColorForPlanet(planet: planet), factionImage: viewModel.getImageNameForPlanet(planet), playerCount: planet?.statistics.playerCount, eventExpirationTime: eventExpirationTime)
                            .shadow(radius: 5.0)
                    }

                } else {
                    
                    if let _ = planet?.biome.name {
                        biomeDescription
                        
                    }
                    
                    if let environmentals = planet?.hazards, !environmentals.isEmpty {
                        environmentsList
                        
                    }
                    
                    if let _ = planet?.statistics {
                        statsList
                    }
                    
                    
                }
                
             

                
                
                
                
            }  .padding(.horizontal, horizPadding)
            
            Spacer(minLength: 150)
            
        }
#if os(iOS)
        
        .background {
            if viewModel.darkMode {
                Color.black.ignoresSafeArea()
            } else {
                Image("helldivers2planet").resizable().aspectRatio(contentMode: .fill).offset(CGSize(width: -400, height: 0)).blur(radius: 20.0).ignoresSafeArea()
            }
        }
        

        
        .overlay(
            
            
            
            FactionImageView(faction: viewModel.getImageNameForPlanet(planet))

                .padding(.trailing, 20)
                .offset(x: 0, y: -45)
            , alignment: .topTrailing)

        
        .toolbarRole(.editor)
        
        .navigationTitle(planet?.name.uppercased() ?? "UNKNOWN")
        
        .navigationBarTitleDisplayMode(.large)
#else

        .toolbar {
            if #available(watchOS 10, *) {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(planet?.name.capitalized ?? "UNKNOWN").textCase(.uppercase)  .font(Font.custom("FSSinclair", size: largeFont))
                }
            }

        }
        
        
#endif
    }
    
    var statsList: some View {
        
        VStack(alignment: .leading) {
            if let missionsWon = planet?.statistics.missionsWon {
                HStack {
                    Text("Missions\(extraStatSplitter)won").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsWon)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let missionsLost = planet?.statistics.missionsLost {
                HStack {
                    Text("Missions\(extraStatSplitter)lost").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsLost)").font(Font.custom("FSSinclair", size: smallFont))
                        .multilineTextAlignment(.trailing)
                }
            }
            
            if let successRate = planet?.statistics.missionSuccessRate {
                HStack {
                    Text("Success rate").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(successRate)%").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
                .padding(.bottom, 4)
            
            if let terminidKills = planet?.statistics.terminidKills {
                HStack {
                    Text("Terminids\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(terminidKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let automatonKills = planet?.statistics.automatonKills {
                HStack {
                    Text("Automatons\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(automatonKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let illuminateKills = planet?.statistics.illuminateKills, showIlluminateStats {
                HStack {
                    Text(!showRedactedText ? "Illuminates\(extraStatSplitter)Killed" : "[REDACTED]\(extraStatSplitter)killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                        .foregroundStyle(showRedactedText ? .red : .white)
                        .shake(times: CGFloat(viewModel.redactedShakeTimes))
                    Spacer()
                    Text("\(illuminateKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
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
            
          
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let bulletsFired = planet?.statistics.bulletsFired {
                HStack {
                    Text("Bullets\(extraStatSplitter)Fired").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFired)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let bulletsHit = planet?.statistics.bulletsHit {
                HStack {
                    Text("Bullets\(extraStatSplitter)Hit").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let accuracy = planet?.statistics.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let helldiversLost = planet?.statistics.deaths {
                HStack {
                    Text("Helldivers\(extraStatSplitter)Lost").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let friendlyKills = planet?.statistics.friendlies {
                HStack {
                    Text("Friendly\(extraStatSplitter)Kills").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(friendlyKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            
            
            
            
        }
        
        
    }
    
    var imageWithSectorName: some View {
        ZStack(alignment: .bottomLeading) {
            Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.multiply)
            
            .frame(maxHeight: 80)
            
            
            if let sector = planet?.sector {
                HStack(spacing: 6) {
                    Text(sector).foregroundStyle(viewModel.getColorForPlanet(planet: planet))
#if os(watchOS)
    .textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: mediumFont))
#else
    .textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
                    #endif
                  
                    Text("Sector")
                    #if os(watchOS)
                        .textCase(.uppercase).font(Font.custom("FSSinclair", size: smallFont))
                    #else
                        .textCase(.uppercase).font(Font.custom("FSSinclair", size: largeFont))
                    #endif
                    
                    
                    
                    
                    Spacer()
                }
                    .padding(5)
                    .padding(.leading, 5)
                  
            }
            
        }   .border(Color.white)
            .padding(4)
            .border(Color.gray)
        
            .padding(4)
            .border(viewModel.getColorForPlanet(planet: planet), width: 2) .padding([.bottom, .horizontal])
    }
    
    var biomeDescription: some View {
        VStack(alignment: .leading, spacing: 5){
            
            Text(planet?.biome.name ?? "").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let biomeDescript = planet?.biome.description {
                Text(biomeDescript)
                    .font(Font.custom("FSSinclair", size: smallFont))
                
            }
            
        }
    }
    
    var environmentsList: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            
            Text("Environment").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let weathers = planet?.hazards {
                ForEach(weathers, id: \.name) { weather in
                    
                    HStack(spacing: 12) {
                        Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                        
                            .frame(width: 30, height: 30)
                            .padding(4)
                            .background{
                                Circle().foregroundStyle(Color.white)
                                    .shadow(radius: 3.0)
                                    .opacity(weather.name.lowercased() == "none" ? 0.4 : 1.0)
                            }
                        
                        VStack(alignment: .leading) {
                            Text(weather.name).textCase(.uppercase)
                                .font(Font.custom("FSSinclair", size: mediumFont))
                            if !weather.description.isEmpty {
                                Text(weather.description)
                                    .font(Font.custom("FSSinclair", size: smallFont))
                            }
                        }
                        
                        
                    }
                }
                
            }
            
            
        }.padding(.bottom, 8)
        //    .padding(.horizontal, 5)
        
        
        
    }
    
    
}

struct FactionImageView: View {
    // not using enemy type enum, because this planet may be viewed from the stats view - if its not currently in a campaign then it may be human owned, in that case the owner will be passed
    var faction: String = "terminid"

    var body: some View {
        
        
        Image(faction)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
        //  .clipShape(Circle())
        
        
    }
    
    
}

enum InfoType: String, SegmentedItem, CaseIterable {
    case warEffort = "War Effort"
    case database = "Database"
    
    var contentType: SegmentedContentType {
        switch self {
        case .warEffort:
            return .text("War Effort")
        case .database:
            return .text("Database")
        }
    }
}
