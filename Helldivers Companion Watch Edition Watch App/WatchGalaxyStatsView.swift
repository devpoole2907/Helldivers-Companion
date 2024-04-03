//
//  WatchGalaxyStatsView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

struct WatchGalaxyStatsView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var navPather: NavigationPather
    
    enum WatchStatsTab: Hashable {
        case galaxyInfo
        case sector(Int)  // each sector has a unique integer identifier
 
    }
    // to give each tab a title
    func titleForTab(_ tab: WatchStatsTab) -> String {
        switch tab {
        case .galaxyInfo:
            return "Galaxy Stats"
        case .sector(let index):
            let sectorName = viewModel.sortedSectors[index]
            return "\(sectorName)"
        }
    }

    
    @State private var currentTab: WatchStatsTab = .galaxyInfo
    
    var body: some View {
        
        
        
        NavigationStack(path: $navPather.navigationPath){
            TabView(selection: $currentTab) {
            
            ScrollView {
                GalaxyInfoView(galaxyStats: viewModel.galaxyStats, showIlluminate: viewModel.configData.showIlluminate)
                    .padding(.horizontal, 5)
            }.tag(WatchStatsTab.galaxyInfo)
            
            ForEach(viewModel.sortedSectors.indices, id: \.self) { index in
                let sector = viewModel.sortedSectors[index]
               
                    ScrollView {
                        LazyVStack {
                            Section{
                                
                                ForEach(viewModel.groupedBySectorPlanetStatuses[sector] ?? [], id: \.planet.index) { planetStatus in
                                    
                                    
                                    Button(action: {
                                        
                                       
                                            navPather.navigationPath.append(planetStatus)
                                        
                                        
                                    }){
                                        
                                        PlanetInfoDetailRow(planetStatus: planetStatus)
                                        
                                    }.padding(.vertical, 8)
                                        .buttonStyle(PlainButtonStyle())
                                    
                                    
                                }
                                
                                
                            } header: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(sector) Sector").font(Font.custom("FS Sinclair", size: largeFont))
                                    RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)         .padding(.bottom, 4)
                                }.padding(.top)
                                
                            }
                        }
                    }.tag(WatchStatsTab.sector(index))
                
                
            }
            
            
            
        }.tabViewStyle(.verticalPage)
            
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("\(titleForTab(currentTab))").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 18))
                    }
                }
            
                .navigationDestination(for: PlanetStatus.self) { status in
                    PlanetInfoView(planetStatus: status)
                }
        
    }
   
    }
}

#Preview {
    WatchGalaxyStatsView()
}
