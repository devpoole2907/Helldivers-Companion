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
    
    @EnvironmentObject var navPather: NavigationPather

    #if os(iOS)
    @Environment(\.requestReview) var requestReview
    #endif
    
    let appUrl = URL(string: "https://apps.apple.com/us/app/war-monitor-for-helldivers-2/id6479404407")
    
    var body: some View {
        
        NavigationStack(path: $navPather.navigationPath) {
            
            ScrollView {
                
                //     Text("Current war season: \(viewModel.currentSeason)")
                
                LazyVStack(spacing: 20) {
                    
                    if let alert = viewModel.configData.prominentAlert {
                        
                        AlertView(alert: alert)
                            .padding(.horizontal)
                    }
                    
                    
                    ForEach(Array(viewModel.updatedCampaigns.enumerated()), id: \.element) { (index, campaign) in
                        // check if planet is defending
                        if let defenseCampaign = viewModel.updatedDefenseCampaigns.first(where: { $0.planet.index == campaign.planet.index }) {
                            
                            let eventExpirationTime = campaign.planet.event?.expireTimeDate
                            
                            // uses faction from event instead, use event health/percentage instead
                            PlanetView(planetName: campaign.planet.name, liberation: campaign.planet.event?.percentage ?? 0.0, rate: campaign.planet.regenPerSecond, playerCount: campaign.planet.statistics.playerCount, planet: campaign.planet, liberationType: .defense, eventExpirationTime: eventExpirationTime).environmentObject(viewModel)
                                .padding(.horizontal)
                                .id(index)
                            
                            
                        } else {
                            PlanetView(planetName: campaign.planet.name, liberation: campaign.planet.percentage, rate: campaign.planet.regenPerSecond, playerCount: campaign.planet.statistics.playerCount, planet: campaign.planet, liberationType: .liberation).environmentObject(viewModel)
                                .padding(.horizontal)
                                .id(index)
                        }
                    }
                    
                }
                #if os(iOS)
                .scrollTargetLayoutiOS17()
                #endif
                
                if let failedFetchTimeRemaining = viewModel.nextFetchTime {
                    VStack(spacing: 0) {
                        
                        Text("Failed to connect to Super Earth High Command. Retrying in:")
                            .opacity(0.5)
                            .foregroundStyle(.gray)
                            .font(Font.custom("FS Sinclair", size: smallFont))
                            .multilineTextAlignment(.center)
                       
                        Text(failedFetchTimeRemaining, style: .timer)
                            .opacity(0.5)
                            .foregroundStyle(.gray)
                            .font(Font.custom("FS Sinclair", size: largeFont))
                            .padding()
                        
                    }      .padding()
                }
                
                Text("Pull to Refresh").textCase(.uppercase)
                    .opacity(0.5)
                    .foregroundStyle(.gray)
                    .font(Font.custom("FS Sinclair Bold", size: smallFont))
                    .padding()
                
                
                Spacer(minLength: 30)
                
            } 
#if os(iOS)
            .scrollPositioniOS17($navPather.scrollPosition)
            #endif
            
            .scrollContentBackground(.hidden)
            
                .refreshable {
                    viewModel.refresh()
                }
            
            
                .sheet(isPresented: $viewModel.showInfo) {
                    
                    AboutView()
                    
                        .presentationDragIndicator(.visible)
                        .customSheetBackground(ultraThin: false)
                    
                }
            
#if os(iOS)
                .background {
                    Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
                }
#endif
            
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewModel.showInfo.toggle()
                        }){
                            Image(systemName: "gearshape.fill")
                        }.foregroundStyle(.white)
                            .bold()
                    }
                 /*   if let appUrl = appUrl {
                    ToolbarItem(placement: .topBarLeading) {
                        
                    
                            
                            ShareLink(item: appUrl) {
                                Image(systemName: "square.and.arrow.up.fill")
                            }
                            
                        }
                        
                    }*/
                    
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        PlayerCountView().environmentObject(viewModel)
                    }
        
                    
                    
                    
                    
                    ToolbarItem(placement: .principal) {
                        
                        
                            Text("UPDATED: \(viewModel.lastUpdatedDate.formatted(date: .omitted, time: .shortened))")
                                .font(Font.custom("FS Sinclair Bold", size: 22))
                        
                                .dynamicTypeSize(.small)
                        
                    }
                    
#endif
                    
#if os(watchOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Text("WAR").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: largeFont)).bold()
                    }
#endif
                    
                }
            
            
                .navigationBarTitleDisplayMode(.inline)
            
                .navigationDestination(for: UpdatedPlanet.self) { planet in
                    PlanetInfoView(planet: planet)
                }
            
            
        }
        
#if os(iOS)
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) { controller in
            print("I am introspecting!")

            
            let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
            let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize

            // default to sf system font
            let largeFont = UIFont(name: "FS Sinclair Bold", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
               let inlineFont = UIFont(name: "FS Sinclair Bold", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)

            
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


