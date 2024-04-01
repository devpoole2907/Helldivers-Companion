//
//  GalaxyStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI
#if os(iOS)
import SwiftUIIntrospect
#endif

// TODO: ADD GALAXY STATS HERE
struct GalaxyStatsView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var navPather: NavigationPather
    @EnvironmentObject var purchaseManager: StoreManager
    
    var body: some View {
        NavigationStack(path: $navPather.navigationPath) {
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
              
                    #if os(iOS)
                    Section {
                        
                        GalaxyInfoView(galaxyStats: viewModel.galaxyStats)
                    }
                  
                        .id(0)
                    #endif
                    
                    
                    
                    // displays the planets grouped by sector
                    
                        // this isnt technically ordered, but it doesnt matter because index of 0 will be marked for the statistics at the top, so if scroll position has any value then bring us back to 0 at the top :-)
                    ForEach(viewModel.sortedSectors.indices, id: \.self) { index in
                        let sector = viewModel.sortedSectors[index]
                        
                        Section{
                            
                            ForEach(viewModel.groupedBySectorPlanetStatuses[sector] ?? [], id: \.planet.index) { planetStatus in
                                
                                
                                NavigationLink(value: planetStatus) {
                                    PlanetInfoDetailRow(planetStatus: planetStatus)
                                }.padding(.vertical, 8)
                                
                            }
                            
                            
                        } header: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(sector) Sector").font(Font.custom("FS Sinclair", size: largeFont))
                                RoundedRectangle(cornerRadius: 25).frame(width: 250, height: 2)         .padding(.bottom, 4)
                            }.padding(.top)
                            
                        }.id(index + 1)
                
                        
                    }
                    
                    
                    
                    
                }.padding(.horizontal)
                
                
                    .scrollTargetLayout()
                
            }.scrollPosition(id: $navPather.scrollPosition)
            
            
            
#if os(iOS)
            
            
                .overlay(
                    FactionImageView(faction: .human)

                        .padding(.trailing, 20)
                        .offset(x: 0, y: -45)
                    , alignment: .topTrailing)
            
                .background {
                    Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
                }
#endif
            
                .navigationTitle("Galaxy Statistics".capitalized)
            
                .navigationDestination(for: PlanetStatus.self) { status in
                    PlanetInfoView(planetStatus: status)
                }
            
                .toolbar {
#if os(iOS)
                    
                    
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
                    
#endif
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
        
#endif
        
        
    }
}

#Preview {
    GalaxyStatsView().environmentObject(PlanetsViewModel()).environmentObject(NavigationPather()).environmentObject(StoreManager())
}

