//
//  ContentView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    
    @StateObject var viewModel = PlanetsViewModel()
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
            
            ScrollView {
                
                //     Text("Current war season: \(viewModel.currentSeason)")
                
                LazyVStack(spacing: 20) {
                    
                    // some preview planets for when editing
                    
                    /*
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)*/
                    
                    ForEach(viewModel.planets, id: \.self) { planet in
                        
                        PlanetView(planetName: planet.planet.name, liberation: planet.liberation, rate: planet.regenPerSecond, playerCount: planet.players, planet: planet)
                            .padding(.horizontal)
                    }
                    
                }
                
                Spacer(minLength: 100)
                
            }.scrollContentBackground(.hidden)
            
               majorOrderButton
            
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
            
            .background {
                Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
            }
        
            .toolbar {
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
                
                
            }
         
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    var ordersSheet: some View {
        
        NavigationStack {
            
            OrderView()
        
                Text(viewModel.majorOrderString).bold()
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            Spacer()
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MAJOR ORDER").textCase(.uppercase).fontWeight(.heavy)
                }
            }
            
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
