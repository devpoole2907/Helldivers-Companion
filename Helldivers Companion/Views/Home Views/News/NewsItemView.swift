//
//  NewsItemView.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/03/2024.
//

import SwiftUI

struct NewsItemView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @State private var isExpanded = false
    
    var newsTitle: String? = nil
    var newsMessage: String = "Terminids! Automatons! EVERYWHERE!!??!!"
    var isWidget = false
    
    var body: some View {

            VStack(alignment: .leading, spacing: 4) {
                
                if let title = newsTitle {
                    Text(title).textCase(.uppercase) .font(Font.custom("FS Sinclair", size: mediumFont)).foregroundStyle(Color.yellow)
                        .lineLimit(isWidget ? 1 : nil)
                }
                // replace only first found new line
                Text(newsMessage.replacingOccurrences(of: "\n", with: "", options: [], range: newsMessage.range(of: "\n"))).font(Font.custom("FS Sinclair", size: isWidget ? 14 : mediumFont)).foregroundStyle(Color.white)
              //  #if os(iOS)
                #if os(iOS)
                    .lineLimit(isWidget ? (widgetFamily != .systemMedium ? 10 : 4) : (isExpanded ? nil : 3))
                #elseif os(watchOS)
                    .lineLimit(isExpanded || isWidget ? nil : 4)
                #endif
                    .frame(maxHeight: isExpanded ? .infinity : 100)
                
                if !isWidget {
                    Button(action: { 
                        withAnimation(.bouncy) {
                            isExpanded.toggle()
                        }
                        }) {
                        Text(isExpanded ? "Less" : "More")
                            .foregroundStyle(.yellow)
                            .font(Font.custom("FS Sinclair", size: smallFont))
                            .padding([.top, .bottom], 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.opacity)
                }
                
                 /*   if isWidget == false { // Only show "More" button if not a widget
                                Button(action: { isExpanded.toggle() }) {
                                    Text(isExpanded ? "Less" : "More")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                        .padding([.top, .bottom], 4)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .transition(.opacity)
                            }*/
                   
             //   #endif
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
