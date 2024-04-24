//
//  PlanetsList.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct PlanetsList: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var navPather: NavigationPather
    
    @State private var searchText = ""
    
    var body: some View {
        
        ScrollView {
            LazyVStack(alignment: .leading) {
                
                // displays the planets grouped by sector
                
                    // this isnt technically ordered, but it doesnt matter because index of 0 will be marked for the statistics at the top, so if scroll position has any value then bring us back to 0 at the top :-)
                ForEach(viewModel.updatedSortedSectors.indices, id: \.self) { index in
                    
                 
                    
                    
                    let sector = viewModel.updatedSortedSectors[index]
                    let planets = viewModel.updatedGroupedBySectorPlanets[sector] ?? []
                    let filteredPlanets = planets.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) }
                    let isSectorMatch = sector.localizedCaseInsensitiveContains(searchText)
                 
                    // show all planets when no search term, show only search matching planets when there is and their respective sector heading
                    
                    if searchText.isEmpty || isSectorMatch || !filteredPlanets.isEmpty {
                    Section{
                        
                        ForEach(isSectorMatch ? planets : filteredPlanets, id: \.index) { planet in
                            
                            
                            NavigationLink(value: planet.index) {
                                PlanetInfoDetailRow(planet: planet)
                            }.padding(.vertical, 8)
                            
                        }
                        
                        
                    } header: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(sector) Sector").font(Font.custom("FSSinclair-Bold", size: largeFont))
                            RoundedRectangle(cornerRadius: 25).frame(width: 250, height: 2)         .padding(.bottom, 4)
                        }.padding(.top)
                        
                    }.id(index + 1)
                    
                }
                    
                }
                
            }.padding(.horizontal)
            
            Spacer(minLength: 150)
            
            
        }
        
        .conditionalBackground(viewModel: viewModel)
        
      
        
        .navigationTitle("Planets".uppercased())
        
        #if os(iOS)
        .toolbarRole(.editor)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Planets").disableAutocorrection(true)
        #endif

    }
}

#Preview {
    PlanetsList()
}
