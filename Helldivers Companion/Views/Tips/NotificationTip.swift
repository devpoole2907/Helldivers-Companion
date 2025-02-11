//
//  NotificationTip.swift
//  Helldivers Companion
//
//  Created by James Poole on 11/02/2025.
//

import TipKit

#if os(iOS)
@available(iOS 17.0, *)
struct NotificationTip: Tip {
    var title: Text {
        Text("Notifications")
    }
    
    var message: Text? {
        Text("Configure your notifications here.")
    }
    
    
    var options: [any TipOption] {
        MaxDisplayCount(2)
    }
}
#endif
