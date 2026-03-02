//
//  GalaxyMapView.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/04/2024.
//

import SwiftUI
import Algorithms

struct GalaxyMapView: View {
    @Binding var selectedPlanet: UpdatedPlanet?
    @State var planetLocation: CGPoint = CGPoint(x: 100, y: 100)
    
    @Binding var showSupplyLines: Bool
    @Binding var showAllPlanets: Bool
    @Binding var showPlanetNames: Bool
    @Binding var currentZoomLevel: CGFloat
    
    @State private var isScaled = false // for defense planets pulsing scale
    
    var planets: [UpdatedPlanet] = []
    var campaigns: [UpdatedCampaign] = []
    var defenseCampaigns: [UpdatedCampaign] = []
    // Widget-path overrides — when non-empty, these replace the corresponding viewModel lookups
    var widgetSpaceStations: [SpaceStation] = []
    var widgetTaskPlanets: [UpdatedPlanet] = []

    var isWidget: Bool = false // to use a different sector image file thats smaller than 4k x 4k (a pdf)

    // computed prop, either use passed planets array if a widget otherwise go straight to viewmodel's published prop
    var allPlanets: [UpdatedPlanet] {
        return planets.isEmpty ? viewModel.updatedPlanets : planets
    }
    
    // computed prop, either use passed campaign planets array if a widget otherwise go straight to viewmodel's published prop
    var allCampaigns: [UpdatedCampaign] {
        return campaigns.isEmpty ? viewModel.updatedCampaigns : campaigns
    }
    
    // computed prop, either use passed defense campaign planets array if a widget otherwise go straight to viewmodel's published prop
    var allDefenseCampaigns: [UpdatedCampaign] {
        return defenseCampaigns.isEmpty ? viewModel.updatedDefenseCampaigns : defenseCampaigns
    }
    
    @Environment(PlanetsDataModel.self) var viewModel

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
    
    private func isPlanetVisible(position: CGPoint, in globalFrame: CGRect) -> Bool {
            // Adjust these thresholds to control how far off-screen planets should start rendering their names
            let visibilityMargin: CGFloat = 100

            let visibleRect = globalFrame.insetBy(dx: -visibilityMargin, dy: -visibilityMargin)
            return visibleRect.contains(position)
        }

    // linear transform constants derived
    private let scaleX: CGFloat = 0.4802
    private let offsetX: CGFloat = 0.5
    private let scaleY: CGFloat = -0.468
    private let offsetY: CGFloat = 0.5
    
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
                
                
                // Use the pre-built context lookup (rebuilt once per refresh) to avoid
                // repeated .first(where:) scans per planet per render.
                let ctxLookup = campaigns.isEmpty ? viewModel.contextLookup : [Int: PlanetContext]()

                // Widget-path fallback: precompute flat lookups once per render so the
                // ForEach bodies below stay O(1) rather than O(n) per planet.
                let activeCampaignIndices: Set<Int> = ctxLookup.isEmpty
                    ? Set(allCampaigns.map(\.planet.index))
                    : []
                let defensePercentageLookup: [Int: Double] = ctxLookup.isEmpty
                    ? Dictionary(uniqueKeysWithValues: allDefenseCampaigns.compactMap { c -> (Int, Double)? in
                        guard let pct = c.planet.event?.percentage else { return nil }
                        return (c.planet.index, pct)
                    })
                    : [:]

