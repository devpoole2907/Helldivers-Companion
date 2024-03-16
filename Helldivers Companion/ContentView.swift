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
                
                //      Text("Current war season: \(viewModel.currentSeason)")
                
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
            
                Button(action: {
                    viewModel.showOrders.toggle()
                }){
                    Text("Major Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                }.padding()
                    
                    .background {
                        Color.black.opacity(0.7)
                }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                .padding()
            
        }
            
            .sheet(isPresented: $viewModel.showOrders) {
                NavigationStack {
                
                        Text(viewModel.majorOrderString).bold()
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
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
            
            .sheet(isPresented: $viewModel.showInfo) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("This application utilizes the unofficial Helldivers 2 API developed by dealloc, available at https://github.com/dealloc/helldivers2-api, to fetch and display the latest data from the ongoing galactic war in the Helldivers 2 universe.").bold()
                     
                        Text("This application is not affiliated with, endorsed by, or in any way officially connected to Arrowhead Game Studios or Sony. All game content, including images and trademarks, are the property of their respective owners. The use of such content within this app falls under fair use for informational purposes and does not imply any association with the game developers or publishers.").bold()
                    
                    }.padding(.horizontal)
                        .multilineTextAlignment(.center)
                    Spacer()
                    
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("About").textCase(.uppercase).fontWeight(.heavy)
                        }
                    }
                }
                
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
            }
            
            .navigationTitle("LAST UPDATED: \(viewModel.lastUpdatedDate.formatted(date: .omitted, time: .shortened))")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
}

#Preview {
    ContentView()
}
