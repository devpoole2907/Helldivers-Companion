//
//  Helldivers_Companion_Major_Order_Watch_Widget.swift
//  Helldivers Companion Major Order Watch Widget
//
//  Created by James Poole on 24/03/2024.
//

import WidgetKit
import SwiftUI

@main
struct Helldivers_Companion_Major_Order_Watch_Widget: Widget {
    let kind: String = "Helldivers_Companion_Major_Order_Watch_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MajorOrderProvider()) { entry in
    
            Helldivers_Companion_Major_Order_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
           
        }
        .configurationDisplayName("Major Order")
        .description("Displays time remaining for the current Major Order.")
        .supportedFamilies([.accessoryRectangular])
    }
}

