//
//  War_Monitor_Total_Player_Count_Watch_Widget.swift
//  War Monitor Total Player Count Watch Widget
//
//  Created by James Poole on 20/04/2024.
//

import WidgetKit
import SwiftUI
#if os(watchOS)
@main
struct War_Monitor_Total_Player_Count_Watch_Widget: Widget {
    let kind: String = "War_Monitor_Total_Player_Count_Watch_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
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
