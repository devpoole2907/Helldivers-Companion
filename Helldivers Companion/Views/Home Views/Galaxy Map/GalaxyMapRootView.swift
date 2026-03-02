//
//  GalaxyMapRootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 09/04/2024.
//

import SwiftUI
import Haptics

struct GalaxyMapRootView: View {
    
    @Environment(PlanetsDataModel.self) var viewModel
    @Environment(NavigationPather.self) var navPather
    
    @State var planetName: String = ""
    @State var position: String = ""
    
    @AppStorage("showSupplyLines") var showSupplyLines = true
    @AppStorage("showAllPlanets") var showAllPlanets = false
    @AppStorage("showPlanetNames") var showPlanetNames = false
    
    @State private var currentZoomScale: CGFloat = 1.0
    
    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var navPather = navPather
        
        NavigationStack(path: $navPather.navigationPath) {
            
            ZStack(alignment: .top) {
                
              
                
                VStack(spacing: 0) {
                    
                    
                    Spacer(minLength: 300)
                
                    GalaxyMapView(selectedPlanet: $viewModel.selectedPlanet, showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets, showPlanetNames: $showPlanetNames, currentZoomLevel: $currentZoomScale).environment(viewModel)
                
                    .frame(width: 300, height: 300)
                    .contentShape(Rectangle())
                    .zoomable(
                        minZoomScale: 1.0,
                        doubleTapZoomScale: 3,
                        currentZoom: $currentZoomScale
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
                
                if let selectedPlanetIndex = viewModel.selectedPlanet?.index {
        
                    UpdatedPlanetView(planetIndex: selectedPlanetIndex)
                        .padding(.horizontal)
                        .frame(maxWidth: 460)
                    
                  
                    
                    
                }
                
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        Text("Please wait democratically".uppercased()).foregroundStyle(.white) .font(Font.custom("FSSinclair", size: mediumFont))
                        DualRingSpinner()
                        Spacer()
                    }
                }
                if let _ = viewModel.fleetStrengthResource {
                    VStack(spacing: 0) {
                        Spacer()
                        FleetStrengthView(fleetStrengthProgress: viewModel.fleetStrengthProgress)
                            .shadow(radius: 3)
                    }
                }
                
            }
            .conditionalBackground(viewModel: viewModel, grayscale: viewModel.isLoading)
            
            
            
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
                        .font(Font.custom("FSSinclair", size: 24)).bold()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    PlayerCountView().environment(viewModel)
                }
                
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationDestination(for: Int.self) { index in
                PlanetInfoView(planetIndex: index)
            }
            
        }.hapticFeedback(.selection, trigger: viewModel.selectedPlanet)

        
        // set custom nav title font
            .helldiversNavigationStyle()
        
    }
    
    
}

#if DEBUG
#Preview {
    GalaxyMapRootView()
        .environment(PlanetsDataModel(apiService: MockAPIService()))
        .environment(NavigationPather())
}
#endif
