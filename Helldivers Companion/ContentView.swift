//
//  ContentView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    #if os(iOS)
    @StateObject var viewModel = PlanetsViewModel()
    #elseif os(watchOS)
    @EnvironmentObject var viewModel: PlanetsViewModel
    #endif
    
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
                    
                    ForEach(viewModel.planets, id: \.self) { planet in
                        
                        PlanetView(planetName: planet.planet.name, liberation: planet.liberation, rate: planet.regenPerSecond, playerCount: planet.players, planet: planet).environmentObject(viewModel)
                            .padding(.horizontal)
                    }
                    
                }
                
                Spacer(minLength: 100)
                
            }.scrollContentBackground(.hidden)
            
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
               
            
            .onAppear {
                
                viewModel.startUpdating()

            }

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
            
          //  OrderView()
        
                Text(viewModel.majorOrderString).bold()
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            Spacer()
            
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MAJOR ORDER").textCase(.uppercase).fontWeight(.heavy)
                }
            }
            #endif
            
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
    ContentView()
}
