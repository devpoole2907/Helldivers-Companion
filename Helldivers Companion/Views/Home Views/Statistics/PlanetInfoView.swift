//
//  PlanetInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct PlanetInfoView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var navPath: NavigationPather
    
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
        return resources.first { $0.id32 == 194773219 }
    }
    
    var darkEnergyProgress: Double {
        guard let resource = darkEnergyResource else { return 0 }
        return Double(resource.currentValue) / Double(resource.maxValue)
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planet)
        
    }
    
    // to determine if it is currently in a campaign
    private var campaign: Bool {
        viewModel.updatedCampaigns.contains(where: { $0.planet.name == planet?.name })
    }
    
    // this is stupid and repetitive
    private var campaignType: Int? {
            guard let planet = planet else { return nil }
            return viewModel.updatedCampaigns.first(where: { $0.planet.index == planet.index })?.type
        }
    
    private var planet: UpdatedPlanet? {
        viewModel.updatedPlanets.first(where: { $0.index == planetIndex })
    }
    
    private var defenseCampaign: UpdatedCampaign? {
        guard let planet = planet else { return nil }
        return viewModel.updatedDefenseCampaigns.first(where: { $0.planet.index == planet.index })
    }
    
    private var eventExpirationTime: Date? {
        defenseCampaign?.planet.event?.expireTimeDate
    }
    
    private var eventInvasionLevel: Int64? {
        defenseCampaign?.planet.event?.invasionLevel
    }
    
    private var eventHealth: Int64? {
        defenseCampaign?.planet.event?.health
    }
    
    private var eventMaxHealth: Int64? {
        defenseCampaign?.planet.event?.maxHealth
    }
    
    private var activeSpaceStation: SpaceStation? {
        return viewModel.spaceStations.first { spaceStation in
            spaceStation.planet.index == planet?.index
        }
    }
    
    // any regions e.g cities on super earth
    var matchingRegions: [PlanetRegion] {
        return viewModel.status?.planetRegions?.filter { $0.planetIndex == planetIndex } ?? []
    }
    
    private var activeSpaceStationDetails: SpaceStationDetails? {
        guard let activeSpaceStation = activeSpaceStation else { return nil }
        return viewModel.firstSpaceStationDetails?.id32 == activeSpaceStation.id32 ? viewModel.firstSpaceStationDetails : nil
    }
    
    private var spaceStationExpirationTime: Date? {
        return activeSpaceStation?.electionEndDate
    }
    private var liberationType: LiberationType {
        
        (defenseCampaign != nil) ? .defense : .liberation
        
    }
    
    private var liberationPercentage: Double? {
        
        // super broken way of using fleet stremgth progress but whatever we got 3 weeks off soon to work on this shit
        
        if defenseCampaign?.planet.event?.eventType == 3, let _ = viewModel.fleetStrengthResource {
            return (1.0 - viewModel.fleetStrengthProgress) * 100
        }
        
        return defenseCampaign?.planet.event?.percentage ?? planet?.percentage
    }
    
    private var liberationTimeRemaining: Date? {
        
        guard let planet = planet else { return nil }
        
        let currentLiberation = planet.event?.percentage ?? planet.percentage
        
        guard let liberationRate = viewModel.currentLiberationRate(for: planet.name), liberationRate > 0 else {
            return nil
        }
        
        let remainingPercentage = 100.0 - currentLiberation
        let timeRemaining = (remainingPercentage / liberationRate) * 3600
        
        let liberationDate = Date().addingTimeInterval(timeRemaining)
        
        return liberationDate
        
    }
    
    private var pointsOfInterest: [GalacticEffect] {
        if let effects = planet?.galacticEffects {
            return effects} else {
                return []
            }
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
            
        }){
            HStack(spacing: 6){
                Image(systemName: "mappin.and.ellipse")
                    .bold()
                    .font(.callout)
                    .padding(.bottom, 2)
                Text("View on Map").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                    .font(Font.custom("FSSinclair", size: 16))
                
            }
            
            
        }.padding(.horizontal)
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
                if let planet = planet, viewModel.updatedTaskPlanets.contains(planet) {
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
                        regionInfo: viewModel.regionInfo,
                        showOnlyTopRegion: false, horizPadding: horizPadding
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
                        HistoryChart(liberationType: liberationType, planetData: planetData, factionColor: viewModel.getColorForPlanet(planet: planet)).environmentObject(viewModel)
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
                            CampaignPlanetStatsView(liberation: liberationPercentage ?? 0.0, liberationType: liberationType, planetName: planet?.name, planet: planet, factionColor: viewModel.getColorForPlanet(planet: planet), factionImage: viewModel.getImageNameForPlanet(planet), playerCount: planet?.statistics.playerCount, eventExpirationTime: eventExpirationTime, invasionLevel: eventInvasionLevel, maxHealth: eventMaxHealth, health: eventHealth, campaignType: campaignType)
                                .shadow(radius: 5.0)
                        }
                        
                    } else {
                        
                        if let _ = planet?.biome.name {
                            biomeDescription
                            
                        }
                        
                        // display any galactic effects in the planet
                        
                        if !pointsOfInterest.isEmpty {
                            
                            galacticEffects
                            
                        }
                                       
                                   
                        
                        if let environmentals = planet?.hazards, !environmentals.isEmpty {
                            environmentsList
                            
                        }
                        
                        if let _ = planet?.statistics {
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
            
            
            
            FactionImageView(faction: viewModel.getImageNameForPlanet(planet))
            
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
                HStack {
                    Text("Missions\(extraStatSplitter)won").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsWon)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let missionsLost = planet?.statistics.missionsLost {
                HStack {
                    Text("Missions\(extraStatSplitter)lost").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(missionsLost)").font(Font.custom("FSSinclair", size: smallFont))
                        .multilineTextAlignment(.trailing)
                }
            }
            
            if let successRate = planet?.statistics.missionSuccessRate {
                HStack {
                    Text("Success rate").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(successRate)%").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)
                .padding(.bottom, 4)
            
            if let terminidKills = planet?.statistics.terminidKills {
                HStack {
                    Text("Terminids\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(terminidKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let automatonKills = planet?.statistics.automatonKills {
                HStack {
                    Text("Automatons\(extraStatSplitter)Killed").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(automatonKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
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
            
            
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let bulletsFired = planet?.statistics.bulletsFired {
                HStack {
                    Text("Bullets\(extraStatSplitter)Fired").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsFired)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let bulletsHit = planet?.statistics.bulletsHit {
                HStack {
                    Text("Bullets\(extraStatSplitter)Hit").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(bulletsHit)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let accuracy = planet?.statistics.accuracy {
                HStack {
                    Text("Accuracy").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(accuracy)%").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            RoundedRectangle(cornerRadius: 25).frame(width: dividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let helldiversLost = planet?.statistics.deaths {
                HStack {
                    Text("Helldivers\(extraStatSplitter)Lost").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(helldiversLost)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            if let friendlyKills = planet?.statistics.friendlies {
                HStack {
                    Text("Friendly\(extraStatSplitter)Kills").textCase(.uppercase).font(Font.custom("FSSinclair", size: mediumFont))
                    Spacer()
                    Text("\(friendlyKills)").font(Font.custom("FSSinclair", size: smallFont))     .multilineTextAlignment(.trailing)
                }
            }
            
            
            
            
            
        }
        
        
    }
    
    var imageWithSectorName: some View {
        ZStack(alignment: .bottomLeading) {
            Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.multiply)
            
            .frame(maxHeight: 80)
            
            
            if let sector = planet?.sector {
                HStack(spacing: 6) {
                    Text(sector).foregroundStyle(viewModel.getColorForPlanet(planet: planet))
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
            
        }   .border(Color.white)
            .padding(4)
            .border(Color.gray)
        
            .padding(4)
            .border(viewModel.getColorForPlanet(planet: planet), width: 2) .padding([.bottom, .horizontal])
    }
    
    var biomeDescription: some View {
        VStack(alignment: .leading, spacing: 5){
            
            Text(planet?.biome.name ?? "").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
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
        }.background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
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
                    .padding(4)
                    .background{
                        Circle().foregroundStyle(Color.white)
                            .shadow(radius: 3.0)
                    }
                
                VStack(alignment: .leading) {
                    Text("MAJOR ORDER").textCase(.uppercase)
                        .font(Font.custom("FSSinclair", size: mediumFont))
                    Text("This planet is a target in the current Major Order.")
                        .font(Font.custom("FSSinclair", size: smallFont))
                }
                
                
                
            }
        }
            .padding(8)
            
        } .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
        .padding(4)
        .padding(.bottom, 4)
    }
    
    var galacticEffects: some View {
            
            VStack(alignment: .leading, spacing: 5) {
                
                Text("Effects & POIs").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: largeFont))
                RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
                
                ForEach(pointsOfInterest) { effect in
                     HStack(spacing: 12) {
                     
                                Image(effect.imageName ?? "").resizable()
                             .renderingMode(.template)
                             .aspectRatio(contentMode: .fit)
                             .foregroundStyle(Color(red: 49/255, green: 49/255, blue: 49/255))
                           
                             .frame(width: 22, height: 22)
                             .offset(x: effect.imageName == "sciencecenter" ? -2 : 0, y: 0)
                             .padding(8)
                             .background(
                                     Circle()
                                         .foregroundStyle(.white)
                                         .shadow(radius: 3)
                                         .opacity(effect.imageName == nil ? 0.4 : 1.0)
                                 )
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
            
            RoundedRectangle(cornerRadius: 25).frame(width: smallerDividerWidth, height: 2)         .padding(.bottom, 4)
            
            if let weathers = planet?.hazards {
                ForEach(weathers, id: \.name) { weather in
                    
                    HStack(spacing: 12) {
                        Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                        
                            .frame(width: 30, height: 30)
                            .padding(4)
                            .background{
                                Circle().foregroundStyle(Color.white)
                                    .shadow(radius: 3.0)
                                    .opacity(weather.name.lowercased() == "none" ? 0.4 : 1.0)
                            }
                        
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
    var faction: String = "terminid"
    
    var body: some View {
        
        
        Image(faction)
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
    let regions: [PlanetRegion]
    let regionInfo: [RegionInfoEntry]
    let showOnlyTopRegion: Bool
    
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

                ForEach(displayedRegions, id: \.regionIndex) { region in
                    let regionName = regionInfo.first(where: { $0.id == String(region.settingsHash ?? -1) })?.name ?? "Region \(region.regionIndex)"
                    let heldProgress: Double = {
                        guard let max = region.maxHealth, max > 0 else { return 0.0 }
                        let remaining = Double(region.health)
                        return 1.0 - (remaining / Double(max))
                    }()
                    let controlStatus: String = {
                        if !region.isAvailable && region.owner != 1 {
                            return "UNDER ENEMY CONTROL"
                        } else {
                            let format = showOnlyTopRegion ? "%.1f%%" : "%.3f%% HELD"
                            return String(format: format, heldProgress * 100)
                        }
                    }()
                    let regionColor: Color = region.factionColor

                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text(regionName)
                                .font(Font.custom("FSSinclair-Bold", size: mediumFont))
                                .foregroundStyle(.white)
                            Spacer()
                            Divider()
                            Text(controlStatus)
                                .font(Font.custom("FSSinclair-Bold", size: smallFont))
                                .foregroundStyle(.white)
                            
                            if region.isAvailable {
                                Spacer()
                                
                                Divider()
                                
                                let regenPerHour = Double(region.regerPerSecond) * 3600.0
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
                    
                    .padding()
                    
                    
                }  .multilineTextAlignment(.center)
            }
            .padding(.horizontal, horizPadding)
            
            
       
            
        }
    }

    private var regionWithMostPlayers: PlanetRegion? {
    regions
        .filter { $0.isAvailable }
        .max(by: { $0.players < $1.players })
}
}
