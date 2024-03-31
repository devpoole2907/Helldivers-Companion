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
    @EnvironmentObject var purchaseManager: StoreManager
    
    
    var body: some View {
        
        
        
        NavigationStack(path: $navPather.navigationPath){
        TabView {
            
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
                    }
                
                
            }
            
            
            
        }.tabViewStyle(.verticalPage)
            
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Galaxy Stats").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 18))
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
