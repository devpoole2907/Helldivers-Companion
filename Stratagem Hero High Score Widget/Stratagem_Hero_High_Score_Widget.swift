//
//  Stratagem_Hero_High_Score_Widget.swift
//  Stratagem Hero High Score Widget
//
//  Created by James Poole on 13/04/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HighScoreEntry {
        HighScoreEntry(date: Date(), highScore: 247331)
    }

    func getSnapshot(in context: Context, completion: @escaping (HighScoreEntry) -> ()) {
        let entry = HighScoreEntry(date: Date(), highScore: 247331)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [HighScoreEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = HighScoreEntry(date: entryDate, highScore: getHighScore())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    
    private func getHighScore() -> Int {
        let defaults = UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion")
        return defaults?.integer(forKey: "highScore") ?? 0
    }
    
}

struct HighScoreEntry: TimelineEntry {
    let date: Date
    let highScore: Int
}

struct Stratagem_Hero_High_Score_WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        
        switch widgetFamily {
            
        case .accessoryRectangular:
            
            HighScoreRectangularView(entry: entry)
            #if os(iOS)
        case .systemSmall:
            
            StratagemHeroHighScoreSmallWidgetView(entry: entry)
            #endif
        case .accessoryInline:
            
            Text("\(entry.highScore)")
            
        default:
            
            Text("You shouldn't see this! This is an error.")
            
            
            
        }
    }
}

struct StratagemHeroHighScoreSmallWidgetView: View {
    
    var entry: Provider.Entry
    
    var body: some View {
        
        
        ZStack {
            
            Color.blue
            
            
            ContainerRelativeShape()
                .inset(by: 4)
                .fill(Color.black)
            
            VStack(spacing: 4) {
                
                Text("STRATAGEM HERO").foregroundStyle(.yellow).bold()
                    .font(Font.custom("FSSinclair", size: 16))
                RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
                    .foregroundStyle(.gray)
                
                Text("High Score".uppercased()).foregroundStyle(.white)
                    .font(Font.custom("FSSinclair", size: 16))
                    .padding(.top, 10)
                
                Text("\(entry.highScore)").foregroundStyle(.yellow)
                    .font(Font.custom("FSSinclair", size: 26))
                
                
            }
            
            
        }
        
    }
    
    
}

struct HighScoreRectangularView: View {
    
    var entry: HighScoreEntry
    
    #if os(iOS)
    let headersFont: CGFloat = 10
    let scoreFont: CGFloat = 20
    let rectWidth: CGFloat = 74
    #else
    let headersFont: CGFloat = 16
    let scoreFont: CGFloat = 30
    let rectWidth: CGFloat = 94
    #endif
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("STRATAGEM HERO").bold()
                    .font(Font.custom("FSSinclair", size: headersFont))
                RoundedRectangle(cornerRadius: 25).frame(width: rectWidth, height: 2)
                    .foregroundStyle(.gray)
                VStack(alignment: .leading, spacing: -4) {
                    Text("High Score".uppercased())
                        .font(Font.custom("FSSinclair", size: headersFont))
                    
                    
                    Text("\(entry.highScore)")
                        .font(Font.custom("FSSinclair", size: scoreFont)).bold()
                    #if os(watchOS)
                    
                        .foregroundStyle(.yellow)
                    
                    #endif
                }.padding(.top, 2)
            }
            Spacer()
        }.padding(.vertical, 3)
#if os(iOS)
        .padding(.top, 2).padding(.horizontal, 8).background(Color.yellow).foregroundStyle(Color.black).clipShape(RoundedRectangle(cornerRadius: 6)).padding(.trailing, 5)
#endif
        
        .widgetAccentable(true)
    }
      
    
    
}

#if os(iOS)
struct Stratagem_Hero_High_Score_Widget: Widget {
    let kind: String = "Stratagem_Hero_High_Score_Widget"
    
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .systemSmall, .accessoryInline]

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Stratagem_Hero_High_Score_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Stratagem_Hero_High_Score_WidgetEntryView(entry: entry)
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
        .configurationDisplayName("Stratagem Hero High Score")
        .description("Displays your high score in Stratagem Hero.")
    }
}

#Preview(as: .accessoryInline) {
    Stratagem_Hero_High_Score_Widget()
} timeline: {
    HighScoreEntry(date: .now, highScore: 2247331)
}
#endif
