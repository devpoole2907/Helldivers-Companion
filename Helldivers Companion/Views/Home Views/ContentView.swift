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
import TipKit
#endif
import Haptics
struct ContentView: View {
    
    #if os(iOS)
    private var tip: NotificationTip {
        NotificationTip()
    }
    #endif
    
    @Environment(PlanetsDataModel.self) var viewModel
    
    @Environment(NavigationPather.self) var navPather
    

    #if os(iOS)
    @Environment(DatabaseModel.self) var dbModel
    @Environment(\.requestReview) var requestReview
    #endif
    
    let appUrl = URL(string: "https://apps.apple.com/us/app/war-monitor-for-helldivers-2/id6479404407")
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
       ]
    
    var fleetView: some View {
        
        FleetStrengthView(fleetStrengthProgress: viewModel.fleetStrengthProgress)
        
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var navPather = navPather
        
        NavigationStack(path: $navPather.navigationPath) {
            ZStack {
                ScrollView {
                    
                    //     Text("Current war season: \(viewModel.currentSeason)")
                    
                    if isIpad {
                        if let alert = viewModel.configData.prominentAlert {
                            
                            AlertView(alert: alert)
                                .padding(.horizontal)
                        }
                        
                        if viewModel.fleetStrengthResource != nil {
                            fleetView
                        }
                        
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.updatedCampaigns, id: \.planet.index) { campaign in
                                
                                UpdatedPlanetView(planetIndex: campaign.planet.index)
                                    .padding()
                                
                                
                            }
                        }
                        
                    } else {
                        
                        
                        
                        
                        
                        
                      
                            
                            /*   AlertView(alert: "You are running a test version of War Monitor. This special build will display additional debug info, if you experience any issues please provide screenshots of the debug information below.")  .padding(.horizontal)*/
                            
                            if let alert = viewModel.configData.prominentAlert {
                                
                                AlertView(alert: alert)
                                    .padding(.horizontal)
                            }
                            
                            
                            /*    if let error = viewModel.lastError {
                             
                             Text("Attempted to fetch planet status: \(error)").font(.title3).bold()
                             
                             }
                             
                             if let error = viewModel.lastCampaignsError {
                             
                             Text("Attempted to fetch campaigns: \(error)").font(.title3).bold()
                             
                             }*/
                            
                            if viewModel.fleetStrengthResource != nil {
                                fleetView
                            }
                            
                        LazyVStack(spacing: 20) {
                            
                            ForEach(viewModel.updatedCampaigns, id: \.planet.index) { campaign in
                                
                                UpdatedPlanetView(planetIndex: campaign.planet.index)
                                    .id(campaign == viewModel.updatedCampaigns.first ? 0 : campaign.planet.index)
                                    .padding(.horizontal)
                                
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    
                    
                    if let failedFetchTimeRemaining = viewModel.nextFetchTime {
                        VStack(spacing: 0) {
                            
                            Text("Failed to connect to Super Earth High Command. Retrying in:")
                                .opacity(0.5)
                                .foregroundStyle(.gray)
                                .font(Font.custom("FSSinclair", size: smallFont))
                                .multilineTextAlignment(.center)
                            
                            Text(failedFetchTimeRemaining, style: .timer)
                                .opacity(0.5)
                                .foregroundStyle(.gray)
                                .font(Font.custom("FSSinclair", size: largeFont))
                                .padding()
                            
                        }      .padding()
                    }
                    
                    Text("Pull to Refresh").textCase(.uppercase)
                        .opacity(0.5)
                        .foregroundStyle(.gray)
                        .font(Font.custom("FSSinclair-Bold", size: smallFont))
                        .padding()
                    
                    
                    Spacer(minLength: 30)
                    
                }
                
                .scrollContentBackground(.hidden)
                
                .refreshable {
                    viewModel.startUpdating()
                }
                
                if viewModel.isLoading {
                    VStack {
                        Text("Please wait democratically".uppercased()).foregroundStyle(.white) .font(Font.custom("FSSinclair", size: mediumFont))
                        DualRingSpinner()
                    }
                }
                
            }
            
                .sheet(isPresented: $viewModel.showInfo) {
                    
                    AboutView()
                    
                        .presentationDragIndicator(.visible)
                        .customSheetBackground(ultraThin: false)
                    
                }
            
#if os(iOS)
                .conditionalBackground(viewModel: viewModel, grayscale: viewModel.isLoading)
#endif
            
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .topBarLeading) {
                        
                        if #available(iOS 17.0, *) {
                            Button(action: {
                                viewModel.showInfo.toggle()
                            }){
                                Image(systemName: "gearshape.fill")
                            }.foregroundStyle(.white)
                                .bold()
                                .popoverTip(tip)
                                .onTapGesture {
                                  tip.invalidate(reason: .actionPerformed)
                                }
                        } else {
                            
                            Button(action: {
                                viewModel.showInfo.toggle()
                            }){
                                Image(systemName: "gearshape.fill")
                            }.foregroundStyle(.white)
                                .bold()
                        }
                        
                        
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        PlayerCountView().environment(viewModel)
                    }
                    
                    
                    ToolbarItem(placement: .principal) {
                        Group {
                            Text("UPDATED: ")
                            + Text(viewModel.lastUpdatedDate, style: .relative)
                            + Text(" ago")
                        }
                        .font(Font.custom("FSSinclair", size: 20)).bold()
                        
                                .dynamicTypeSize(.small)
                        
                    }
                    
#endif
                    
#if os(watchOS)
                    if #available(watchOS 10, *) {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("WAR").textCase(.uppercase)  .font(Font.custom("FSSinclair", size: largeFont)).bold()
                        }
                    }
#endif
                    
                }
            
            
                .navigationBarTitleDisplayMode(.inline)
            
                .navigationDestination(for: Int.self) { index in
                    PlanetInfoView(planetIndex: index)
                }
            
            #if os(iOS)
                .navigationDestination(for: ContentViewPage.self) { _ in
                    SuperStoreList().environment(dbModel)
                }
            #endif
            
        }
        
#if os(iOS)
        .helldiversNavigationStyle()
    
        .onAppear {
            viewModel.viewCount += 1
            
            if viewModel.viewCount == 3 {
                requestReview()
            }
        }
        #endif
        
    }
    
    
    
    
}
