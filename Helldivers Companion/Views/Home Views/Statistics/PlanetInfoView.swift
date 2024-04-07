//
//  PlanetInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI

struct PlanetInfoView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var navPath: NavigationPather
    
    @State private var infoType: InfoType = .warEffort
    
    var planet: UpdatedPlanet? = nil
    
    private var planetData: [PlanetDataPoint] {
        viewModel.planetHistory[planet?.name ?? ""] ?? []
    }
    
    private var liberationType: LiberationType {
        viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet?.index }) ? .defense : .liberation
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planet?.name ?? "")
        
    }
    // to determine if it is currently defending
    private var defenseEvent: Bool {
        viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.name == planet?.name })
    }
    
    // to determine if it is currently in a campaign
    private var campaign: Bool {
        viewModel.updatedCampaigns.contains(where: { $0.planet.name == planet?.name })
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
            
            
         
            
            VStack(alignment: .leading, spacing: 14) {
                
                // dont show if not currently fighting
                if campaign {
                    
                    CustomSegmentedPicker(selection: $infoType, items: InfoType.allCases)
                        .frame(maxWidth: .infinity)
                    
                        .padding(.bottom, 34)
                    
                }
                
           
                
                
                // dont show this data if the planet isnt a current campaign
                if campaign && infoType == .warEffort {
                    HistoryChart(liberationType: liberationType, planetData: planetData, factionColor: viewModel.getColorForPlanet(planet: planet)).environmentObject(viewModel)
                        .shadow(radius: 5.0)
                    
                    if let liberation = planet?.percentage, let planetName = planet?.name, let players = planet?.statistics.playerCount {
                        
                        if defenseEvent {
                            
                            let eventExpirationTime = viewModel.eventExpirationDate(from: planet?.event?.endTime)
                            
                            // must be a defending event, use defense percent
                            
                            CampaignPlanetStatsView(liberation: liberation, liberationType: liberationType, showExtraStats: true, planetName: planetName, planet: planet, factionColor: viewModel.getColorForPlanet(planet: planet), factionImage: viewModel.getImageNameForPlanet(planet), playerCount: players, isWidget: false, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate, illuminateRate: viewModel.configData.illuminateRate, eventExpirationTime: eventExpirationTime)
                               .shadow(radius: 5.0)
                            
                            
                        } else {
                            // not defending
                            
                            CampaignPlanetStatsView(liberation: liberation, liberationType: liberationType, showExtraStats: true, planetName: planetName, planet: planet, factionColor: viewModel.getColorForPlanet(planet: planet), factionImage: viewModel.getImageNameForPlanet(planet), playerCount: players, isWidget: false, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate, illuminateRate: viewModel.configData.illuminateRate)
                                .shadow(radius: 5.0)
                        }
                    }
                } else {
                    
                    if let _ = planet?.biome?.slug {
                        biomeDescription
                        
                    }
                    
                    if let environmentals = planet?.environmentals, !environmentals.isEmpty {
                        environmentsList
                        
                    }
                    
                    if let _ = planet?.statistics {
                        statsList
                    }
                    
                    
                }
                
             

                
                
                
                
            }  .padding(.horizontal, horizPadding)
            Text("Data provided from Helldivers Training Manual API")
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
                .foregroundStyle(.gray)
                .opacity(0.5)
                .foregroundStyle(.gray)
                .font(Font.custom("FS Sinclair", size: smallFont))
                .padding()
            
            Spacer(minLength: 150)
            
        }
#if os(iOS)
        
        
        .background {
            Image("helldivers2planet").resizable().aspectRatio(contentMode: .fill).offset(CGSize(width: -400, height: 0)).blur(radius: 20.0).ignoresSafeArea()
        }
        
        .overlay(
            
            
            
            FactionImageView(faction: viewModel.getImageNameForPlanet(planet))

                .padding(.trailing, 20)
                .offset(x: 0, y: -45)
            , alignment: .topTrailing)

        
        .toolbarRole(.editor)
        
        .navigationTitle(planet?.name.capitalized ?? "UNKNOWN")
        
        .navigationBarTitleDisplayMode(.large)
