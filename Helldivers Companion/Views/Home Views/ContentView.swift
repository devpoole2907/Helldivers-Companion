//
//  ContentView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import UIKit
import StoreKit
#if os(iOS)
import SwiftUIIntrospect
#endif

struct ContentView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var purchaseManager: StoreManager
    
    @EnvironmentObject var navPather: NavigationPather

    #if os(iOS)
    @Environment(\.requestReview) var requestReview
    #endif
    
    var body: some View {
        
        NavigationStack(path: $navPather.navigationPath) {
            
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

                    ForEach(Array(viewModel.campaignPlanets.enumerated()), id: \.element) { (index, planetStatus) in
                        // check if planet is defending
                        if let defenseEvent = viewModel.defensePlanets.first(where: { $0.planet.index == planetStatus.planet.index }) {
                            // planet is defending, use defense percentage for liberation val
                            PlanetView(planetName: planetStatus.planet.name, liberation: defenseEvent.defensePercentage, rate: planetStatus.regenPerSecond, playerCount: planetStatus.players, planet: planetStatus, liberationType: .defense, bugOrAutomaton: planetStatus.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate).environmentObject(viewModel)
                                .padding(.horizontal)
                                .id(index)
                        } else {
                            // planet not defending, use liberation
                            PlanetView(planetName: planetStatus.planet.name, liberation: planetStatus.liberation, rate: planetStatus.regenPerSecond, playerCount: planetStatus.players, planet: planetStatus, liberationType: .liberation, bugOrAutomaton: planetStatus.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate).environmentObject(viewModel)
                                .padding(.horizontal)
                                .id(index)
                        }
                    }

                    
                }.scrollTargetLayout()
                
                Text("Pull to Refresh").textCase(.uppercase)
                    .opacity(0.5)
                    .foregroundStyle(.gray)
                    .font(Font.custom("FS Sinclair", size: smallFont))
                    .padding()
                
                
                Spacer(minLength: 150)
                
            } .scrollPosition(id: $navPather.scrollPosition)
            
            
            .scrollContentBackground(.hidden)
            
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
                    if !purchaseManager.products.isEmpty {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                purchaseManager.showTips.toggle()
                            }){
                                Image(systemName: "cart.fill")
                            }.foregroundStyle(.white)
                                .bold()
                        }
                    }
                    
                    
                    
                    
                    ToolbarItem(placement: .principal) {
                        
                        
                            Text("UPDATED: \(viewModel.lastUpdatedDate.formatted(date: .omitted, time: .shortened))")
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
            
                .navigationDestination(for: PlanetStatus.self) { status in
                    PlanetInfoView(planetStatus: status)
                }
            
            
        }
        
#if os(iOS)
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) { controller in
            print("I am introspecting!")

            
            let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
            let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize

            // default to sf system font
            let largeFont = UIFont(name: "FS Sinclair", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
               let inlineFont = UIFont(name: "FS Sinclair", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)

            
            let largeAttributes: [NSAttributedString.Key: Any] = [
                .font: largeFont
            ]

            let inlineAttributes: [NSAttributedString.Key: Any] = [
                .font: inlineFont
            ]
                                
            controller.navigationBar.titleTextAttributes = inlineAttributes
            
            controller.navigationBar.largeTitleTextAttributes = largeAttributes
            
            
       
        }
        
        
    
        .onAppear {
            viewModel.viewCount += 1
            
            if viewModel.viewCount == 3 {
                requestReview()
            }
        }
        #endif
        
    }
    
    
    
    
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
