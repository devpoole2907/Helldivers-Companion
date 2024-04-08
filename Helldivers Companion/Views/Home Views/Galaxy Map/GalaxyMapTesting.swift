//
//  GalaxyMapTesting.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/04/2024.
//

import SwiftUI
import Zoomable
import SwiftUIIntrospect

struct DraggablePlanetView: View {
    @Binding var location: CGPoint
    var imageSize: CGSize
    
    @Binding var position: String
    
    var body: some View {
        Circle()
            .frame(width: 6, height: 6)
            .foregroundColor(.blue)
            .position(x: location.x, y: location.y)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.location = CGPoint(x: value.location.x, y: value.location.y)
                    }
                    .onEnded { value in
                        self.location = CGPoint(x: value.location.x, y: value.location.y)
                        printPosition()
                    }
            )
        
        
        
    }
    
    private func printPosition() {
        let xPercentage = location.x / imageSize.width
        let yPercentage = location.y / imageSize.height
        print(".position(x: imageSize.width * \(xPercentage), y: imageSize.height * \(yPercentage))")
        self.position = "\(xPercentage), \(yPercentage))"
    }
}


struct GalaxyMapTesting: View {
    @Binding var selectedPlanet: UpdatedPlanet?
    @State var planetLocation: CGPoint = CGPoint(x: 100, y: 100)
    
    @Binding var position: String
    @Binding var showSupplyLines: Bool
    @Binding var showAllPlanets: Bool
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    func updatedPlanet(for position: PlanetPosition) -> UpdatedPlanet? {
        viewModel.updatedPlanets.first(where: { $0.index == position.index })
    }
    
    // to get position for planet so we can draw supply lines
    private func position(forPlanetIndex index: Int, in size: CGSize) -> CGPoint? {
        guard let planetPosition = planetPositions.first(where: { $0.index == index }) else {
            return nil
        }
        return CGPoint(x: size.width * planetPosition.xMultiplier, y: size.height * planetPosition.yMultiplier)
    }
    
    func getColorForPlanet(planetPosition: PlanetPosition) -> Color {
        
        guard let planet = updatedPlanet(for: planetPosition) else {
            print("planet is not found for color")
            return .gray // default color if no matching planet found
        }
        
        
        if planet.currentOwner == "Humans" {
            if viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                let campaign = viewModel.updatedDefenseCampaigns.first { $0.planet.index == planet.index }
                switch campaign?.planet.event?.faction {
                case "Terminids": return .yellow
                case "Automaton": return .red
                case "Illuminate": return .blue
                default: return .cyan
                }
            } else {
                return .cyan
            }
        } else if viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet.index }) {
            if !viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                switch planet.currentOwner {
                case "Automaton": return .red
                case "Terminids": return .yellow
                case "Illuminate": return .blue
                default: return .gray // default color if currentOwner dont match any known factions
                }
            }
        } else {
            // planet musnt be part of any campaigns, colour it based on current owner
            switch planet.currentOwner {
            case "Automaton": return .red
            case "Terminids": return .yellow
            case "Illuminate": return .blue
            default: return .gray
            }
        }
        
        
        return .gray // if no conditions meet for some reason
        
        
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size
            ZStack {
                Image("sectorMap")
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .opacity(0.4)
                
                if showSupplyLines {
                    
                    // for supply lines, lines between each planet using the planets waypoints variable
                    ForEach(viewModel.updatedPlanets, id: \.index) { updatedPlanet in
                        if let startPoint = position(forPlanetIndex: updatedPlanet.index, in: imageSize) {
                            ForEach(updatedPlanet.waypoints, id: \.self) { waypointIndex in
                                if let endPoint = position(forPlanetIndex: waypointIndex, in: imageSize) {
                                    Path { path in
                                        path.move(to: startPoint)
                                        path.addLine(to: endPoint)
                                    }
                                    .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [2, 1]))
                                    .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    
                }
                
                ForEach(planetPositions.filter { planet in
                    showAllPlanets || viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet.index })
                }, id: \.index) { planet in
                    
                    
                    // determine if in an active campaign,
                    let activeCampaign = viewModel.updatedCampaigns.first(where: { $0.planet.index == planet.index })
                    let isDefending = viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index })
                    
                    // change size of circle, if its in a campaign or selected it should be larger
                    let circleSize = viewModel.selectedPlanet?.index == planet.index ? 10 :
                    ((activeCampaign != nil) ? 8 : 6)
                    
                    ZStack {
                        
                        Circle()
                            .frame(width: viewModel.selectedPlanet?.index == planet.index ? 10 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6), height: viewModel.selectedPlanet?.index == planet.index ? 10 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6))
                            .position(
                                x: imageSize.width * planet.xMultiplier,
                                y: imageSize.height * planet.yMultiplier
                            )
                        
                        
                            .foregroundColor(
                                getColorForPlanet(planetPosition: planet)
                            )
                        
                        if let percentage = activeCampaign?.planet.percentage {
                            let progress = percentage / 100.0
                            
                            CircularProgressView(progress: progress, color: getColorForPlanet(planetPosition: planet))
                                   .frame(width: viewModel.selectedPlanet?.index == planet.index ? 8 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4), height: viewModel.selectedPlanet?.index == planet.index ? 8 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4))
                                   .position(
                                       x: imageSize.width * planet.xMultiplier,
                                       y: imageSize.height * planet.yMultiplier
                                   )
                            
                        }
                        
                     /*   */
                        
                    }
                    
                        .overlay(
                            Group {
                                if viewModel.selectedPlanet?.index == planet.index {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 0.6)
                                        .frame(width: 12, height: 12)
                                        .position(
                                            x: imageSize.width * planet.xMultiplier,
                                            y: imageSize.height * planet.yMultiplier
                                        )
                                }
                            }
                        )
                    
                        .onTapGesture {
                            print("\(planet.name) tapped")
                            withAnimation(.bouncy) {
                                viewModel.selectedPlanet = viewModel.updatedPlanets.first(where: { $0.index == planet.index })
                                
                            }
                            
                        }
                }
                
                
                
                
                /*
                 DraggablePlanetView(location: $planetLocation, imageSize: imageSize, position: $position)
                 */
            }.shadow(radius: 3)
        }
    }
}