#else

        .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(planet?.name.capitalized ?? "UNKNOWN").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: largeFont))
                }

        }
        
        
#endif
    }
    
    var statsList: some View {
        
        VStack(alignment: .leading) {
            if let missionsWon = planet?.statistics.missionsWon {
                HStack {
                    Text("Missions\(extraStatSplitter)won").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsWon)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let missionsLost = planet?.statistics.missionsLost {
                HStack {
                    Text("Missions\(extraStatSplitter)lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsLost)").font(Font.custom("FS Sinclair", size: smallFont))
                        .multilineTextAlignment(.trailing)
                }
            }
            
            if let successRate = planet?.statistics.missionSuccessRate {
                HStack {
                    Text("Success rate").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(successRate)%").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
                .padding(.bottom, 4)
            
            if let terminidKills = planet?.statistics.terminidKills {
                HStack {
                    Text("Terminids\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(terminidKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let automatonKills = planet?.statistics.automatonKills {
                HStack {
                    Text("Automatons\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(automatonKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let illuminateKills = planet?.statistics.illuminateKills, viewModel.configData.showIlluminate {
                HStack {
                    Text("Illuminates\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(illuminateKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
          
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let bulletsFired = planet?.statistics.bulletsFired {
                HStack {
                    Text("Bullets\(extraStatSplitter)Fired").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFired)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let bulletsHit = planet?.statistics.bulletsHit {
                HStack {
                    Text("Bullets\(extraStatSplitter)Hit").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let accuracy = planet?.statistics.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let helldiversLost = planet?.statistics.deaths {
                HStack {
                    Text("Helldivers\(extraStatSplitter)Lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let friendlyKills = planet?.statistics.friendlies {
                HStack {
                    Text("Friendly\(extraStatSplitter)Kills").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(friendlyKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            
            
            
            
        }
        
        
    }
    
    var imageWithSectorName: some View {
        ZStack(alignment: .bottomLeading) {
            Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
            
            
            if let sector = planet?.sector {
                HStack(spacing: 6) {
                    Text(sector).foregroundStyle(viewModel.getColorForPlanet(planet: planet))
#if os(watchOS)
    .textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
#endif
                  
                    Text("Sector")
                    #if os(watchOS)
                        .textCase(.uppercase).font(Font.custom("FS Sinclair", size: smallFont))
                    #endif
                    
                    
                    
                    
                    Spacer()
                }        .textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
                    .padding(5)
                    .padding(.leading, 5)
                    .background {
                        Color.black.opacity(0.6)
                    }
            }
            
        }   .border(Color.white)
            .padding(4)
            .border(Color.gray)
        
            .padding(4)
            .border(viewModel.getColorForPlanet(planet: planet), width: 2) .padding([.bottom, .horizontal])
    }
    
    var biomeDescription: some View {
        VStack(alignment: .leading, spacing: 5){
            
            Text(planet?.biome?.slug ?? "").textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let biomeDescript = planet?.biome?.description {
                Text(biomeDescript)
                    .font(Font.custom("FS Sinclair", size: smallFont))
                
            }
            
        }
    }
    
    var environmentsList: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            
            Text("Environment").textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let weathers = planet?.environmentals {
                ForEach(weathers, id: \.name) { weather in
                    
                    HStack(spacing: 12) {
                        Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                        
                            .frame(width: 30, height: 30)
                            .padding(4)
                            .background{
                                Circle().foregroundStyle(Color.white)
                                    .shadow(radius: 3.0)
                            }
                        
                        VStack(alignment: .leading) {
                            Text(weather.name).textCase(.uppercase)
                                .font(Font.custom("FS Sinclair", size: mediumFont))
                            if !weather.description.isEmpty {
                                Text(weather.description)
                                    .font(Font.custom("FS Sinclair", size: smallFont))
                            }
                        }
                        
                        
                    }
                }
                
            }
            
            
        }.padding(.bottom, 8)
        //    .padding(.horizontal, 5)
        
        
        
    }
    
    
}

#Preview {
    NavigationStack{
        PlanetInfoView().environmentObject(PlanetsViewModel()).environmentObject(NavigationPather())
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
