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
    
    @Binding var showSupplyLines: Bool
    @Binding var showAllPlanets: Bool
    @Binding var showPlanetNames: Bool
    
    @State private var isScaled = false // for defense planets pulsing scale
    
    var planets: [UpdatedPlanet]?
    var campaigns: [UpdatedCampaign]?
    var defenseCampaigns: [UpdatedCampaign]?
    
    var isWidget: Bool = false // to use a different sector image file thats smaller than 4k x 4k (a pdf)

    // computed prop, either use passed planets array if a widget otherwise go straight to viewmodel's published prop
    var allPlanets: [UpdatedPlanet] {
        return planets ?? viewModel.updatedPlanets
    }
    
    // computed prop, either use passed campaign planets array if a widget otherwise go straight to viewmodel's published prop
    var allCampaigns: [UpdatedCampaign] {
        return campaigns ?? viewModel.updatedCampaigns
    }
    
    // computed prop, either use passed defense campaign planets array if a widget otherwise go straight to viewmodel's published prop
    var allDefenseCampaigns: [UpdatedCampaign] {
        return defenseCampaigns ?? viewModel.updatedDefenseCampaigns
    }
    
    @EnvironmentObject var viewModel: PlanetsDataModel

    func updatedPlanet(for position: PlanetPosition) -> UpdatedPlanet? {
        allPlanets.first(where: { $0.index == position.index })
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
        
        
        if planet.currentOwner.lowercased() == "humans" {
            if allDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                let campaign = allDefenseCampaigns.first { $0.planet.index == planet.index }
                switch campaign?.planet.event?.faction {
                case "Terminids": return .yellow
                case "Automaton": return .red
                case "Illuminate": return .purple
                default: return .cyan
                }
            } else {
                return .cyan
            }
        } else if allCampaigns.contains(where: { $0.planet.index == planet.index }) {
            if !allDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                switch planet.currentOwner.lowercased() {
                case "automaton": return .red
                case "terminids": return .yellow
                case "illuminate": return .purple
                default: return .gray // default color if currentOwner dont match any known factions
                }
            }
        } else {
            // planet musnt be part of any campaigns, colour it based on current owner
            switch planet.currentOwner.lowercased() {
            case "automaton": return .red
            case "terminids": return .yellow
            case "illuminate": return .purple
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
    
    // TODO: grab planet positions from api, meridia is moving!
    // linear transform constants derived
    private let scaleX: CGFloat = 0.4802
    private let offsetX: CGFloat = 0.5
    private let scaleY: CGFloat = -0.468
    private let offsetY: CGFloat = 0.5
    
    func transformedPosition(for planet: UpdatedPlanet, imageSize: CGSize) -> CGPoint {
        let x = planet.position.x
        let y = planet.position.y
        
        // apply  derived transform
        let finalX = scaleX * x + offsetX
        let finalY = scaleY * y + offsetY
        
        
        return CGPoint(
            x: imageSize.width * finalX,
            y: imageSize.height * finalY
        )
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size
            ZStack {
                
                
             
                Image(isWidget ? "sectorMap800" : "sectorMap")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .opacity(0.4)
                
         
                if showSupplyLines {
                    
                    // for supply lines, lines between each planet using the planets waypoints variable
                    ForEach(allPlanets, id: \.index) { updatedPlanet in
                        if let startPoint = position(forPlanetIndex: updatedPlanet.index, in: imageSize) {
                            ForEach(updatedPlanet.waypoints, id: \.self) { waypointIndex in
                                if let endPoint = position(forPlanetIndex: waypointIndex, in: imageSize),
                                                   (showAllPlanets || allCampaigns.contains(where: { $0.planet.index == updatedPlanet.index || $0.planet.index == waypointIndex }) ||
                                                    allPlanets.first(where: { $0.index == updatedPlanet.index })?.currentOwner.lowercased() != "humans"){
                                    Path { path in
                                        path.move(to: startPoint)
                                        path.addLine(to: endPoint)
                                    }
                                    
                                    .stroke(
                                       allDefenseCampaigns.contains(where: { $0.planet.index == updatedPlanet.index }) ? Color.cyan.opacity(0.5) : getColorForPlanet(planetPosition: PlanetPosition(name: updatedPlanet.name, index: updatedPlanet.index, xMultiplier: 0, yMultiplier: 0)).opacity(0.5),
                                                                       style: StrokeStyle(lineWidth: 1, dash: [2, 1])
                                                                   )
                                    .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    
                }
                // this can be improved.. A LOT, but at least for now itll do, gets the feat out the door until i can return with a fresh brain
                ForEach(planetPositions.filter { planetPosition in
                    if showAllPlanets {
                        return true
                    } else {
                        let currentPlanet = allPlanets.first { $0.index == planetPosition.index }
                        let isOwnerNotHuman = currentPlanet?.currentOwner.lowercased() != "humans"
                        let isInCampaign = allCampaigns.contains(where: { $0.planet.index == planetPosition.index })
                        
                        // check if any waypoints from this planet lead to a campaign planet
                        let hasWaypointToCampaign = currentPlanet?.waypoints.contains(where: { waypointIndex in
                            allCampaigns.contains(where: { $0.planet.index == waypointIndex })
                        }) ?? false
                        
                        let isTargetOfCampaign = allPlanets.contains { planet in
                                    planet.waypoints.contains(planetPosition.index) &&
                                    allCampaigns.contains(where: { $0.planet.index == planet.index })
                                }
                        
                        return isInCampaign || isOwnerNotHuman || hasWaypointToCampaign || isTargetOfCampaign
                    }
                }, id: \.index) { planet in
                    
                    let planetPosition = CGPoint(
                                                x: imageSize.width * planet.xMultiplier,
                                                y: imageSize.height * planet.yMultiplier
                                            )
                    
                    // determine if has dss stationed here
                    let hasSpaceStation = viewModel.spaceStations.first?.planet.index == planet.index
                    
                    
                    // determine if in an active campaign,
                    let activeCampaign = allCampaigns.first(where: { $0.planet.index == planet.index })
                    let isDefending = allDefenseCampaigns.first(where: { $0.planet.index == planet.index })
                    
                    // change size of circle, if its in a campaign or selected it should be larger
                    let circleSize = selectedPlanet?.index == planet.index ? 10 :
                    ((activeCampaign != nil) ? 8 : 6)
                    
                    ZStack {
                        // show red expanding ring around defense planets
                        if (isDefending != nil || viewModel.updatedTaskPlanets.contains(where: { $0.index == planet.index })) {
                            Circle()
                                .scaleEffect(isScaled ? 2.0 : 0.8)
                                .opacity(isScaled ? 0 : 1.0)
                                           .animation(
                                               .easeInOut(duration: 1).repeatForever(autoreverses: false),
                                               value: isScaled
                                           )
                                        
                                .frame(width: selectedPlanet?.index == planet.index ? 10 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6), height: selectedPlanet?.index == planet.index ? 10 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6))
                                .position(planetPosition)
                                .foregroundStyle(isDefending != nil ? .red : .yellow)
                               
                            
                        }
            
                            Circle()
                                .frame(width: selectedPlanet?.index == planet.index ? 10 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6), height: selectedPlanet?.index == planet.index ? 10 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 8 : 6))
                                .position(planetPosition)
                            
                            
                                .foregroundStyle(planet.name.lowercased().contains("meridia") ? Color(red: 63/255, green: 44/255, blue: 141/255) : getColorForPlanet(planetPosition: planet)
                                )
                        
                        // space station icon!
                        
                        if hasSpaceStation {
                            Image("dssIcon")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: selectedPlanet?.index == planet.index ? 8 : 4, height: selectedPlanet?.index == planet.index ? 8 : 4)
                                .position(planetPosition)
                                .offset(x: selectedPlanet?.index == planet.index ? -7 : -4, y: selectedPlanet?.index == planet.index ? -6 : -4)
                                .allowsHitTesting(false)
                                .foregroundStyle(.white)
                        }
                            
                        
                        if let defenseCampaign = isDefending {
                            
                            if let percentage = defenseCampaign.planet.event?.percentage {
                                let progress = percentage / 100.0
                                
                                CircularProgressView(progress: progress, color: getColorForPlanet(planetPosition: planet))
                                    .frame(width: selectedPlanet?.index == planet.index ? 8 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4), height: selectedPlanet?.index == planet.index ? 8 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4))
                                    .position(planetPosition)
                                
                            }
                            
                            
                        }
                        
                            else if let percentage = activeCampaign?.planet.percentage {
                                let progress = percentage / 100.0
                                
                                CircularProgressView(progress: progress, color: getColorForPlanet(planetPosition: planet))
                                    .frame(width: selectedPlanet?.index == planet.index ? 8 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4), height: selectedPlanet?.index == planet.index ? 8 : selectedPlanet?.index == planet.index ? 8 : (activeCampaign != nil ? 6 : 4))
                                    .position(planetPosition)
                                
                            }
                        
                        if showPlanetNames && selectedPlanet?.index != planet.index {
                           // dont show floating planet name if they have tapped on it, thats duplicate info in the ui they can see it already
                           Text("\(planet.name)")
                                .shadow(radius: 3)
                               .multilineTextAlignment(.center)
                               .font(Font.custom("FSSinclair", size: 50)).bold()
                               .scaleEffect(0.04)
                               .position(planetPosition)
                               .offset(x: 4, y: 5)
                               .frame(minWidth: 100)
                               .allowsHitTesting(false)
                       }
                            
                           
                            
                        
                        
                     /*   */
                        
                    }
                    
                    .onAppear {
                                   isScaled = true
                               }
                    
                        .overlay(
                            Group {
                                if selectedPlanet?.index == planet.index {
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
                                if selectedPlanet?.index == planet.index {
                                            // deselect planet if same tapped
                                            selectedPlanet = nil
                                        } else {
                                       // otherwise select
                                            selectedPlanet = allPlanets.first(where: { $0.index == planet.index })
                                        }
                            }
                            
                        }
                }
                
                // TODO: grab planet positions from api, meridia is moving!
                
                // loop through allPlanets and grab their positions etc
                /*
                
                ForEach(allPlanets, id: \.index) { planet in
                    let point = transformedPosition(for: planet, imageSize: geometry.size)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 5, height: 5)
                        .position(point)
                }
                 .allowsHitTesting(false)
                */
                
                /*
                 DraggablePlanetView(location: $planetLocation, imageSize: imageSize, position: $position)
                 */
            }.shadow(radius: 3)
        }
    }
}
