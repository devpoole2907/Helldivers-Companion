//
//  GalaxyMapRootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 09/04/2024.
//

import SwiftUI
import Zoomable
import SwiftUIIntrospect
import Haptics

struct GalaxyMapRootView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var navPather: NavigationPather
    
    @State var planetName: String = ""
    @State var position: String = ""
    
    @AppStorage("showSupplyLines") var showSupplyLines = true
    @AppStorage("showAllPlanets") var showAllPlanets = false
    @AppStorage("showPlanetNames") var showPlanetNames = false
    
    @State private var currentZoomScale: CGFloat = 1.0
    
    var body: some View {
        
        NavigationStack(path: $navPather.navigationPath) {
            
            ZStack(alignment: .top) {
                
              
                
                VStack(spacing: 0) {
                    
                    
                    Spacer(minLength: 300)
                
                    GalaxyMapView(selectedPlanet: $viewModel.selectedPlanet, showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets, showPlanetNames: $showPlanetNames, currentZoomLevel: $currentZoomScale).environmentObject(viewModel)
                
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
                
            }
            .conditionalBackground(viewModel: viewModel)
            
            
            
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
                
                if #unavailable(iOS 17.0) {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Button(action: {
                            
                            iOS16AlertPopup().showAndStack()
                            
                        }){
                            Image(systemName: "exclamationmark.triangle.fill")
                               
                        } .tint(.red)
                        
                    }
                    
                    
                } else { // else display player count here too on ios 17+
                    ToolbarItem(placement: .topBarTrailing) {
                        PlayerCountView().environmentObject(viewModel)
                    }
                }
                
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationDestination(for: Int.self) { index in
                PlanetInfoView(planetIndex: index)
            }
            
        }.hapticFeedback(.selection, trigger: viewModel.selectedPlanet)

        
        // set custom nav title font
            .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) { controller in
            print("I am introspecting!")
            
            DispatchQueue.main.async {
                let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
                let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
                
                // default to sf system font
                let largeFont = UIFont(name: "FSSinclair-Bold", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
                let inlineFont = UIFont(name: "FSSinclair-Bold", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)
                
                
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
    
    
}

#Preview {
    GalaxyMapRootView()
}
