//
//  PlanetInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI
struct PlanetInfoView: View {
    
    @Environment(PlanetsDataModel.self) var viewModel
    @Environment(NavigationPather.self) var navPath
    
    @State private var infoType: InfoType = .warEffort
    
    @State var showIlluminateStats = true // for redacted animation
    @State var showRedactedText = false
    
    let planetIndex: Int
    
    private var planetData: [UpdatedPlanetDataPoint] {
        viewModel.planetHistory[planet?.name ?? ""] ?? []
    }
    
    var showEnergyBar: Bool {
        planet?.index == 64 && viewModel.configData.meridiaEvent // hardcoded to meridia at this stage
    }
    
    var darkEnergyResource: GlobalResource? {
        guard let resources = viewModel.status?.globalResources else { return nil }
        return resources.resource(for: .darkEnergy)
    }
    
    var darkEnergyProgress: Double {
        guard let resource = darkEnergyResource else { return 0 }
        return Double(resource.currentValue) / Double(resource.maxValue)
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planet)
        
    }
    
    private var context: PlanetContext? {
        viewModel.context(for: planetIndex)
    }

    // Convenience accessors — all backed by context so no extra lookups
    private var planet: UpdatedPlanet? { context?.planet }

    private var campaign: Bool { context?.isActive ?? false }
    private var liberationType: LiberationType { context?.liberationType ?? .liberation }
    private var liberationPercentage: Double? { context?.liberationPercentage }
    private var liberationTimeRemaining: Date? { context?.liberationTimeRemaining }
    private var eventExpirationTime: Date? { context?.eventExpiration }
    private var eventInvasionLevel: Int64? { context?.invasionLevel }
    private var eventHealth: Int64? { context?.eventHealth }
    private var eventMaxHealth: Int64? { context?.eventMaxHealth }
    private var spaceStationExpirationTime: Date? { context?.spaceStationExpiration }
    private var activeSpaceStationDetails: SpaceStationDetails? { context?.spaceStationDetails }
    var matchingRegions: [Region] { context?.matchingRegions ?? [] }

    private var pointsOfInterest: [GalacticEffect] {
        planet?.galacticEffects ?? []
    }
    
#if os(watchOS)
    
    let dividerWidth: CGFloat = 100
    let smallerDividerWidth: CGFloat = 80
    let horizPadding: CGFloat = 5
    let extraStatSplitter = "\n" // split by new line on watchos
    
#else
    
    let dividerWidth: CGFloat = 300
    let smallerDividerWidth: CGFloat = 200
    let horizPadding: CGFloat = 20
    let extraStatSplitter = " " // split by space on ios
    
    var viewOnMapButton: some View {
        
        Button(action: {
            
            // take em to the map!
            viewModel.selectedPlanet = planet
            viewModel.popMapToRoot.send()
            
        }, label: {
            HStack(spacing: 6){
                Image(systemName: "mappin.and.ellipse")
                    .bold()
                    .font(.callout)
                    .padding(.bottom, 2)
                Text("View on Map").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                    .font(Font.custom("FSSinclair", size: 16))
                
            }
            
            
        }).padding(.horizontal)
            .padding(.vertical, 5)
            .frame(height: 40)
            .background(Material.thin)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
        
        
        
        
    }
    
