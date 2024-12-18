//
//  MajorOrderTimeView.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

struct MajorOrderTimeView: View {
    
    // to support ios 18 widget tinting
    #if os(iOS)
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    #endif
    
    var backgroundOpacity: Double {
        #if os(iOS)
            return widgetRenderingMode == .accented ? 0.2 : 1
        #endif
        return 1
    }
    
    var timeRemaining: Int64 = 0
    
    var isWidget = false
    
    var isMini = false
    
    var nameSize: CGFloat {
        
        if isWidget {
            return 14
        } else if isMini {
            return 10
        } 
        
        return mediumFont
    }
    
    #if os(iOS)
    let alignment: VerticalAlignment = .bottom
    #elseif os(watchOS)
    let alignment: VerticalAlignment = .center
    #endif
    
    var body: some View {
        HStack(alignment: alignment) {
            if !isMini {
                Text("Major Order ends in:").foregroundStyle(.white)
#if os(watchOS)
                
                    .multilineTextAlignment(.center)
                
#endif
            }
            Text("\(formatDuration(seconds: timeRemaining))").padding(.top, 2).padding(.horizontal, 16).background(Color.yellow.opacity(backgroundOpacity)).foregroundStyle(Color.black)
        }.font(Font.custom("FSSinclair", size: nameSize))
    }
}

#Preview {
    MajorOrderTimeView()
}
