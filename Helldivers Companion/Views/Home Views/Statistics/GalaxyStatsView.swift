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
                LazyVStack {
                    
                    ForEach(viewModel.allPlanetStatuses, id: \.self.planet.index) { planetStatus in
                        
                        NavigationLink(value: planetStatus) {
                            Text("Planet: \(planetStatus.planet.name)")
                        }
                        
                        
                    }
                    
                    
                }.scrollTargetLayout()
                
            }.scrollPosition(id: $navPather.scrollPosition)
            
                .navigationTitle("Galaxy Statistics".capitalized)
                
                
            
            
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
    GalaxyStatsView()
}