#endif
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                
                
                imageWithSectorName
                
                if showEnergyBar {
                    
                    darkEnergyTracker.padding(.horizontal)
                }
                
                // if this planet is in a major order
                if context?.isMajorOrderTarget == true {
                    majorOrderPlanetNotice.padding(.horizontal)
                }
                
                if let spaceStationExpiration = spaceStationExpirationTime {
                    SpaceStationView(spaceStationExpiration: spaceStationExpiration, spaceStationDetails: activeSpaceStationDetails, warTime: viewModel.warTime, isWidget: false, showFullInfo: true)
                        .padding(.horizontal)
                }
                
                // any regions
                
                if !matchingRegions.isEmpty && campaign {
                    
                    
                    RegionListView(
                        regions: matchingRegions,
                        showOnlyTopRegion: false, factionColor: planet?.factionColor ?? Color.gray, horizPadding: horizPadding
                    ) .padding(.bottom, 20)
                    
                }
                
                
                VStack(alignment: .leading, spacing: 14) {
                    
                    // dont show if not currently fighting
                    if campaign {
                        
                        CustomSegmentedPicker(selection: $infoType, items: InfoType.allCases)
                            .frame(maxWidth: .infinity)
                        
                            .padding(.bottom, 40)
                        
                    }
                    
                    
                    
                    
                    // dont show this data if the planet isnt a current campaign
                    if campaign && infoType == .warEffort {
                        HistoryChart(liberationType: liberationType, planetData: planetData, factionColor: planet?.factionColor ?? Color.gray).environment(viewModel)
                            .shadow(radius: 5.0)
                        VStack(alignment: .center, spacing: 2) {
                            if let timeRemaining = liberationTimeRemaining {
                                Group {
                                    Text("\(liberationType == .defense ? "DEFENDED" : "LIBERATION") IN: ")
                                    + Text(timeRemaining, style: .relative)
                                    
                                    
                                }.font(Font.custom("FSSinclair-Bold", size: smallFont))
                                    .foregroundStyle(.white)
                                    .shadow(radius: 5.0)
                                
                            }
                            if let context = context {
                                CampaignPlanetStatsView(context: context)
                                    .shadow(radius: 5.0)
                            }
                        }
                        
                    } else {
                        
                        if planet?.biome.name != nil {
                            biomeDescription
                            
                        }
                        
                        // display any galactic effects in the planet
                        
                        if !pointsOfInterest.isEmpty {
                            
                            galacticEffects
                            
                        }
                                       
                                   
                        
                        if let environmentals = planet?.hazards, !environmentals.isEmpty {
                            environmentsList
                            
                        }
                        
                        if planet?.statistics != nil {
                            statsList
                        }
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                }  .padding(.horizontal, horizPadding)
                
                Spacer(minLength: 150)
                
            }
            
#if os(iOS)
            
            if viewModel.currentTab != .map {
                viewOnMapButton.padding(.bottom, 60)
                    .padding(.trailing, 10)
                    .transition(.opacity)
            }
            
            
            
#endif
            
        }
        
#if os(iOS)
        
        .background {
            if viewModel.darkMode {
                Color.black.ignoresSafeArea()
            } else {
                Image("helldivers2planet").resizable().aspectRatio(contentMode: .fill).offset(CGSize(width: -400, height: 0)).blur(radius: 20.0).ignoresSafeArea()
                    .grayscale(1.0).opacity(0.6)
            }
        }
        
        
        
        .overlay(
            
            
            
            FactionImageView(factionString: planet?.faction.imageName ?? "unknown")
            
                .padding(.trailing, 20)
                .offset(x: 0, y: -45)
            , alignment: .topTrailing)
        
        
        .toolbarRole(.editor)
        
        .navigationTitle(planet?.name.uppercased() ?? "UNKNOWN")
        
        .navigationBarTitleDisplayMode(.large)
#else
        
        .toolbar {
            if #available(watchOS 10, *) {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(planet?.name.capitalized ?? "UNKNOWN").textCase(.uppercase)  .font(Font.custom("FSSinclair", size: largeFont))
                }
            }
            
        }
        
        
