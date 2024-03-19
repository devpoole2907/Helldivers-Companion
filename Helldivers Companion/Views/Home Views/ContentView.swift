//
//  ContentView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel

    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
            
            ScrollView {
                
                //     Text("Current war season: \(viewModel.currentSeason)")
                
                LazyVStack(spacing: 20) {
                    
                    // some preview planets for when editing
                    
                    
                  /*  PlanetView().padding(.horizontal).environmentObject(viewModel)
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)*/
                    
                    ForEach(viewModel.defensePlanets, id: \.planet.index) { planet in
                      
                        if let status = planet.planetStatus {
                            PlanetView(planetName: planet.planet.name, liberation: planet.defensePercentage, playerCount: status.players, planet: status, liberationType: .defense).environmentObject(viewModel)
                                .padding(.horizontal)
                        }
                    }
                    
                    ForEach(viewModel.planets, id: \.self) { planetStatus in
                        
                        PlanetView(planetName: planetStatus.planet.name, liberation: planetStatus.liberation, rate: planetStatus.regenPerSecond, playerCount: planetStatus.players, planet: planetStatus).environmentObject(viewModel)
                            .padding(.horizontal)
                    }
                    
                }
                
                Spacer(minLength: 100)
                
            }.scrollContentBackground(.hidden)
                
                    .refreshable {
                        viewModel.refresh()
                    }
            
#if os(iOS)
                majorOrderButton.padding(.bottom, 50)
                
        
                
                #endif
        }
            
            .sheet(isPresented: $viewModel.showOrders) {
                
                ordersSheet
                
                
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
                
            }
            
            .sheet(isPresented: $viewModel.showInfo) {
               
                AboutView()
                
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
                
            }
               
            #if os(watchOS) // this is updated in root on ios
            .onAppear {
                
                viewModel.startUpdating()

            }
            #endif

            #if os(iOS)
            .background {
                Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
            }
            #endif
        
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.showInfo.toggle()
                    }){
                        Image(systemName: "info.circle")
                    }.foregroundStyle(.white)
                        .bold()
                }
                
                
#if os(iOS)
                    ToolbarItem(placement: .principal) {
                        
                        Text("LAST UPDATED: \(viewModel.lastUpdatedDate.formatted(date: .omitted, time: .shortened))")
                            .font(Font.custom("FS Sinclair", size: 24))
                        
                    }
                    #endif
                
                
                
            }
         
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    var ordersSheet: some View {
        
        NavigationStack {
            ScrollView {
            OrderView().padding(.horizontal)

            Spacer()
            
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                 
                    ZStack(alignment: .leading) {
                        Image("MajorOrdersBanner").resizable()
                            .frame(width: getRect().width + 50, height: 60).ignoresSafeArea()
                            .offset(CGSize(width: 0, height: 0))
                            .border(Color.white, width: 2)
                            .padding(.bottom)
                            .opacity(0.8)
                          
                        
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Image(systemName: "scope").bold()
                           
                            Text("MAJOR ORDER").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 24))
                                    
                        }.padding(.leading, 70)
                    }
                    
                
                        
                }
            }
            #endif
            
        }.scrollContentBackground(.hidden)
     
            .toolbarBackground(.hidden, for: .navigationBar)
            
          
            
            .navigationBarTitleDisplayMode(.inline)
        }
        
      

        
        
    }
    
    var majorOrderButton: some View {
        
        Button(action: {
            viewModel.showOrders.toggle()
        }){
            Text("Major Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                .font(Font.custom("FS Sinclair", size: 20))
        }.padding()
        
            .background {
                Color.black.opacity(0.7)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
            .padding()
        

        
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
