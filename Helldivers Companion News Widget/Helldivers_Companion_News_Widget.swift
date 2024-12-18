//
//  Helldivers_Companion_News_Widget.swift
//  Helldivers Companion News Widget
//
//  Created by James Poole on 22/03/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    @MainActor var planetsModel = PlanetsDataModel()
    
    @MainActor var newsModel = NewsFeedModel()
    
    func placeholder(in context: Context) -> NewsItemEntry {
        NewsItemEntry(date: Date(), title: "Automaton Counterattack", description: "Intercepted messages indicate bot plans for a significant push. Increased resistance on Automaton planets is anticipated.", published: 4444974)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NewsItemEntry) -> ()) {
        let entry = NewsItemEntry(date: Date(), title: "Automaton Counterattack", description: "Intercepted messages indicate bot plans for a significant push. Increased resistance on Automaton planets is anticipated.", published: 4444974)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        
        Task {
            var entries: [NewsItemEntry] = []
            
            guard let config = await planetsModel.fetchConfig() else {
                print("config failed to load")
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }
            
            let news = await newsModel.fetchNewsFeed(config: config, false)
            
            if let newsEntry = news.first, let message = newsEntry.message {
                
                
                
                let entry = NewsItemEntry(date: Date(), title: newsEntry.title ?? "BREAKING NEWS", description: message, published: newsEntry.published ?? 0, configData: config)
                
                
                entries.append(entry)
                
            }
            
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            
            
            
        }
        
        
        
        
        
        
        
    }
}

struct NewsItemEntry: TimelineEntry {
    let date: Date
    let title: String?
    let description: String
    let published: UInt32
    var configData: RemoteConfigDetails? = nil
}

struct Helldivers_Companion_News_WidgetEntryView : View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            
            if widgetRenderingMode != .accented {
                Color(.systemBlue).opacity(0.6)
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
            }
            NewsItemView(newsTitle: entry.title, newsMessage: entry.description.replacingOccurrences(of: "\n", with: ""), published: entry.published, configData: entry.configData, isWidget: true).padding(.horizontal)
                .padding(.vertical, 5)
            
            
            
            
        }
        
    }
}

struct Helldivers_Companion_News_Widget: Widget {
    let kind: String = "Helldivers_Companion_News_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            
            if #available(iOSApplicationExtension 17.0, *) {
                Helldivers_Companion_News_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .widgetAccentable(true)
                // for deeplinking to news view
                    .widgetURL(URL(string: "helldiverscompanion://news"))
            } else {
                Helldivers_Companion_News_WidgetEntryView(entry: entry)
                
                // for deeplinking to news view
                    .widgetURL(URL(string: "helldiverscompanion://news"))
            }
            
        }
        .configurationDisplayName("News")
        .description("Displays the latest news entry for Helldivers 2.")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabled()
    }
}
@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    Helldivers_Companion_News_Widget()
} timeline: {
    NewsItemEntry(date: Date(), title: "Automaton Counterattack", description: "Intercepted messages indicate bot plans for a significant push. Increased resistance on Automaton planets is anticipated.", published: 4444974)
}
