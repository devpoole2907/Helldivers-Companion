//
//  War_Monitor_Total_Player_Count_Widget.swift
//  War Monitor Total Player Count Widget
//
//  Created by James Poole on 20/04/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    typealias Entry = PlayerCountEntry
    
    @MainActor var planetsModel = PlanetsDataModel()
    
    func placeholder(in context: Context) -> PlayerCountEntry {
        PlayerCountEntry(date: Date(), playerCount: 247643)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PlayerCountEntry) -> ()) {
        let entry =  PlayerCountEntry(date: Date(), playerCount: 247643)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        
        // fetches from github instead to save on api call
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentPlanets.json"
        
        Task {
            var entries: [PlayerCountEntry] = []
            
            guard let config = await planetsModel.fetchConfig() else {
                print("config failed to load")
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }
            
            let planetResults = await planetsModel.fetchPlanets(using: urlString, for: config)
            let (planets, _, _) = planetResults
            
            let playerCount = planets.reduce(0) { $0 + $1.statistics.playerCount }
            
            entries.append(PlayerCountEntry(date: Date(), playerCount: playerCount))
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            
        }
        
        
    }
}

struct PlayerCountEntry: TimelineEntry {
    let date: Date
    let playerCount: Int64
}

struct War_Monitor_Total_Player_Count_WidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            
            Text("PLAYER COUNT") .font(Font.custom("FSSinclair", size: 16)).bold()
            
            RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
            VStack (alignment: .leading, spacing: -3){
                HStack(spacing: 3) {
                    Image("diver").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                        .padding(.bottom, 2)
                    Text("\(entry.playerCount)") .font(Font.custom("FSSinclair", size: 16))
                    Spacer()
                }.padding(.leading, 5)
            }.padding(.top, 2)
            
        }.widgetAccentable()
        
            .padding(.leading, 5)
            .padding(.vertical, 2)
        //background breaks the watch version
#if os(iOS)
            .background(in: RoundedRectangle(cornerRadius: 5.0))
#endif
    }
}
#if os(iOS)
struct War_Monitor_Total_Player_Count_Widget: Widget {
    let kind: String = "War_Monitor_Total_Player_Count_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                War_Monitor_Total_Player_Count_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                War_Monitor_Total_Player_Count_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies([.accessoryRectangular])
        .configurationDisplayName("Total Player Count")
        .description("Displays the total player count.")
    }
}

#endif
