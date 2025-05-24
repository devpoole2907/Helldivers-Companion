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
    
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size
            let displayModels = viewModel.planetDisplayModels(from: allPlanets, imageSize: geometry.size)
            ZStack {
                
                
                
                Image(isWidget ? "sectorMap800" : "sectorMap")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .opacity(0.4)
                
                
                if showSupplyLines {
                    ForEach(viewModel.supplyLineModels(for: allPlanets, allCampaigns: allCampaigns, showAll: showAllPlanets, imageSize: geometry.size)) { line in
                        Path { path in
                            path.move(to: line.start)
                            path.addLine(to: line.end)
                        }
                        .stroke(line.color, style: StrokeStyle(lineWidth: 1, dash: [2, 1]))
                        .allowsHitTesting(false)
                    }
                }
                // this can be improved.. A LOT, but at least for now itll do, gets the feat out the door until i can return with a fresh brain
                
                ForEach(displayModels) { model in
                    PlanetNodeView(
                        model: model,
                        isSelected: selectedPlanet?.index == model.id,
                        selectedPlanet: $selectedPlanet,
                        showPlanetNames: showPlanetNames,
                        currentZoomLevel: currentZoomLevel
                    )
                }
                
                /*
                 DraggablePlanetView(location: $planetLocation, imageSize: imageSize, position: $position)
                 */
            }
            .shadow(radius: 3)
            
        }
    }
}

private struct PlanetNodeView: View {
    let model: PlanetDisplayModel
    let isSelected: Bool
    @Binding var selectedPlanet: UpdatedPlanet?
    let showPlanetNames: Bool
    let currentZoomLevel: CGFloat

    @State private var isScaled = false

    var body: some View {
        let planet = model.planet
        let position = model.position

        let frameSize: CGFloat = isSelected ? 10 : (model.isInCampaign ? 8 : 6)
        let iconSize: CGFloat = isSelected ? 8 : 4
        let effectSize: CGFloat = isSelected ? 6 : 3
        let effectXOffset: CGFloat = isSelected ? 8 : 4
        let nameYOffset: CGFloat = isSelected ? -10 : -5.5
        let spaceStationXOffset: CGFloat = isSelected ? -7 : -4
        let spaceStationYOffset: CGFloat = isSelected ? -6 : -4

        ZStack {
            if model.isDefending || model.isTaskPlanet {
                Circle()
                    .scaleEffect(isScaled ? 2.0 : 0.8)
                    .opacity(isScaled ? 0 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isScaled)
                    .frame(width: frameSize, height: frameSize)
                    .position(position)
                    .foregroundStyle(model.isDefending ? .red : .yellow)
            }

            Circle()
                .frame(width: frameSize, height: frameSize)
                .position(position)
                .foregroundStyle(
                    (planet.galacticEffects?.contains { $0.name?.localizedCaseInsensitiveContains("black hole") == true } ?? false)
                    ? Color(red: 63/255, green: 44/255, blue: 141/255)
                    : planet.factionColor
                )
                .opacity(
                    (planet.galacticEffects?.contains { $0.name?.localizedCaseInsensitiveContains("fractured") == true } ?? false)
                    ? 0.3 : 1.0
                )

            if model.hasSpaceStation {
                Image("dssIcon")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .position(position)
                    .offset(x: spaceStationXOffset, y: spaceStationYOffset)
                    .allowsHitTesting(false)
                    .foregroundStyle(.white)
            }

            if let effects = planet.galacticEffects?.filter({ $0.imageName != nil && $0.showImageOnMap })
                .uniqued(on: \.imageName).prefix(2) {
                ForEach(Array(effects.enumerated()), id: \.element.galacticEffectId) { index, effect in
                    if let imageName = effect.imageName {
                        Image(imageName)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: effectSize, height: effectSize)
                            .position(
                                x: position.x + (index == 1 ? effectXOffset : 0),
                                y: position.y + CGFloat(index * 4)
                            )
                            .offset(x: 2, y: nameYOffset)
                            .allowsHitTesting(false)
                            .foregroundStyle(imageName == "alert" ? .red : .white)
                    }
                }
            }

            if let percentage = model.defenseProgress {
                CircularProgressView(progress: percentage / 100.0, color: planet.factionColor)
                    .frame(width: iconSize, height: iconSize)
                    .position(position)
            } else if let percentage = model.majorOrderProgress {
                CircularProgressView(progress: percentage / 100.0, color: planet.factionColor)
                    .frame(width: iconSize, height: iconSize)
                    .position(position)
            }

            if showPlanetNames && !isSelected && currentZoomLevel > 1.5 {
                Text(planet.name)
                    .shadow(radius: 3)
                    .multilineTextAlignment(.center)
                    .font(Font.custom("FSSinclair", size: 50)).bold()
                    .scaleEffect(0.04)
                    .position(position)
                    .offset(x: 4, y: 5)
                    .frame(minWidth: 100)
                    .allowsHitTesting(false)
            }

            if planet.galacticEffects?.contains(where: { $0.name?.lowercased().contains("gloom") ?? false }) ?? false {
                Image("gloom").resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.yellow)
                    .frame(width: 30, height: 30)
                    .position(position)
                    .allowsHitTesting(false)
            }
        }
        .onAppear { isScaled = true }
        .overlay(
            Group {
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 0.6)
                        .frame(width: 12, height: 12)
                        .position(position)
                }
            }
        )
        .onTapGesture {
            withAnimation(.bouncy) {
                selectedPlanet = isSelected ? nil : planet
            }
        }
    }
}
