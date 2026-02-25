//
//  Helldivers_Companion_Galaxy_Map_Widget.swift
//  Helldivers Companion Galaxy Map Widget
//
//  Created by James Poole on 12/04/2024.
//

import WidgetKit
import SwiftUI

struct GalaxyMapProvider: TimelineProvider {
    
    let apiService = WarAPIService()
    
    
    func placeholder(in context: Context) -> GalaxyMapEntry {
        GalaxyMapEntry(date: Date(), campaigns: [], defenseCampaigns: [], planets: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GalaxyMapEntry) -> Void) {
        let entry = GalaxyMapEntry(date: Date(), campaigns: [], defenseCampaigns: [], planets: [])
        completion(entry)
    }
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        
        let campaignsUrlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentCampaigns.json"
        
        let planetsUrlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentPlanets.json"
        
        Task {
            var entries: [GalaxyMapEntry] = []
            
            guard let config = await apiService.fetchConfig() else {
                print("config failed to load")
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }
            
            let (planets, _, _) = await apiService.fetchPlanets(url: planetsUrlString, apiAddress: config.apiAddress, language: nil)
            let (campaigns, defenseCampaigns) = await apiService.fetchCampaigns(url: campaignsUrlString, apiAddress: config.apiAddress, language: nil)
            
            let entry = GalaxyMapEntry(date: Date(), campaigns: campaigns, defenseCampaigns: defenseCampaigns, planets: planets)
            entries.append(entry)
            
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            
            
            
        }
        
    }
}

struct GalaxyMapEntry: TimelineEntry {
    let date: Date
    var campaigns: [UpdatedCampaign]
    var defenseCampaigns: [UpdatedCampaign]
    var planets: [UpdatedPlanet]
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
                GalaxyMapView(selectedPlanet: .constant(nil), showSupplyLines: .constant(true), showAllPlanets: widgetRenderingMode == .accented ? .constant(false) : .constant(true), showPlanetNames: .constant(false), currentZoomLevel: .constant(1), planets: entry.planets, campaigns: entry.campaigns, defenseCampaigns: entry.defenseCampaigns, isWidget: true).environmentObject(PlanetsDataModel())
                    .padding()
                    .frame(width: 300, height: 300)
                
                Text("Last Updated: \(Date().formatted(date: .omitted, time: .shortened))").textCase(.uppercase)
                
                    .font(Font.custom("FSSinclair", size: 16)).bold()
                    .foregroundStyle(.yellow)
                
            }.widgetAccentable(true)
            
        }
        
    }
    
}
