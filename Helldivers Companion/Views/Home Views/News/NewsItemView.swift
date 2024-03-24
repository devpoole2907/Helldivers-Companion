//
//  NewsItemView.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/03/2024.
//

import SwiftUI

struct NewsItemView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var newsTitle: String? = nil
    var newsMessage: String = "Terminids! Automatons! EVERYWHERE!!??!!"
    var isWidget = false
    
    var body: some View {

            VStack(alignment: .leading, spacing: 4) {
                
                if let title = newsTitle {
                    Text(title).textCase(.uppercase) .font(Font.custom("FS Sinclair", size: isWidget ? smallFont : mediumFont)).foregroundStyle(Color.yellow)
                        .lineLimit(isWidget ? 1 : nil)
                }
                
                Text(newsMessage.replacingOccurrences(of: "\n", with: "")).font(Font.custom("FS Sinclair", size: isWidget ? 14 : mediumFont)).foregroundStyle(Color.white)
                #if os(iOS)
                    .lineLimit(isWidget ? (widgetFamily != .systemMedium ? 8 : 4 ) : nil)
                #endif
            }
            .padding()
            .frame(maxWidth: .infinity)
                .background {
                    Color.black
                }.border(Color.blue.opacity(isWidget ? 0 : 0.4), width: 6)
   
        
    }
    
    
}

#Preview {
    NewsItemView()
}