                if showSupplyLines {
                    
                    // for supply lines, lines between each planet using the planets waypoints variable
                    ForEach(allPlanets, id: \.index) { updatedPlanet in
                        if let startPoint = boundingBoxTransformedPosition(forPlanetIndex: updatedPlanet.index,
                                                                           in: imageSize) {
                            ForEach(updatedPlanet.waypoints, id: \.self) { waypointIndex in
                                if let endPoint = boundingBoxTransformedPosition(forPlanetIndex: waypointIndex,
                                                                                 in: imageSize),
                                   showAllPlanets || activeCampaignIndices.contains(updatedPlanet.index) || activeCampaignIndices.contains(waypointIndex) ||
                                    updatedPlanet.ownerFaction != .human {
                                    Path { path in
                                        path.move(to: startPoint)
                                        path.addLine(to: endPoint)
                                    }
                                    
                                    .stroke(
                                        (ctxLookup[updatedPlanet.index]?.isDefending ?? defensePercentageLookup.keys.contains(updatedPlanet.index)) ? Color.cyan.opacity(0.5) : updatedPlanet.factionColor.opacity(0.5),
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
                        let isOwnerNotHuman = updatedPlanet.ownerFaction != .human
                        let isInCampaign = activeCampaignIndices.contains(updatedPlanet.index)

                        let hasWaypointToCampaign = updatedPlanet.waypoints.contains { waypointIndex in
                            activeCampaignIndices.contains(waypointIndex)
                        }

                        let isTargetOfCampaign = allPlanets.contains { planet in
                            planet.waypoints.contains(updatedPlanet.index) &&
                            activeCampaignIndices.contains(planet.index)
                        }
                        
                        return isInCampaign
                        || isOwnerNotHuman
                        || hasWaypointToCampaign
                        || isTargetOfCampaign
                    }
                    
                }, id: \.index) { updatedPlanet in
                    
                    let planetPosition = boundingBoxTransformedPosition(for: updatedPlanet, imageSize: imageSize)

                    // Use pre-built context when available (main app), fall back to
                    // per-planet lookups for widget path where contextLookup isn't available.
                    let ctx = ctxLookup[updatedPlanet.index]
                    
                    // determine if has dss stationed here
                    let hasSpaceStation: Bool = {
                        if let ctx { return ctx.spaceStation != nil }
                        let stations = widgetSpaceStations.isEmpty ? viewModel.spaceStations : widgetSpaceStations
                        return stations.first?.planet.index == updatedPlanet.index
                    }()

                    // Use pre-built context booleans when available; fall back to O(1) lookups for the widget path.
                    let isActiveCampaign = ctx?.isActive ?? activeCampaignIndices.contains(updatedPlanet.index)
                    let isDefending = ctx?.isDefending ?? (defensePercentageLookup[updatedPlanet.index] != nil)
                    // Defense progress: use pre-computed liberationPercentage from context when available;
                    // fall back to the precomputed defense percentage lookup for the widget path.
                    let defenseProgressPercentage: Double? = isDefending
                        ? (ctx?.liberationPercentage ?? defensePercentageLookup[updatedPlanet.index])
                        : nil
                    
                    
                    ZStack {
                        
                        // show red expanding ring around defense planets
                        let taskPlanets = widgetTaskPlanets.isEmpty ? viewModel.updatedTaskPlanets : widgetTaskPlanets
                        let isMajorOrderTarget = ctx?.isMajorOrderTarget ?? taskPlanets.contains(where: { $0.index == updatedPlanet.index })
                        let dotSize: CGFloat = selectedPlanet?.index == updatedPlanet.index ? 10 : (isActiveCampaign ? 8 : 6)
                        if isDefending || isMajorOrderTarget {
                            Circle()
                                .scaleEffect(isScaled ? 2.0 : 0.8)
                                .opacity(isScaled ? 0 : 1.0)
                                           .animation(
                                               .easeInOut(duration: 1).repeatForever(autoreverses: false),
                                               value: isScaled
                                           )
                                        
                                           .frame(width: dotSize, height: dotSize)
                                .position(planetPosition)
                                .foregroundStyle(isDefending ? .red : .yellow)
                               
                            
                        }
                        
                        Circle()
                            .frame(width: dotSize, height: dotSize)
                            .position(planetPosition)
                        
                        
                            .foregroundStyle(
                                (updatedPlanet.galacticEffects?.contains {
                                    $0.name?.localizedCaseInsensitiveContains("black hole") == true
                                } ?? false)
                                ? Color(red: 63/255, green: 44/255, blue: 141/255)
                                : updatedPlanet.factionColor
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
                        
                        // GET THE CURRENT PLANETS FIRST TWO GALACTIC EFFECT (IF ANY) AND DISPLAY IMAGE IF IT EXISTS:
                        
                        if let effects = updatedPlanet.galacticEffects?.filter({ $0.imageName != nil && $0.showImageOnMap })
                            .uniqued(on: \.imageName) // dont show effects with same images
                            .prefix(2) {
                            ForEach(Array(effects.enumerated()), id: \.element.galacticEffectId) { index, effect in
                                if let imageName = effect.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                         .frame(width: selectedPlanet?.index == updatedPlanet.index ? 6 : 3, height: selectedPlanet?.index == updatedPlanet.index ? 6 : 3)
                                     .position(
                                     x: planetPosition.x + (index == 1 ? (selectedPlanet?.index == updatedPlanet.index ? 8 : 4) : 0), // offset right
                                     y: planetPosition.y + CGFloat(index * 4)   // offset down
                                     )
                                     .offset(x: 2, y: selectedPlanet?.index == updatedPlanet.index ? -10 : -5.5)
                                     .allowsHitTesting(false)
                                     .foregroundStyle(imageName == "alert" ? .red : .white)
                                }
                            }
                        }
                        
                        let progressRingSize: CGFloat = selectedPlanet?.index == updatedPlanet.index ? 8 : (isActiveCampaign ? 6 : 4)
                        if let percentage = defenseProgressPercentage {
                            let progress = percentage / 100.0
                            CircularProgressView(progress: progress, color: updatedPlanet.factionColor)
                                .frame(width: progressRingSize, height: progressRingSize)
                                .position(planetPosition)
                        } else if isActiveCampaign {
                            let progress = updatedPlanet.percentage / 100.0
                            CircularProgressView(progress: progress, color: updatedPlanet.factionColor)
                                .frame(width: progressRingSize, height: progressRingSize)
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
