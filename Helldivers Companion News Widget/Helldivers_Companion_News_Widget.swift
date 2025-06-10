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

            print("[Widget] Fetching config...")
            guard let config = await planetsModel.fetchConfig() else {
                print("[Widget] Failed to fetch config.")
                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }
            print("[Widget] Config fetched successfully.")

            print("[Widget] Fetching news...")
            let news = await newsModel.fetchNewsFeed(config: config, true)
            print("[Widget] Fetched \(news.count) news items.")

            let warTime = await planetsModel.fetchWarTime()
            if warTime != nil {
                print("[Widget] War time fetched: \(warTime!)")
            } else {
                print("[Widget] War time is nil.")
            }

            // pick the first news item that actually contains a non-empty message
            if let newsEntry = news.first(where: { ($0.message?.isEmpty == false) }) {
                let entry = NewsItemEntry(
                    date: Date(),
                    title: newsEntry.title ?? "BREAKING NEWS",
                    description: newsEntry.message ?? "Check the app for more details.",
                    published: newsEntry.published ?? 0,
                    configData: config,
                    warTime: warTime
                )
                entries.append(entry)
            } else {
                print("[Widget] No news items contained a message.")
            }

            if entries.isEmpty {
                print("[Widget] No entries created, adding fallback entry.")
                let fallback = NewsItemEntry(
                    date: Date(),
                    title: "No News",
                    description: "Check back later.",
                    published: 0,
                    configData: config,
                    warTime: warTime
                )
                entries.append(fallback)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            print("[Widget] Timeline created with \(entries.count) entry(ies).")
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
    var warTime: Int64?
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
            NewsItemView(newsTitle: entry.title, newsMessage: entry.description.replacingOccurrences(of: "\n", with: ""), published: entry.published, configData: entry.configData, isWidget: true, warTime: entry.warTime).padding(.horizontal)
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
