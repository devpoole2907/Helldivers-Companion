//
//  RectangleProgressBar.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct RectangleProgressBar: View {
    
#if os(iOS)
@Environment(\.widgetRenderingMode) var widgetRenderingMode
#endif

var backgroundOpacity: Double {
    #if os(iOS)
    if #available(iOS 18, *) {
        return widgetRenderingMode == .accented ? 0.2 : 1
    }
    #endif
    return 1
}
    
    var value: Double // Expected to be between 0.0 and 1.0
    var primaryColor: Color = .cyan
    var secondaryColor: Color
    var height: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                Rectangle()
                    .fill(primaryColor)
                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width))
                    .opacity(backgroundOpacity)
                
                Rectangle()
                    .fill(secondaryColor)
                    .frame(width: max((1 - CGFloat(self.value))*geometry.size.width, 0))
                    .opacity(backgroundOpacity)
            }
       
        }
        .frame(height: height)
    }
}

#Preview {
    RectangleProgressBar(value: 30 / 100, secondaryColor: Color.red)
}
