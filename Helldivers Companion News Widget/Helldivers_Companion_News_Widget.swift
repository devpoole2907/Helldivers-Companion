//
//  Helldivers_Companion_News_Widget.swift
//  Helldivers Companion News Widget
//
//  Created by James Poole on 22/03/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    
    var newsModel = NewsFeedModel()
    
    func placeholder(in context: Context) -> NewsItemEntry {
        NewsItemEntry(date: Date(), title: "Automaton Counterattack", description: "Intercepted messages indicate bot plans for a significant push. Increased resistance on Automaton planets is anticipated.")
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsItemEntry) -> ()) {
        let entry = NewsItemEntry(date: Date(), title: "Automaton Counterattack", description: "Intercepted messages indicate bot plans for a significant push. Increased resistance on Automaton planets is anticipated.")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [NewsItemEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        newsModel.fetchNewsFeed { news in
            
            print("fetching news")
            
            if let newsEntry = news.first, let message = newsEntry.message {
                
                
                    
                    let entry = NewsItemEntry(date: Date(), title: newsEntry.title ?? "BREAKING NEWS", description: message)
                
                    
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
}

struct Helldivers_Companion_News_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            
            Color(.systemBlue).opacity(0.6)
            
            ContainerRelativeShape()
                .inset(by: 4)
                .fill(Color.black)
            NewsItemView(newsTitle: entry.title, newsMessage: entry.description.replacingOccurrences(of: "\n", with: ""), isWidget: true).padding(.horizontal)
                .padding(.vertical, 5)
              
            
            
            
        }
        
    }
}

struct Helldivers_Companion_News_Widget: Widget {
    let kind: String = "Helldivers_Companion_News_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in

                Helldivers_Companion_News_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            
                   
                    
        }
        .configurationDisplayName("News")
        .description("Displays the latest news entry for Helldivers 2.")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemLarge) {
    Helldivers_Companion_News_Widget()
} timeline: {
    NewsItemEntry(date: Date(), title: "Automaton Counterattack", description: "Intercepted messages indicate bot plans for a significant push. Increased resistance on Automaton planets is anticipated.")
}
