//
//  PlayerCountTip.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/02/2025.
//


import TipKit

#if os(iOS)
@available(iOS 17.0, *)
struct PlayerCountTip: Tip {
    var title: Text {
        Text("Player Count")
    }
    
    var message: Text? {
        Text("Tap here to view the player distribution across the galaxy.")
    }
    
    
    var options: [any TipOption] {
        MaxDisplayCount(1)
    }
}
#endif
