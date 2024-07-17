//
//  WatchGalaxyStatsView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

@available(watchOS 10.0, *)
struct WatchGalaxyStatsView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
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
            let sectorName = viewModel.updatedSortedSectors[index]
            return "\(sectorName)"
        }
    }

    
    @State private var currentTab: WatchStatsTab = .galaxyInfo
    
    var body: some View {
        
        
        
        NavigationStack(path: $navPather.navigationPath){
            TabView(selection: $currentTab) {
            
            ScrollView {
                GalaxyInfoView()
                    .padding(.horizontal, 5)
            }.tag(WatchStatsTab.galaxyInfo)
            
            ForEach(viewModel.updatedSortedSectors.indices, id: \.self) { index in
                let sector = viewModel.updatedSortedSectors[index]
               
                    ScrollView {
                        LazyVStack {
                            Section{
                                
                                ForEach(viewModel.updatedGroupedBySectorPlanets[sector] ?? [], id: \.index) { planet in
                                    
                                    
                                    Button(action: {
                                        
                                       
                                        navPather.navigationPath.append(planet.index)
                                        
                                        
                                    }){
                                        
                                        PlanetInfoDetailRow(planet: planet)
                                        
                                    }.padding(.vertical, 8)
                                        .buttonStyle(PlainButtonStyle())
                                    
                                    
                                }
                                
                                
                            } 
                        }
                    }.tag(WatchStatsTab.sector(index))
                
                
            }
            
            
            
        }.tabViewStyle(.verticalPage)
            
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("\(titleForTab(currentTab))").textCase(.uppercase)  .font(Font.custom("FSSinclair-Bold", size: 18))
                    }
                }
            
                .navigationDestination(for: Int.self) { index in
                    PlanetInfoView(planetIndex: index)
                }
        
    }
   
    }
}
