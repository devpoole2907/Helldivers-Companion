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
    
    //   PlanetView(planetName: planetStatus.planet.name, liberation: planetStatus.liberation, rate: planetStatus.regenPerSecond, playerCount: planetStatus.players, planet: planetStatus, liberationType: .liberation, bugOrAutomaton: planetStatus.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate
    
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
    
    
    
    var body: some View {
        ScrollView {
            
            
            imageWithSectorName
            
            VStack(alignment: .leading, spacing: 14) {
                
                if let _ = planetStatus?.planet.biome?.slug {
                    biomeDescription
                    
                }
                
                if let _ = planetStatus?.planet.environmentals {
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
                        
                        if let defenseEvent = viewModel.defensePlanets.first(where: { $0.planet.name == planetName }) {
                            
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
                
             

                
                
                
                
            }  .padding(.horizontal, 20)
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
            FactionImageView(bugOrAutomaton: bugOrAutomaton)
                .padding(.trailing, 20)
                .offset(x: 0, y: -45)
            , alignment: .topTrailing)

        
        .toolbarRole(.editor)
        
        .navigationTitle(planetStatus?.planet.name.capitalized ?? "ESTANU")
        
        .navigationBarTitleDisplayMode(.large)
#else
        .navigationBarTitleDisplayMode(.inline) // TODO: come back here, inlining nav on watchos might be unneccesary
#endif
    }
    
    var statsList: some View {
        
        VStack {
            if let missionsWon = planetStatus?.planet.stats?.missionsWon {
                HStack {
                    Text("Missions won").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsWon)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let missionsLost = planetStatus?.planet.stats?.missionsLost {
                HStack {
                    Text("Missions lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsLost)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let successRate = planetStatus?.planet.stats?.missionSuccessRate {
                HStack {
                    Text("Success rate").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(successRate)%").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            Divider()
            
            if let terminidKills = planetStatus?.planet.stats?.bugKills {
                HStack {
                    Text("Terminids Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(terminidKills)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let automatonKills = planetStatus?.planet.stats?.automatonKills {
                HStack {
                    Text("Automatons Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(automatonKills)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let illuminateKills = planetStatus?.planet.stats?.illuminateKills {
                HStack {
                    Text("Illuminates Killed").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(illuminateKills)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
          
            
            Divider()
            
            if let bulletsFied = planetStatus?.planet.stats?.bulletsFired {
                HStack {
                    Text("Bullets Fired").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFied)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let bulletsHit = planetStatus?.planet.stats?.bulletsHit {
                HStack {
                    Text("Bullets Hit").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let accuracy = planetStatus?.planet.stats?.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            Divider()
            
            if let helldiversLost = planetStatus?.planet.stats?.deaths {
                HStack {
                    Text("Helldivers Lost").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            if let friendlyKills = planetStatus?.planet.stats?.friendlies {
                HStack {
                    Text("Friendly Kills").textCase(.uppercase).font(Font.custom("FS Sinclair", size: mediumFont))
                    Spacer()
                    Text("\(friendlyKills)").font(Font.custom("FS Sinclair", size: smallFont))
                }
            }
            
            
            
            
            
        }
        
        
    }
    
    var imageWithSectorName: some View {
        ZStack(alignment: .bottomLeading) {
            Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
            
            
            if let sector = planetStatus?.planet.sector {
                HStack(spacing: 6) {
                    Text(sector).foregroundColor(bugOrAutomaton == .terminid ? .yellow : .red)
                    Text("Sector")
                    
                    
                    
                    
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
            .border(bugOrAutomaton == .terminid ? .yellow : .red, width: 2) .padding([.bottom, .horizontal])
    }
    
    var biomeDescription: some View {
        VStack(alignment: .leading, spacing: 5){
            
            Text(planetStatus?.planet.biome?.slug ?? "").textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
            
            Divider()
                .frame(width: 200)
            
            if let biomeDescript = planetStatus?.planet.biome?.description {
                Text(biomeDescript)
                    .font(Font.custom("FS Sinclair", size: smallFont))
                
            }
            
        }
    }
    
    var environmentsList: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            
            Text("Environment").textCase(.uppercase).font(Font.custom("FS Sinclair", size: largeFont))
            
            Divider()
                .frame(width: 200)
            
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
    
    var bugOrAutomaton: EnemyType = .terminid
    
    
    var body: some View {
        
        
        Image(bugOrAutomaton.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
        //  .clipShape(Circle())
        
        
    }
    
    
}
