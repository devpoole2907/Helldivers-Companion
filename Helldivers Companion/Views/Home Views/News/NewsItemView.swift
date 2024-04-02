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
    var published: UInt32
    @State var warStatusResponse: WarStatusResponse?
    var isWidget = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            if let title = newsTitle {
                Text(title).textCase(.uppercase) .font(Font.custom("FS Sinclair", size: mediumFont)).foregroundStyle(Color.yellow)
#if os(watchOS)
                    .lineLimit(nil)
#elseif os(iOS)
                    .lineLimit(isWidget ? (widgetFamily != .systemMedium ? 2 : 1) : nil)
#endif
            }
            // replace only first found new line
            Text(newsMessage.replacingOccurrences(of: "\n", with: "", options: [], range: newsMessage.range(of: "\n"))).font(Font.custom("FS Sinclair", size: isWidget ? 14 : mediumFont)).foregroundStyle(Color.white)
            //  #if os(iOS)
#if os(iOS)
                .lineLimit(isWidget ? (widgetFamily != .systemMedium ? 10 : 4) : (isExpanded ? nil : 3))
                .frame(maxHeight: isExpanded ? .infinity : 100)
#elseif os(watchOS)
                .lineLimit(nil)
            
#endif
            
            
            // show all of it on watchos due to the vertical paging system on the watch
            HStack {
                
                if let warStartDate = warStatusResponse?.convertStartedAtToDate() {
                    let publishedTimeInterval = TimeInterval(published)
                    let publishedDate = warStartDate.addingTimeInterval(publishedTimeInterval)
                    let now = Date()
                    
                    let components = Calendar.current.dateComponents([.hour, .day], from: publishedDate, to: now)
                    let hoursDifference = components.hour ?? 0
                    let daysDifference = components.day ?? 0

                    if daysDifference > 0 {
                        Text("\(daysDifference) day\(daysDifference > 1 ? "s" : "") ago").font(Font.custom("FS Sinclair", size: smallFont))
                            .foregroundStyle(.gray)
                    } else {
                        Text("\(hoursDifference) hour\(hoursDifference > 1 ? "s" : "") ago")
                            .font(Font.custom("FS Sinclair", size: smallFont))
                            .foregroundStyle(.gray)
                    }
                }

                
                Spacer()
#if os(iOS)
                if !isWidget {
                    Button(action: {
                        withAnimation(.bouncy) {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Less" : "More")
                            .foregroundStyle(.yellow)
#if os(iOS)
                            .font(Font.custom("FS Sinclair", size: smallFont))
#elseif os(watchOS)
                            .font(Font.custom("FS Sinclair", size: mediumFont))
#endif
                            .padding([.top, .bottom], 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    //.frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.opacity)
                }
#endif
                
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
#if os(iOS)
        .padding()
#else
        .padding(.horizontal)
#endif
        .frame(maxWidth: .infinity)
        
        
        
        // dont show background on watchos
#if os(iOS)
        .background {
            Color.black
        }.border(Color.blue.opacity(isWidget ? 0 : 0.4), width: 6)
#else
        
        // show shadows on watchos because the text is on opaque backgorund
        
            .shadow(radius: 3.0)
        
#endif
        
        
        
    }
    
    
}

#Preview {
    NewsItemView(published: 4444974)
}
