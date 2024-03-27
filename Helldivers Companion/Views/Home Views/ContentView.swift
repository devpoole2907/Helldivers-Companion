//
//  ContentView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import UIKit
import StoreKit

struct ContentView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel

    #if os(iOS)
    @Environment(\.requestReview) var requestReview
    #endif
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                //     Text("Current war season: \(viewModel.currentSeason)")
                
                LazyVStack(spacing: 20) {
                    
                    // some preview planets for when editing
                    
                    
                    /*  PlanetView().padding(.horizontal).environmentObject(viewModel)
                     PlanetView().padding(.horizontal)
                     PlanetView().padding(.horizontal)
                     PlanetView().padding(.horizontal)*/
                    
                    if let alert = viewModel.configData.prominentAlert {
                        
                        AlertView(alert: alert)
                            .padding(.horizontal)
                    }

                    ForEach(viewModel.campaignPlanets, id: \.self) { planetStatus in
                        // check if planet is defending
                        if let defenseEvent = viewModel.defensePlanets.first(where: { $0.planet.index == planetStatus.planet.index }) {
                            // planet is defending, use defense percentage for liberation val
                            PlanetView(planetName: planetStatus.planet.name, liberation: defenseEvent.defensePercentage, rate: planetStatus.regenPerSecond, playerCount: planetStatus.players, planet: planetStatus, liberationType: .defense, bugOrAutomaton: planetStatus.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate).environmentObject(viewModel)
                                .padding(.horizontal)
                        } else {
                            // planet not defending, use liberation
                            PlanetView(planetName: planetStatus.planet.name, liberation: planetStatus.liberation, rate: planetStatus.regenPerSecond, playerCount: planetStatus.players, planet: planetStatus, liberationType: .liberation, bugOrAutomaton: planetStatus.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate).environmentObject(viewModel)
                                .padding(.horizontal)
                        }
                    }

                    
                }
                
                Text("Pull to Refresh").textCase(.uppercase)
                    .opacity(0.5)
                    .foregroundStyle(.gray)
                    .font(Font.custom("FS Sinclair", size: smallFont))
                    .padding()
                
                
                Spacer(minLength: 150)
                
            }.scrollContentBackground(.hidden)
            
                .refreshable {
                    viewModel.refresh()
                }
            
            
            
            
            
                .sheet(isPresented: $viewModel.showInfo) {
                    
                    AboutView()
                    
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.thinMaterial)
                    
                }
            
#if os(iOS)
                .background {
                    Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
                }
#endif
            
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.showInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                        }.foregroundStyle(.white)
                            .bold()
                    }
                    
                    
                    
                    
                    
                    ToolbarItem(placement: .principal) {
                        
                        Text("LAST UPDATED: \(viewModel.lastUpdatedDate.formatted(date: .omitted, time: .shortened))")
                            .font(Font.custom("FS Sinclair", size: 24))
                        
                    }
                    
#endif
                    
#if os(watchOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Text("WAR").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: largeFont))
                    }
#endif
                    
                }
            
            
                .navigationBarTitleDisplayMode(.inline)
        }
        #if os(iOS)
        .onAppear {
            viewModel.viewCount += 1
            
            if viewModel.viewCount == 3 {
                requestReview()
            }
        }
        #endif
        
    }
    
    
    
    
}

#Preview {
    ContentView().environmentObject(PlanetsViewModel())
}


extension View {
    
    var isIpad: Bool {
#if !os(watchOS)
        UIDevice.current.userInterfaceIdiom == .pad
#else
        
        return false
        
#endif
    }
    
}
