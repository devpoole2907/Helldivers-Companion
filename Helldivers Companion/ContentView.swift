//
//  ContentView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    
    @StateObject var viewModel = PlanetsViewModel()
    
    @State private var showOrders = false
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
            
            ScrollView {
                
                //      Text("Current war season: \(viewModel.currentSeason)")
                
                LazyVStack(spacing: 20) {
                    
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)
                    PlanetView().padding(.horizontal)
                    
                    ForEach(viewModel.planets, id: \.self) { planet in
                        
                        PlanetView(planetName: planet.planet.name, liberation: planet.liberation, rate: planet.regenPerSecond, playerCount: planet.players, planet: planet)
                            .padding(.horizontal)
                    }
                    
                }
                
                Spacer(minLength: 100)
                
            }.scrollContentBackground(.hidden)
            
                Button(action: {
                    showOrders.toggle()
                }){
                    Text("Major Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                }.padding()
                    
                    .background {
                        Color.black.opacity(0.7)
                }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                .padding()
            
        }
            
            .sheet(isPresented: $showOrders) {
                NavigationStack {
                
                        Text(viewModel.majorOrderString).bold()
                            .padding(.horizontal)
                    Spacer()
                    
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("MAJOR ORDER").textCase(.uppercase).fontWeight(.heavy)
                        }
                    }
                }
                
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
                
            }
               
            
            .onAppear {
                viewModel.startUpdating()
            }
            
            .background {
                Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
            }
        
            
            .navigationTitle("LAST UPDATED: \(viewModel.lastUpdatedDate.formatted(date: .omitted, time: .shortened))")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
}

#Preview {
    ContentView()
}
