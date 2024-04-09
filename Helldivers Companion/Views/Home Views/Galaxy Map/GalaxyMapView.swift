//
//  GalaxyMapView.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/04/2024.
//

import SwiftUI

struct GalaxyMapView: View {
    @Binding var selectedPlanet: UpdatedPlanet?
    @State var planetLocation: CGPoint = CGPoint(x: 100, y: 100)
    
    @Binding var position: String
    @Binding var showSupplyLines: Bool
    @Binding var showAllPlanets: Bool
    @Binding var showPlanetNames: Bool
    
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
    
    private func isPlanetVisible(position: CGPoint, in globalFrame: CGRect) -> Bool {
            // Adjust these thresholds to control how far off-screen planets should start rendering their names
            let visibilityMargin: CGFloat = 100

            let visibleRect = globalFrame.insetBy(dx: -visibilityMargin, dy: -visibilityMargin)
            return visibleRect.contains(position)
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
                    
                    let planetPosition = CGPoint(
                                                x: imageSize.width * planet.xMultiplier,
                                                y: imageSize.height * planet.yMultiplier
                                            )
                    
                    
                    // determine if in an active campaign,
                    let activeCampaign = viewModel.updatedCampaigns.first(where: { $0.planet.index == planet.index })
                    let isDefending = viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index })
                    
                    // change size of circle, if its in a campaign or selected it should be larger
                    let circleSize = viewModel.selectedPlanet?.index == planet.index ? 10 :
                    ((activeCampaign != nil) ? 8 : 6)
                    
                    ZStack {
            
                            Circle()
                                .frame(width: viewModel.selectedPlanet?.index == planet.index ? 10 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6), height: viewModel.selectedPlanet?.index == planet.index ? 10 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6))
                                .position(planetPosition)
                            
                            
                                .foregroundColor(
                                    getColorForPlanet(planetPosition: planet)
                                )
                            
                            if let percentage = activeCampaign?.planet.percentage {
                                let progress = percentage / 100.0
                                
                                CircularProgressView(progress: progress, color: getColorForPlanet(planetPosition: planet))
                                    .frame(width: viewModel.selectedPlanet?.index == planet.index ? 8 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4), height: viewModel.selectedPlanet?.index == planet.index ? 8 : viewModel.selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4))
                                    .position(planetPosition)
                                
                            }
                        
                        if showPlanetNames && viewModel.selectedPlanet?.index != planet.index {
                           // dont show floating planet name if they have tapped on it, thats duplicate info in the ui they can see it already
                           Text("\(planet.name)")
                                .shadow(radius: 3)
                               .multilineTextAlignment(.center)
                               .font(Font.custom("FS Sinclair Bold", size: 50))
                               .scaleEffect(0.04)
                               .position(planetPosition)
                               .offset(x: 4, y: 5)
                               .frame(minWidth: 100)
                               .allowsHitTesting(false)
                       }
                            
                           
                            
                        
                        
                     /*   */
                        
                    }
                    
                        .overlay(
                            Group {
                                if viewModel.selectedPlanet?.index == planet.index {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 0.6)
                                        .frame(width: 12, height: 12)
                                        .position(planetPosition)
                                    
                                }
                            }.allowsHitTesting(false)
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

