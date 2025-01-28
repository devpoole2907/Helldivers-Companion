//
//  NewsItemView.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/03/2024.
//

import SwiftUI

@available(watchOS 9.0, *)
struct NewsItemView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @State private var isExpanded = false
    
    var newsTitle: String? = nil
    var newsMessage: String = "Terminids! Automatons! EVERYWHERE!!??!!"
    var published: UInt32
    @State var configData: RemoteConfigDetails?
    var isWidget = false
    
    var warTime: Int64?
    
    var body: some View {
        
        ZStack {
            #if os(iOS)
            if !isWidget {
                Color.gray.opacity(0.2)
            }
            #endif
            
        VStack(alignment: .leading, spacing: 4) {
            
            if let title = newsTitle {
                Text(title).textCase(.uppercase) .font(Font.custom("FSSinclair-Bold", size: mediumFont)).foregroundStyle(Color.yellow)
#if os(watchOS)
                    .lineLimit(nil)
#elseif os(iOS)
                    .lineLimit(isWidget ? (widgetFamily != .systemMedium ? 2 : 1) : nil)
#endif
            }
            // replace only first found new line
            Text(newsMessage.replacingOccurrences(of: "\n", with: "", options: [], range: newsMessage.range(of: "\n"))).font(Font.custom("FSSinclair", size: isWidget ? 14 : mediumFont)).foregroundStyle(Color.white)
            //  #if os(iOS)
#if os(iOS)
                .lineLimit(isWidget ? (widgetFamily != .systemMedium ? 10 : 4) : (isExpanded ? nil : 3))
                .frame(maxHeight: isExpanded ? .infinity : 100)
#elseif os(watchOS)
                .lineLimit(nil)
            
#endif
            
            
            // show all of it on watchos due to the vertical paging system on the watch
            HStack {
                if let warStartTime = warTime {
                    // Subtract the published time from the current war time
                    let timeElapsed = warStartTime - Int64(published)
                    
                    // Convert the time elapsed to seconds
                    let elapsedTimeInSeconds = TimeInterval(timeElapsed)
                    
                    // Calculate days, hours, and minutes
                    let components = Calendar.current.dateComponents(
                        [.day, .hour, .minute],
                        from: Date(timeIntervalSince1970: 0),
                        to: Date(timeIntervalSince1970: elapsedTimeInSeconds)
                    )
                    
                    let daysDifference = components.day ?? 0
                    let hoursDifference = components.hour ?? 0
                    let minutesDifference = components.minute ?? 0
                    
                    // Display the time difference
                    if daysDifference > 0 {
                        Text("\(daysDifference) day\(daysDifference > 1 ? "s" : "") ago")
                            .font(Font.custom("FSSinclair", size: smallFont))
                            .foregroundStyle(.gray)
                    } else if hoursDifference > 0 {
                        Text("\(hoursDifference) hour\(hoursDifference > 1 ? "s" : "") ago")
                            .font(Font.custom("FSSinclair", size: smallFont))
                            .foregroundStyle(.gray)
                    } else {
                        Text("\(minutesDifference) minute\(minutesDifference > 1 ? "s" : "") ago")
                            .font(Font.custom("FSSinclair", size: smallFont))
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
                            .font(Font.custom("FSSinclair-Bold", size: smallFont))
#elseif os(watchOS)
                            .font(Font.custom("FSSinclair-Bold", size: mediumFont))
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
            #endif
        
    }
#if os(iOS)
        
   
        .background {
            
            if !isWidget { Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: [57, 19], dashPhase: 30))
                    .foregroundStyle(.gray)
                    .opacity(0.5)
                    .shadow(radius: 3)
                
            } else {
                Rectangle().foregroundStyle(Color.clear)
                
            }
            
        }
        
  
#else
        .padding(.horizontal)
#endif
        .frame(maxWidth: .infinity)
        
        

#if os(watchOS)
        
        // show shadows on watchos because the text is on opaque backgorund
        
            .shadow(radius: 3.0)
        
#endif
        
        
        
    }
    
    
}

