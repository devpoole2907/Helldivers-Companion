//
//  PieChartTip.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/02/2025.
//
import TipKit

#if os(iOS)
@available(iOS 17.0, *)
struct PieChartTip: Tip {
    var title: Text {
        Text("Player Counts")
    }
    
    var message: Text? {
        Text("Drag your finger across the segments to view different player counts.")
    }
    
    
    var options: [any TipOption] {
        MaxDisplayCount(2)
    }
}
#endif
