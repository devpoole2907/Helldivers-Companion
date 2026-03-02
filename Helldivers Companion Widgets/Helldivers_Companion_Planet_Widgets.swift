//
//  Helldivers_Companion_Widgets.swift
//  Helldivers Companion Widgets
//
//  Created by James Poole on 18/03/2024.
//

import WidgetKit
import SwiftUI

@available(watchOS 9.0, *)
struct PlanetStatusProvider: TimelineProvider {
    typealias Entry = SimplePlanetStatus
    
    private let dataProvider = WidgetDataProvider()

    func placeholder(in context: Context) -> SimplePlanetStatus {
        SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, campaignType: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimplePlanetStatus) -> Void) {
        
        let entry = SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, campaignType: 0)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimplePlanetStatus>) -> Void) {
        Task {
            var entries: [SimplePlanetStatus] = []

            guard let data = await dataProvider.fetchPlanetData() else {
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }

            if let highestPlanetCampaign = data.campaigns.max(by: { $0.planet.statistics.playerCount < $1.planet.statistics.playerCount }) {
                let highestPlanet = highestPlanetCampaign.planet
                let campaignType = highestPlanetCampaign.type
                let spaceStationExpirationTime = data.spaceStations.first(where: { $0.planet.index == highestPlanet.index })?.electionEndDate

                if let defenseEvent = data.defenseCampaigns.first(where: { $0.planet.index == highestPlanet.index }) {
                    var liberationPercentage = defenseEvent.planet.event?.percentage ?? highestPlanet.percentage
                    if defenseEvent.planet.event?.eventType == 3 {
                        liberationPercentage = (1.0 - data.fleetStrengthProgress) * 100
                    }
                    let entry = SimplePlanetStatus(
                        date: Date(), planetName: highestPlanet.name,
                        liberation: liberationPercentage, playerCount: highestPlanet.statistics.playerCount,
                        planet: highestPlanet, liberationType: .defense,
                        eventExpirationTime: highestPlanet.event?.expireTimeDate,
                        invasionLevel: highestPlanet.event?.invasionLevel,
                        eventHealth: highestPlanet.event?.health,
                        eventMaxHealth: highestPlanet.event?.maxHealth,
                        spaceStationExpirationTime: spaceStationExpirationTime,
                        campaignType: campaignType)
                    entries.append(entry)
                } else {
                    // we dont need to access the view models faction image function's additional conditions here, because the planet is definitely not defending and is definitely a campaign, so we can just use it in the view directly as it will fall through to the check we need anyway
                    let entry = SimplePlanetStatus(
                        date: Date(), planetName: highestPlanet.name,
                        liberation: highestPlanet.percentage, playerCount: highestPlanet.statistics.playerCount,
                        planet: highestPlanet, spaceStationExpirationTime: spaceStationExpirationTime,
                        campaignType: campaignType)
                    entries.append(entry)
                }

                print("appending entry!")
            }

            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }
    
}


struct SimplePlanetStatus: TimelineEntry {
    var date: Date
    var planetName: String
    var liberation: Double
    var playerCount: Int64
    var planet: UpdatedPlanet?
    var liberationType: LiberationType = .liberation
    var eventExpirationTime: Date?
    var invasionLevel: Int64?
    var eventHealth: Int64?
    var eventMaxHealth: Int64?
    var spaceStationExpirationTime: Date?
    var campaignType: Int
}

@available(watchOS 9.0, *)
struct Helldivers_Companion_WidgetsEntryView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var entry: PlanetStatusProvider.Entry
    
    var body: some View {
        
        switch widgetFamily {
        case .accessoryRectangular:
            RectangularPlanetWidgetView(entry: entry)
        case .accessoryInline:
            InlinePlanetWidgetView(entry: entry)
#if os(watchOS)
        case .accessoryCorner:
            CornerPlanetWidgetView(entry: entry)
                .widgetAccentable()
#endif
        default:
            
            
#if os(iOS)
            
            
            ZStack {
                
                if widgetRenderingMode != .accented {
                    (entry.planet?.factionColor ?? Color.gray).opacity(0.6)
                    
                    ContainerRelativeShape()
                        .inset(by: 4)
                        .fill(Color.black)
                    
                }
                
                PlanetView(
                    planetName: entry.planetName,
                    liberation: entry.liberation,
                    playerCount: entry.playerCount,
                    planet: entry.planet,
                    showHistory: false,
                    showImage: widgetFamily != .systemMedium,
                    showExtraStats: widgetFamily != .systemMedium,
                    liberationType: entry.liberationType,
                    isWidget: true,
                    eventExpirationTime: entry.eventExpirationTime,
                    spaceStationExpirationTime: entry.spaceStationExpirationTime,
                    eventInvasionLevel: entry.invasionLevel,
                    eventHealth: entry.eventHealth,
                    eventMaxHealth: entry.eventMaxHealth,
                    campaignType: entry.campaignType
                // PlanetsDataModel.shared is a structurally-required environment value for PlanetView;
                // all actual widget data flows through entry fields — the viewModel is never consulted for fetching.
                ).environment(PlanetsDataModel.shared)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
            }                 .widgetAccentable(true)
#else
            Text("You shouldnt see this")
#endif
        }
        
        
        
    }
}
@available(watchOS 9.0, *)
struct RectangularPlanetWidgetView: View {
    