#Preview {
    MapRootViewTest()
}

struct MapRootViewTest: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    @State var planetName: String = ""
    @State var position: String = ""
    
    @State var showSupplyLines = false
    @State var showAllPlanets = false
    
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
        
        // deprecated navview used here instead of stack, stack doesnt work with the zoomable modifier/package - leads to strange zooming to the upper left corner
        // nav is needed to be able to tap planets
        NavigationView {
            
            ZStack(alignment: .top) {
                
              
                
                VStack(spacing: 0) {
                    
                    Spacer(minLength: 300)
                
                GalaxyMapTesting(selectedPlanet: $viewModel.selectedPlanet, position: $position, showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets).environmentObject(viewModel)
                
                    .frame(width: 300, height: 300)
                    .contentShape(Rectangle())
                    .zoomable(
                        minZoomScale: 1.0,
                        doubleTapZoomScale: 3,
                        outOfBoundsColor: .clear
                    )
                
                    .padding()
                
                    .clipShape(Rectangle())
                
                    .padding(.bottom, 20)
                
            }
                
                if let selectedPlanet = viewModel.selectedPlanet {
                    
                    
                    let eventExpirationTime = selectedPlanet.event?.expireTimeDate
                    
                    
                    
                    PlanetView(planetName: selectedPlanet.name, liberation: liberationPercentage, rate: selectedPlanet.regenPerSecond, playerCount: selectedPlanet.statistics.playerCount, planet: selectedPlanet, liberationType: isDefending ? .defense : .liberation, eventExpirationTime: eventExpirationTime, isInMapView: true, isActive: isActive).environmentObject(viewModel)
                        .padding(.horizontal)
                        .frame(maxHeight: 300)
                        .animation(.bouncy, value: isActive)
                    
                    // wrapping the planet view as a nav link directly doesnt work, but overlaying a clear view that is the nav link does! ebic hax
                        .contentShape(Rectangle())
                        .overlay {
                            NavigationLink(destination: PlanetInfoView(planet: selectedPlanet)) {
                                
                                Color.clear
                                
                            }
                        }
                    
                    
                }
                
            }
            .background {
                Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
            }
            
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button(action: {
                        
                        MapSettingsPopup(showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets).showAndStack()
                        
                    }){
                        Image(systemName: "gearshape.fill")
                    }.tint(.white)
                    
                }
                
                ToolbarItem(placement: .principal) {
                    Text("GALAXY MAP")
                        .font(Font.custom("FS Sinclair", size: 24))
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
            
        }
        // set custom nav title front
        .introspect(.navigationView(style: .stack), on: .iOS(.v16, .v17)) { controller in
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
        
    }
    
    
}