#endif
    }
    
    var statsList: some View {
        
        VStack(alignment: .leading) {
            if let missionsWon = planet?.statistics.missionsWon {
                StatRow(label: "Missions\(extraStatSplitter)won", value: "\(missionsWon)")
            }
            
            if let missionsLost = planet?.statistics.missionsLost {
                StatRow(label: "Missions\(extraStatSplitter)lost", value: "\(missionsLost)")
            }
            
            if let successRate = planet?.statistics.missionSuccessRate {
                StatRow(label: "Success rate", value: "\(successRate)%")
            }
            
            RoundedDivider(width: dividerWidth)
            
            if let terminidKills = planet?.statistics.terminidKills {
                StatRow(label: "Terminids\(extraStatSplitter)Killed", value: "\(terminidKills)")
            }
            
            if let automatonKills = planet?.statistics.automatonKills {
                StatRow(label: "Automatons\(extraStatSplitter)Killed", value: "\(automatonKills)")
            }
            
            if let illuminateKills = planet?.statistics.illuminateKills, showIlluminateStats {
                HStack {
                    Text(!showRedactedText ? "Illuminates\(extraStatSplitter)Killed" : "[REDACTED]\(extraStatSplitter)killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                        .foregroundStyle(showRedactedText ? .red : .white)
                        .shake(times: CGFloat(viewModel.redactedShakeTimes))
                    Spacer()
                    Text("\(illuminateKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
                
                .onAppear {
                    // redact the info if the illuminates are not enabled in the config
                    if !viewModel.showIlluminateUI {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            
                            withAnimation(.bouncy(duration: 0.3)) {
                                viewModel.redactedShakeTimes += 1
                                showRedactedText = true
                            }
                            
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            // hide illuminate
                            withAnimation(.bouncy(duration: 0.5)) {
                                showIlluminateStats = false
                            }
                        }
                    }
                    
                }
                
            }
            
            
            
            RoundedDivider(width: dividerWidth)
            
            if let bulletsFired = planet?.statistics.bulletsFired {
                StatRow(label: "Bullets\(extraStatSplitter)Fired", value: "\(bulletsFired)")
            }
            
            if let bulletsHit = planet?.statistics.bulletsHit {
                StatRow(label: "Bullets\(extraStatSplitter)Hit", value: "\(bulletsHit)")
            }
            
            if let accuracy = planet?.statistics.accuracy {
                StatRow(label: "Accuracy", value: "\(accuracy)%")
            }
            
            RoundedDivider(width: dividerWidth)
            
            if let helldiversLost = planet?.statistics.deaths {
                StatRow(label: "Helldivers\(extraStatSplitter)Lost", value: "\(helldiversLost)")
            }
            
            if let friendlyKills = planet?.statistics.friendlies {
                StatRow(label: "Friendly\(extraStatSplitter)Kills", value: "\(friendlyKills)")
            }
            
            
            
            
            
        }
        
        
    }
    
    var imageWithSectorName: some View {
        ZStack(alignment: .bottomLeading) {
            Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
            
            DarkGradientOverlay(maxHeight: 80)
            
            
            if let sector = planet?.sector {
                HStack(spacing: 6) {
                    Text(sector).foregroundStyle(planet?.factionColor ?? Color.gray)
#if os(watchOS)
                        .textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: mediumFont))
#else
                        .textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
#endif
                    
                    Text("Sector")
#if os(watchOS)
                        .textCase(.uppercase).font(Font.custom("FSSinclair", size: smallFont))
#else
                        .textCase(.uppercase).font(Font.custom("FSSinclair", size: largeFont))
#endif
                    
                    
                    
                    
                    Spacer()
                }
                .padding(5)
                .padding(.leading, 5)
                
            }
            
        }   .helldiversBorder()
            .padding(4)
            .border(planet?.factionColor ?? Color.gray, width: 2) .padding([.bottom, .horizontal])
    }
    
    var biomeDescription: some View {
        VStack(alignment: .leading, spacing: 5){
            
            Text(planet?.biome.name ?? "").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
            
            RoundedDivider(width: smallerDividerWidth)
            
            if let biomeDescript = planet?.biome.description {
                Text(biomeDescript)
                    .font(Font.custom("FSSinclair", size: smallFont))
                
            }
            
        }
    }
    
    var darkEnergyTracker: some View {
        ZStack(alignment: .leading) {
            
            Color.gray.opacity(0.16)
                .shadow(radius: 3)
            VStack(spacing: 8) {
                
                Text("Dark Energy").textCase(.uppercase)
                    .foregroundStyle(.white)
                    .font(Font.custom("FSSinclair-Bold", size: largeFont))
                    .multilineTextAlignment(.center)
                
                
                Text(darkEnergyProgress > 0 ? "\(darkEnergyProgress * 100, specifier: "%.3f")% ACCUMULATED" : "DARK ENERGY DEPLETED").textCase(.uppercase)
                    .foregroundStyle(.white)
                    .font(Font.custom("FSSinclair", size: mediumFont))
                    .multilineTextAlignment(.center)
                
                
                MiniRectangleProgressBar(value: darkEnergyProgress, primaryColor: .purple, secondaryColor: .black, height: 26)
                    .padding(.horizontal, 6)
                
            }.padding(20)
        }
        .dashedRowBackground(dashPattern: dashPattern)
        .padding(4)
        .padding(.bottom, 4)
    }
    
    var majorOrderPlanetNotice: some View
    {
        ZStack(alignment: .leading) {
            
            Color.gray.opacity(0.16)
                .shadow(radius: 3)
            
            VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 12) {
                Image("orderstar").resizable()
                    .renderingMode(.template).aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color(red: 49/255, green: 49/255, blue: 49/255))
                    .frame(width: 30, height: 30)
                    .offset(x: 0, y: -0.5)
                    .whiteCircleBackground()
                
                VStack(alignment: .leading) {
                    Text("MAJOR ORDER").textCase(.uppercase)
                        .font(Font.custom("FSSinclair", size: mediumFont))
                    Text("This planet is a target in the current Major Order.")
                        .font(Font.custom("FSSinclair", size: smallFont))
                }
                
                
                
            }
        }
            .padding(8)
            
        }
        .dashedRowBackground(dashPattern: dashPattern)
        .padding(4)
        .padding(.bottom, 4)
    }
    
    var galacticEffects: some View {
            
            VStack(alignment: .leading, spacing: 5) {
                
                Text("Effects & POIs").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
                RoundedDivider(width: smallerDividerWidth)
                
                ForEach(pointsOfInterest) { effect in
                     HStack(spacing: 12) {
                     
                                Image(effect.imageName ?? "").resizable()
                             .renderingMode(.template)
                             .aspectRatio(contentMode: .fit)
                             .foregroundStyle(Color(red: 49/255, green: 49/255, blue: 49/255))
                           
                             .frame(width: 22, height: 22)
                             .offset(x: effect.imageName == "sciencecenter" ? -2 : 0, y: 0)
                             .whiteCircleBackground(padding: 8, opacity: effect.imageName == nil ? 0.4 : 1.0)
                             .frame(width: 34, height: 34)

                            
                         VStack(alignment: .leading) {
                             Text(effect.name ?? "UNKNOWN").textCase(.uppercase)
                                 .font(Font.custom("FSSinclair", size: mediumFont))
                             Text(effect.description ?? "Research is underway to identify this mysterious signal.")
                                     .font(Font.custom("FSSinclair", size: smallFont))
                         }
                        }
                    
                    
                }
            }
            .padding(.bottom, 8)
        
    }
    
    var environmentsList: some View {
        
        VStack(alignment: .leading, spacing: 5) {
            
            Text("Environment").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
            
            RoundedDivider(width: smallerDividerWidth)
            
            if let weathers = planet?.hazards {
                ForEach(weathers, id: \.name) { weather in
                    
                    HStack(spacing: 12) {
                        Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                        
                            .frame(width: 30, height: 30)
                            .whiteCircleBackground(opacity: weather.name.lowercased() == "none" ? 0.4 : 1.0)
                        
                        VStack(alignment: .leading) {
                            Text(weather.name).textCase(.uppercase)
                                .font(Font.custom("FSSinclair", size: mediumFont))
                            if !weather.description.isEmpty {
                                Text(weather.description)
                                    .font(Font.custom("FSSinclair", size: smallFont))
                            }
                        }
                        
                        
                    }
                }
                
            }
            
            
        }.padding(.bottom, 8)
        //    .padding(.horizontal, 5)
        
        
        
    }
    
    
}