    var entry: PlanetStatusProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 3) {
                if entry.campaignType != 3 {
                    Image(entry.planet?.faction.imageName ?? "unknown").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                        .padding(.bottom, 2)
                }
                Text(entry.planetName) .font(Font.custom("FSSinclair", size: 16)).bold()
                
                
                Image(systemName: entry.liberationType == .defense ? "shield.lefthalf.filled" : "target")
                    .font(.footnote)
                    .padding(.bottom, 1)
                
                
            }
            RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
            VStack(alignment: .leading, spacing: -3){
                HStack(spacing: 3) {
                    Image("diver").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                        .padding(.bottom, 2)
                    Text("\(entry.playerCount)") .font(Font.custom("FSSinclair", size: 16))
                    Spacer()
                }.padding(.leading, 5)
                HStack(spacing: 3) {
                    if entry.campaignType != 3 {
                    Image(systemName: "chart.xyaxis.line").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                        .padding(.bottom, 2)
                 
                        Text(String(format: entry.eventExpirationTime != nil ? "%.0f%%" : "%.4f%%", entry.liberation))
                            .font(Font.custom("FSSinclair", size: 16))
                        Spacer()
                    }
                    if let expireTime = entry.eventExpirationTime {
                        Text(expireTime, style: .timer)
                            .font(Font.custom("FSSinclair", size: 12))
                    }
                    
                }.padding(.leading, 5)
            }.padding(.top, 2)
            
        }.widgetAccentable()
        
            .padding(.leading, 5)
            .padding(.vertical, 2)
        // background breaks the watch version
#if os(iOS)
            .background(in: RoundedRectangle(cornerRadius: 5.0))
#endif
    }
}
#if os(watchOS)
@available(watchOS 9.0, *)
struct CornerPlanetWidgetView: View {
    var entry: PlanetStatusProvider.Entry
    var body: some View {
        
        if #available(iOS 17.0, *), #available(watchOS 10.0, *) {
            
            Text(entry.planetName)
                .font(.footnote)
                .scaledToFit()
                .minimumScaleFactor(0.2)
                .widgetCurvesContent()
                .widgetLabel {
                    ProgressView(value: entry.liberation, total: 100)
                        .tint(.yellow)
                }
        } else {
            Text(entry.planetName)
                .font(.footnote)
                .scaledToFit()
                .minimumScaleFactor(0.2)
            
                .widgetLabel {
                    ProgressView(value: entry.liberation, total: 100)
                        .tint(.yellow)
                }
        }
    }
}
#endif
@available(watchOS 9.0, *)
struct InlinePlanetWidgetView: View {
    
    var entry: PlanetStatusProvider.Entry
    
    var body: some View {
        HStack(spacing: 3) {
            Image(entry.planet?.faction.imageName ?? "terminid").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                .padding(.bottom, 2)
            Text("\(entry.planetName)") .font(Font.custom("FSSinclair", size: 16))
            Image(systemName: entry.liberationType == .defense ? "shield.lefthalf.filled" : "target")
                .font(.footnote)
            Text("\(String(format: "%.2f%%", entry.liberation))") .font(Font.custom("FSSinclair", size: 16))
        }
        
    }
}
@available(watchOS 9.0, *)
struct Helldivers_Companion_Planet_Widgets: Widget {
    let kind: String = "Helldivers_Companion_Widgets"
    
#if os(watchOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .accessoryInline]
#elseif os(iOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .accessoryInline, .systemMedium, .systemLarge]
#endif
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlanetStatusProvider()) { entry in
            
            if #available(iOS 17.0, *), #available(watchOS 10, *) { 
                Helldivers_Companion_WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                // for deeplinking to info of planet view
                    .widgetURL(URL(string: "helldiverscompanion://\(entry.planetName)"))
            } else {
                Helldivers_Companion_WidgetsEntryView(entry: entry)
            }
            
        }
        .configurationDisplayName("Player Count")
        .description("Shows the planet with the current highest player count.")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}
