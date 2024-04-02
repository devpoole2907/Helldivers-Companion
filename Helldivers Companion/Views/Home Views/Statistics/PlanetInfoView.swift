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
    
    var planetStatus: PlanetStatus? = nil
    
    private var planetData: [PlanetDataPoint] {
        viewModel.planetHistory[planetStatus?.planet.name ?? ""] ?? []
    }
    
    private var liberationType: LiberationType {
        viewModel.defensePlanets.contains(where: { $0.planet.index == planetStatus?.planet.index }) ? .defense : .liberation
    }
    
    private var bugOrAutomaton: EnemyType {
        planetStatus?.owner == "Terminids" ? .terminid : .automaton
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planetStatus?.planet.name ?? "")
        
    }
    // to determine if it is currently defending
    private var defenseEvent: PlanetEvent? {
        viewModel.defensePlanets.first(where: { $0.planet.name == planetStatus?.planet.name })
    }
    
    // to determine if it is currently in a campaign
    private var campaign: PlanetStatus? {
        viewModel.campaignPlanets.first(where: { $0.planet.name == planetStatus?.planet.name })
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
    
    private var faction: Faction {
       /*
        if defenseEvent != nil {
            planetStatus?.owner
        }
        
        // just return the current owner, its either being attacked or not active currently
        else if campaign != nil {
            
        } else {
            // just return the current owner, its not defending or attacking
        }
        */
        
        // TODO: STOP OVERWRITING OWNER FOR DEFENSE PLANETS, STORE/DISPLAY IT ANOTHER WAY
        
        // for now we just return the type of faction based on owner, this will be slightly incorrect! unless we dont mind just displaying the enemy faction when its defending anywa here
        
        switch planetStatus?.owner {
            
        case "Terminids":
            return .terminid
        case "Illuminates":
            return .illuminate
        case "Automaton":
            return .automaton
        case "Humans":
            return .human
        default:
            return .terminid
        }
        
        
        
        
        
    }
    
    var factionColor: Color {
        switch planetStatus?.owner {
            
        case "Terminids":
            return .yellow
        case "Illuminates":
            return .blue
        case "Automaton":
            return .red
        case "Humans":
            return .cyan
        default:
            return .yellow
        }
    }
    
    
    
    var body: some View {
        ScrollView {
            
            
            imageWithSectorName
            
            VStack(alignment: .leading, spacing: 14) {
                
                if let _ = planetStatus?.planet.biome?.slug {
                    biomeDescription
                    
                }
                
                if let environmentals = planetStatus?.planet.environmentals, !environmentals.isEmpty {
                    environmentsList
                    
                }
                
                if let _ = planetStatus?.planet.stats {
                    statsList
                }
                
                
                // dont show this data if the planet isnt a current campaign
                if viewModel.campaignPlanets.contains(where: { $0.planet.name == planetStatus?.planet.name }) {
                    HistoryChart(liberationType: liberationType, planetData: planetData, bugOrAutomaton: bugOrAutomaton).environmentObject(viewModel)
                        .shadow(radius: 5.0)
                    
                    if let liberation = planetStatus?.liberation, let planetName = planetStatus?.planet.name, let players = planetStatus?.players {
                        
                        if let defenseEvent = defenseEvent {
                            
                            // must be a defending event, use defense percent
                            
                            CampaignPlanetStatsView(liberation: defenseEvent.defensePercentage, bugOrAutomaton: bugOrAutomaton, liberationType: liberationType, showExtraStats: true, planetName: planetName, playerCount: players, isWidget: false, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate)
                               .shadow(radius: 5.0)
                            
                            
                        } else {
                            // not defending
                            
                            CampaignPlanetStatsView(liberation: liberation, bugOrAutomaton: bugOrAutomaton, liberationType: liberationType, showExtraStats: true, planetName: planetName, playerCount: players, isWidget: false, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate)
                                .shadow(radius: 5.0)
                        }
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
            
            
            
            FactionImageView(faction: faction)

                .padding(.trailing, 20)
                .offset(x: 0, y: -45)
            , alignment: .topTrailing)

        
        .toolbarRole(.editor)
        
        .navigationTitle(planetStatus?.planet.name.capitalized ?? "UNKNOWN")
        
        .navigationBarTitleDisplayMode(.large)
#else
        .navigationBarTitleDisplayMode(.inline) // TODO: come back here, inlining nav on watchos might be unneccesary
        
        
        .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(planetStatus?.planet.name.capitalized ?? "UNKNOWN").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: largeFont))
                }

        }
        
        
#endif
    }
    
    var statsList: some View {
        
        VStack(alignment: .leading) {
            if let missionsWon = planetStatus?.planet.stats?.missionsWon {
                HStack {
                    Text("Missions\(extraStatSplitter)won").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsWon)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let missionsLost = planetStatus?.planet.stats?.missionsLost {
                HStack {
                    Text("Missions\(extraStatSplitter)lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsLost)").font(Font.custom("FS Sinclair", size: smallFont))
                        .multilineTextAlignment(.trailing)
                }
            }
            
            if let successRate = planetStatus?.planet.stats?.missionSuccessRate {
                HStack {
                    Text("Success rate").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(successRate)%").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
                .padding(.bottom, 4)
            
            if let terminidKills = planetStatus?.planet.stats?.bugKills {
                HStack {
                    Text("Terminids\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(terminidKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let automatonKills = planetStatus?.planet.stats?.automatonKills {
                HStack {
                    Text("Automatons\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(automatonKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let illuminateKills = planetStatus?.planet.stats?.illuminateKills, viewModel.configData.showIlluminate {
                HStack {
                    Text("Illuminates\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(illuminateKills)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
          
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let bulletsFired = planetStatus?.planet.stats?.bulletsFired {
                HStack {
                    Text("Bullets\(extraStatSplitter)Fired").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFired)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let bulletsHit = planetStatus?.planet.stats?.bulletsHit {
                HStack {
                    Text("Bullets\(extraStatSplitter)Hit").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let accuracy = planetStatus?.planet.stats?.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let helldiversLost = planetStatus?.planet.stats?.deaths {
                HStack {
                    Text("Helldivers\(extraStatSplitter)Lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FS Sinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let friendlyKills = planetStatus?.planet.stats?.friendlies {
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
            
            
            if let sector = planetStatus?.planet.sector {
                HStack(spacing: 6) {
                    Text(sector).foregroundStyle(factionColor)
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
            .border(factionColor, width: 2) .padding([.bottom, .horizontal])
    }
    
    var biomeDescription: some View {
        VStack(alignment: .leading, spacing: 5){
            
            Text(planetStatus?.planet.biome?.slug ?? "").textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let biomeDescript = planetStatus?.planet.biome?.description {
                Text(biomeDescript)
                    .font(Font.custom("FS Sinclair", size: smallFont))
                
            }
            
        }
    }
    
    var environmentsList: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            
            Text("Environment").textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let weathers = planetStatus?.planet.environmentals {
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
    var faction: Faction = .terminid

    var body: some View {
        
        
        Image(faction.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
        //  .clipShape(Circle())
        
        
    }
    
    
}