struct FactionImageView: View {
    // not using enemy type enum, because this planet may be viewed from the stats view - if its not currently in a campaign then it may be human owned, in that case the owner will be passed
    var factionString: String = "terminid"
    
    var body: some View {
        
        
        Image(factionString)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
        //  .clipShape(Circle())
        
        
    }
    
    
}

enum InfoType: String, SegmentedItem, CaseIterable {
    case warEffort = "War Effort"
    case database = "Database"
    
    var contentType: SegmentedContentType {
        switch self {
        case .warEffort:
            return .text("War Effort")
        case .database:
            return .text("Database")
        }
    }
}

struct RegionListView: View {
    let regions: [Region]
    let showOnlyTopRegion: Bool
    let factionColor: Color
    
    let horizPadding: CGFloat

    var body: some View {
        let displayedRegions = showOnlyTopRegion
            ? [regionWithMostPlayers].compactMap { $0 }
            : regions.sorted { $0.isAvailable && !$1.isAvailable }
        
        if !displayedRegions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                
                if !showOnlyTopRegion {
                    Text("REGIONS")
                        .font(Font.custom("FSSinclair-Bold", size: largeFont))
                        .foregroundStyle(.white)
                    
                }

                ForEach(displayedRegions, id: \.self.id) { (region: Region) in
                    let regionName = region.name
                    let heldProgress: Double = {
                        guard let max = region.maxHealth, let health = region.health, max > 0 else { return 0.0 }
                        let remaining = Double(health)
                        return 1.0 - (remaining / Double(max))
                    }()
                    let controlStatus: String = {
                        if !region.isAvailable {
                            return "UNDER ENEMY CONTROL"
                        } else {
                            let format = showOnlyTopRegion ? "%.1f%%" : "%.3f%% HELD"
                            return String(format: format, heldProgress * 100)
                        }
                    }()
                    let regionColor: Color = factionColor

                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text(regionName ?? "Unknown")
                                .font(Font.custom("FSSinclair-Bold", size: mediumFont))
                                .foregroundStyle(.white)
                            Spacer()
                            Divider()
                            Text(controlStatus)
                                .font(Font.custom("FSSinclair-Bold", size: smallFont))
                                .foregroundStyle(.white)
                            
                            if region.isAvailable, let regenPerSecond = region.regenPerSecond {
                                Spacer()
                                
                                Divider()
                                
                                let regenPerHour = Double(regenPerSecond) * 3600.0
                                let regenPercent = (regenPerHour / Double(region.maxHealth ?? 0)) * 100
                                
                                Text(String(format: "%.1f%% / h", -regenPercent))
                                    .foregroundStyle(regionColor).bold()
                                    .font(Font.custom("FSSinclair", size: smallFont))
                                    .padding(.top, 2)
                                    .dynamicTypeSize(.small)
                                
                            }
                            
                        }
                        
                        if region.isAvailable {
                            RectangleProgressBar(
                                value: heldProgress,
                                primaryColor: Color.cyan,
                                secondaryColor: regionColor,
                                height: 8
                            )
                            .padding(.horizontal, 6)
                            .padding(.vertical, 5)
                            .border(regionColor, width: 2)
                        }
                    }
                    
                    
                }  .multilineTextAlignment(.center)
            }
            .padding(.horizontal, horizPadding)
            
            
       
            
        }
    }

    private var regionWithMostPlayers: Region? {
    regions
        .filter { $0.isAvailable }
        .max(by: { $0.players < $1.players })
}
}

#if DEBUG
#Preview("Liberation") {
    NavigationStack {
        PlanetInfoView(planetIndex: 5)
    }
    .background(.black)
    .environment(PlanetsDataModel.preview(contexts: [.mockLiberation]))
    .environment(NavigationPather())
}

#Preview("Defense") {
    NavigationStack {
        PlanetInfoView(planetIndex: 5)
    }
    .background(.black)
    .environment(PlanetsDataModel.preview(contexts: [.mockDefense]))
    .environment(NavigationPather())
}

#Preview("Almost Liberated") {
    NavigationStack {
        PlanetInfoView(planetIndex: 12)
    }
    .background(.black)
    .environment(PlanetsDataModel.preview(contexts: [.mockAlmostLiberated]))
    .environment(NavigationPather())
}
#endif
