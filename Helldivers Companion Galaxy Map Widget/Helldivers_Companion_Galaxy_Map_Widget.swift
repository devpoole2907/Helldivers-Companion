//
//  Helldivers_Companion_Galaxy_Map_Widget.swift
//  Helldivers Companion Galaxy Map Widget
//
//  Created by James Poole on 12/04/2024.
//

import WidgetKit
import SwiftUI

struct GalaxyMapProvider: TimelineProvider {

    private let dataProvider = WidgetDataProvider()

    func placeholder(in context: Context) -> GalaxyMapEntry {
        GalaxyMapEntry(date: Date(), campaigns: [], defenseCampaigns: [], planets: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (GalaxyMapEntry) -> Void) {
        let entry = GalaxyMapEntry(date: Date(), campaigns: [], defenseCampaigns: [], planets: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            var entries: [GalaxyMapEntry] = []

            guard let data = await dataProvider.fetchMapData() else {
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }

            entries.append(GalaxyMapEntry(date: Date(), campaigns: data.campaigns, defenseCampaigns: data.defenseCampaigns, planets: data.planets, spaceStations: data.spaceStations, taskPlanets: data.taskPlanets))
            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }
}

struct GalaxyMapEntry: TimelineEntry {
    let date: Date
    var campaigns: [UpdatedCampaign]
    var defenseCampaigns: [UpdatedCampaign]
    var planets: [UpdatedPlanet]
    var spaceStations: [SpaceStation] = []
    var taskPlanets: [UpdatedPlanet] = []
}

struct GalaxyMapWidgetEntryView: View {
    var entry: GalaxyMapProvider.Entry
    
    var body: some View {
        GalaxyMapWidgetView(entry: entry)
    }
}

struct Helldivers_Companion_Galaxy_Map_Widget: Widget {
    let kind: String = "Helldivers_Companion_Galaxy_Map_Widget"
    
    let supportedFamilies: [WidgetFamily] = [.systemLarge]
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GalaxyMapProvider()) { entry in
            if #available(iOS 17.0, *) {
                GalaxyMapWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                GalaxyMapWidgetEntryView(entry: entry)
            }
        }
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Galaxy Map")
        .description("Displays the galaxy map.")
        .contentMarginsDisabled()
    }
}

struct GalaxyMapWidgetView: View {
    
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var entry: GalaxyMapEntry
    
    var body: some View {
        
        ZStack {
            
            if widgetRenderingMode != .accented {
                
                Color.cyan
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
                
            }
            
            VStack(spacing: 0) {
                GalaxyMapView(selectedPlanet: .constant(nil), showSupplyLines: .constant(true), showAllPlanets: widgetRenderingMode == .accented ? .constant(false) : .constant(true), showPlanetNames: .constant(false), currentZoomLevel: .constant(1), planets: entry.planets, campaigns: entry.campaigns, defenseCampaigns: entry.defenseCampaigns, widgetSpaceStations: entry.spaceStations, widgetTaskPlanets: entry.taskPlanets, isWidget: true)
                    // PlanetsDataModel.shared is a structurally-required environment value for GalaxyMapView;
                    // all actual widget data flows through entry fields — the viewModel is never consulted for fetching.
                    .environment(PlanetsDataModel.shared)
                    .padding()
                    .frame(width: 300, height: 300)
                
                Text("Last Updated: \(Date().formatted(date: .omitted, time: .shortened))").textCase(.uppercase)
                
                    .font(Font.custom("FSSinclair", size: 16)).bold()
                    .foregroundStyle(.yellow)
                
            }.widgetAccentable(true)
            
        }
        
    }
    
}
