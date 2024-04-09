//
//  GalaxyMapRootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 09/04/2024.
//

import SwiftUI
import Zoomable
import SwiftUIIntrospect

struct GalaxyMapRootView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var navPather: NavigationPather
    
    @State var planetName: String = ""
    @State var position: String = ""
    
    @State var showSupplyLines = true
    @State var showAllPlanets = true
    @State var showPlanetNames = false
    
    // to determine if it is actively in a campaign
    var isActive: Bool {
        
        if let selectedPlanet = viewModel.selectedPlanet {
            
            viewModel.updatedCampaigns.contains(where: { $0.planet.index == selectedPlanet.index })
            
        } else {
            false
        }
        
    }
    // to determine if it is actively in a defense campaign
    var isDefending: Bool {
        
        if let selectedPlanet = viewModel.selectedPlanet {
            
            viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == selectedPlanet.index })
            
        } else {
            false
        }
        
        
    }
    
    var liberationPercentage: Double {
        
        if let selectedPlanet = viewModel.selectedPlanet {
            if isDefending || isActive {
                return selectedPlanet.percentage
            } else if selectedPlanet.currentOwner == "Humans" {
                
                return 100
                
                
            } else {
                // must be owned by another faction and not actively in campaign so 0
                return 0
            }
            
            
        }
        
        return 0
        
        
        
    }
    
    var body: some View {
        
        NavigationStack(path: $navPather.navigationPath) {
            
            ZStack(alignment: .top) {
                
              
                
                VStack(spacing: 0) {
                    
                    
                    Spacer(minLength: 300)
                
                    GalaxyMapView(selectedPlanet: $viewModel.selectedPlanet, position: $position, showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets, showPlanetNames: $showPlanetNames).environmentObject(viewModel)
                
                    .frame(width: 300, height: 300)
                    .contentShape(Rectangle())
                    .zoomable(
                        minZoomScale: 1.0,
                        doubleTapZoomScale: 3,
                        outOfBoundsColor: .clear
                    )
                
                    .padding()
                
                    //   .clipShape(Rectangle())
                
                    .padding(.bottom, 20)
                
            }
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black]),
                    startPoint: .center,
                    endPoint: .top
                )
                .blendMode(.multiply)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .clear, .black]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .blendMode(.multiply)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                if let selectedPlanet = viewModel.selectedPlanet {
                    
                    
                    let eventExpirationTime = selectedPlanet.event?.expireTimeDate
                    
                    
                    
                    PlanetView(planetName: selectedPlanet.name, liberation: liberationPercentage, rate: selectedPlanet.regenPerSecond, playerCount: selectedPlanet.statistics.playerCount, planet: selectedPlanet, liberationType: isDefending ? .defense : .liberation, eventExpirationTime: eventExpirationTime, isActive: isActive).environmentObject(viewModel)
                        .padding(.horizontal)
                        .frame(maxWidth: 460, maxHeight: 300)
                        .animation(.bouncy, value: isActive)
                    
                  
                    
                    
                }
                
            }
            .background {
                Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
            }
            
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button(action: {
                        
                        MapSettingsPopup(showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets, showPlanetNames: $showPlanetNames).showAndStack()
                        
                    }){
                        Image(systemName: "slider.horizontal.3").bold()
                    }.tint(.white)
                    
                }
                
                ToolbarItem(placement: .principal) {
                    Text("GALAXY MAP")
                        .font(Font.custom("FS Sinclair Bold", size: 24))
                }
                
                if #unavailable(iOS 17.0) {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Button(action: {
                            
                            iOS16AlertPopup().showAndStack()
                            
                        }){
                            Image(systemName: "exclamationmark.triangle.fill")
                               
                        } .tint(.red)
                        
                    }
                    
                    
                }
                
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationDestination(for: UpdatedPlanet.self) { planet in
                PlanetInfoView(planet: planet)
            }
            
        }

        
        // set custom nav title font
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
        
    }
    
    
}

#Preview {
    GalaxyMapRootView()
}
