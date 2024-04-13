//
//  Stratagem_Hero_High_Score_Watch_Widget.swift
//  Stratagem Hero High Score Watch Widget
//
//  Created by James Poole on 13/04/2024.
//

import WidgetKit
import SwiftUI

@main
struct Stratagem_Hero_High_Score_Watch_Widget: Widget {
    let kind: String = "Stratagem_Hero_High_Score_Watch_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Stratagem_Hero_High_Score_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
        .configurationDisplayName("Stratagem Hero High Score")
        .description("Displays your high score in Stratagem Hero.")
    }
}

#Preview(as: .accessoryRectangular) {
    Stratagem_Hero_High_Score_Watch_Widget()
} timeline: {
    HighScoreEntry(date: .now, highScore: 2144563)
}
