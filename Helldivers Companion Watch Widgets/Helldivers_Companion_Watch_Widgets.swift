//
//  Helldivers_Companion_Watch_Widgets.swift
//  Helldivers Companion Watch Widgets
//
//  Created by James Poole on 18/03/2024.
//

import WidgetKit
import SwiftUI

@main
struct Helldivers_Companion_Watch_Widgets: Widget {
    let kind: String = "Helldivers_Companion_Watch_Widgets"
    
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular]

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlanetStatusProvider()) { entry in
            if #available(iOS 17.0, *) {
                Helldivers_Companion_WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        }
        .configurationDisplayName("Player Count")
        .description("Shows the planet with the current highest player count.")
        .supportedFamilies(supportedFamilies)
        
    }
}

#Preview(as: .accessoryRectangular) {
    Helldivers_Companion_Watch_Widgets()
} timeline: {
    SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000)
}

