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
    @Binding var currentZoomLevel: CGFloat
    
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
    
    func getColorForPlanet(planet: UpdatedPlanet) -> Color {
        
        
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
    
    func boundingBoxTransformedPosition(for planet: UpdatedPlanet, imageSize: CGSize) -> CGPoint {
        let x = planet.position.x  // typically in [-1..+1]
        let y = planet.position.y  // typically in [-1..+1]

        // Convert from [-1..+1] → [0..1]
        let normalizedX = (x + 1) / 2
        // For Y, if the API has +Y as "up," we invert so +1 maps near the top of the image:
        let normalizedY = 1 - (y + 1) / 2

        // Then map [0..1] onto the actual image size:
        let finalX = normalizedX * imageSize.width
        let finalY = normalizedY * imageSize.height

        return CGPoint(x: finalX, y: finalY)
    }
    
    func boundingBoxTransformedPosition(forPlanetIndex index: Int, in size: CGSize) -> CGPoint? {
        guard let planet = allPlanets.first(where: { $0.index == index }) else { return nil }
        return boundingBoxTransformedPosition(for: planet, imageSize: size)
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
                        if let startPoint = boundingBoxTransformedPosition(forPlanetIndex: updatedPlanet.index,
                                                                           in: imageSize) {
                            ForEach(updatedPlanet.waypoints, id: \.self) { waypointIndex in
                                if let endPoint = boundingBoxTransformedPosition(forPlanetIndex: waypointIndex,
                                                                                 in: imageSize),
                                   (showAllPlanets || allCampaigns.contains(where: { $0.planet.index == updatedPlanet.index || $0.planet.index == waypointIndex }) ||
                                    allPlanets.first(where: { $0.index == updatedPlanet.index })?.currentOwner.lowercased() != "humans"){
                                    Path { path in
                                        path.move(to: startPoint)
                                        path.addLine(to: endPoint)
                                    }
                                    
                                    .stroke(
                                        allDefenseCampaigns.contains(where: { $0.planet.index == updatedPlanet.index }) ? Color.cyan.opacity(0.5) : getColorForPlanet(planet: updatedPlanet).opacity(0.5),
                                        style: StrokeStyle(lineWidth: 1, dash: [2, 1])
                                    )
                                    .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    
                }
                // this can be improved.. A LOT, but at least for now itll do, gets the feat out the door until i can return with a fresh brain
                
                ForEach(allPlanets.filter { updatedPlanet in
                    
                    if showAllPlanets {
                        return true
                    } else {
                        // replicate your old filter logic:
                        let isOwnerNotHuman = updatedPlanet.currentOwner.lowercased() != "humans"
                        let isInCampaign = allCampaigns.contains { $0.planet.index == updatedPlanet.index }
                        
                        let hasWaypointToCampaign = updatedPlanet.waypoints.contains { waypointIndex in
                            allCampaigns.contains { $0.planet.index == waypointIndex }
                        }
                        
                        let isTargetOfCampaign = allPlanets.contains { planet in
                            planet.waypoints.contains(updatedPlanet.index) &&
                            allCampaigns.contains { $0.planet.index == planet.index }
                        }
                        
                        return isInCampaign
                        || isOwnerNotHuman
                        || hasWaypointToCampaign
                        || isTargetOfCampaign
                    }
                    
                }, id: \.index) { updatedPlanet in
                    
                    let planetPosition = boundingBoxTransformedPosition(for: updatedPlanet, imageSize: imageSize)
                    
                    // determine if has dss stationed here
                    let hasSpaceStation = viewModel.spaceStations.first?.planet.index == updatedPlanet.index
                    
                    
                    // determine if in an active campaign,
                    let activeCampaign = allCampaigns.first(where: { $0.planet.index == updatedPlanet.index })
                    let isDefending = allDefenseCampaigns.first(where: { $0.planet.index == updatedPlanet.index })
                    
                    // change size of circle, if its in a campaign or selected it should be larger
                    let circleSize = selectedPlanet?.index == updatedPlanet.index ? 10 :
                    ((activeCampaign != nil) ? 8 : 6)
                    
                    
                    ZStack {
                        
                        // show red expanding ring around defense planets
                        if (isDefending != nil || viewModel.updatedTaskPlanets.contains(where: { $0.index == updatedPlanet.index })) {
                            Circle()
                                .scaleEffect(isScaled ? 2.0 : 0.8)
                                .opacity(isScaled ? 0 : 1.0)
                                           .animation(
                                               .easeInOut(duration: 1).repeatForever(autoreverses: false),
                                               value: isScaled
                                           )
                                        
                                           .frame(width: selectedPlanet?.index == updatedPlanet.index ? 10 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 8 : 6), height: selectedPlanet?.index == updatedPlanet.index ? 10 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 8 : 6))
                                .position(planetPosition)
                                .foregroundStyle(isDefending != nil ? .red : .yellow)
                               
                            
                        }
                        
                        Circle()
                            .frame(width: selectedPlanet?.index == updatedPlanet.index ? 10 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 8 : 6), height: selectedPlanet?.index == updatedPlanet.index ? 10 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 8 : 6))
                            .position(planetPosition)
                        
                        
                            .foregroundStyle(
                                (updatedPlanet.galacticEffects?.contains {
                                    $0.name?.localizedCaseInsensitiveContains("black hole") == true
                                } ?? false)
                                ? Color(red: 63/255, green: 44/255, blue: 141/255)
                                : getColorForPlanet(planet: updatedPlanet)
                            )
                        
                            .opacity(
                                (updatedPlanet.galacticEffects?.contains {
                                    $0.name?.localizedCaseInsensitiveContains("fractured") == true
                                } ?? false)
                                ? 0.3
                                : 1.0
                            )
                        
                        // space station icon!
                        
                        if hasSpaceStation {
                            Image("dssIcon")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: selectedPlanet?.index == updatedPlanet.index ? 8 : 4, height: selectedPlanet?.index == updatedPlanet.index ? 8 : 4)
                                .position(planetPosition)
                                .offset(x: selectedPlanet?.index == updatedPlanet.index ? -7 : -4, y: selectedPlanet?.index == updatedPlanet.index ? -6 : -4)
                                .allowsHitTesting(false)
                                .foregroundStyle(.white)
                        }
                        
                        // galactic places of interest
                        
                        // GET THE CURRENT PLANETS FIRST GALACTIC EFFECT (IF ANY) AND DISPLAY IMAGE IF IT EXISTS:
                        
                        if let firstEffect = updatedPlanet.galacticEffects?.first, let imageName = firstEffect.imageName {
                            Image(imageName)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: selectedPlanet?.index == updatedPlanet.index ? 6 : 3, height: selectedPlanet?.index == updatedPlanet.index ? 6 : 3)
                                .position(planetPosition)
                                .offset(x: 2, y: selectedPlanet?.index == updatedPlanet.index ? -10 : -5.5)
                                .allowsHitTesting(false)
                                .foregroundStyle(.white)
                        }
                        
                        
                        if let defenseCampaign = isDefending {
                            
                            if let percentage = defenseCampaign.planet.event?.percentage {
                                let progress = percentage / 100.0
                                
                                CircularProgressView(progress: progress, color: getColorForPlanet(planet: updatedPlanet))
                                    .frame(width: selectedPlanet?.index == updatedPlanet.index ? 8 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 6 : 4), height: selectedPlanet?.index == updatedPlanet.index ? 8 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 6 : 4))
                                    .position(planetPosition)
                                
                            }
                            
                            
                        }
                        
                            else if let percentage = activeCampaign?.planet.percentage {
                                let progress = percentage / 100.0
                                
                                CircularProgressView(progress: progress, color: getColorForPlanet(planet: updatedPlanet))
                                    .frame(width: selectedPlanet?.index == updatedPlanet.index ? 8 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 6 : 4), height: selectedPlanet?.index == updatedPlanet.index ? 8 : selectedPlanet?.index == updatedPlanet.index ? 8 : (activeCampaign != nil ? 6 : 4))
                                    .position(planetPosition)
                                
                            }
                        
                        if showPlanetNames && selectedPlanet?.index != updatedPlanet.index && currentZoomLevel > 1.5 {
                           // dont show floating planet name if they have tapped on it, thats duplicate info in the ui they can see it already
                           Text("\(updatedPlanet.name)")
                                .shadow(radius: 3)
                               .multilineTextAlignment(.center)
                               .font(Font.custom("FSSinclair", size: 50)).bold()
                               .scaleEffect(0.04)
                               .position(planetPosition)
                               .offset(x: 4, y: 5)
                               .frame(minWidth: 100)
                               .allowsHitTesting(false)
                       }
                        
                        if updatedPlanet.galacticEffects?.contains(where: { $0.name?.lowercased().contains("gloom") ?? false }) ?? false {
                            Image("gloom").resizable()
                                .renderingMode(.template).aspectRatio(contentMode: .fit)
                                .foregroundStyle(.yellow)
                                .frame(width: 30, height: 30)
                                .position(planetPosition)
                                .allowsHitTesting(false)
                        }
                        
                    }
                    
                   .onAppear {
                                   isScaled = true
                               }
                    
                        .overlay(
                            Group {
                                if selectedPlanet?.index == updatedPlanet.index {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 0.6)
                                        .frame(width: 12, height: 12)
                                        .position(planetPosition)
                                    
                                }
                            }.allowsHitTesting(false)
                        )
                    
                        .onTapGesture {
                            print("\(updatedPlanet.name) tapped")
                            withAnimation(.bouncy) {
                                if selectedPlanet?.index == updatedPlanet.index {
                                            // deselect planet if same tapped
                                            selectedPlanet = nil
                                        } else {
                                       // otherwise select
                                            selectedPlanet = updatedPlanet
                                        }
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
