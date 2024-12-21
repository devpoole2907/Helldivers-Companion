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
            return widgetRenderingMode == .accented ? 0.4 : 1
        }
#endif
        return 1
    }
    
    var secondaryOpacity: Double {
        if primaryColor == secondaryColor {
            return 0.2
        } else {
            return backgroundOpacity
        }
    }
    
    @State private var animatedValue: Double = 0.0
    
    var value: Double // Expected to be between 0.0 and 1.0
    var primaryColor: Color = .cyan
    var secondaryColor: Color
    var height: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                Rectangle()
                    .fill(primaryColor)
                    .frame(width: min(CGFloat(self.animatedValue)*geometry.size.width, geometry.size.width))
                    .opacity(backgroundOpacity)
                
                Rectangle()
                    .fill(secondaryColor)
                    .frame(width: max((1 - CGFloat(self.animatedValue))*geometry.size.width, 0))
                    .opacity(secondaryOpacity)
            }.animation(.easeInOut(duration: 2.0), value: animatedValue)
            
        }
        .frame(height: height)
        .onAppear {
                    // animate progress bar when view appears
                    withAnimation {
                        animatedValue = value
                    }
                }
        .onChange(of: value) { newValue in
                    // update animation value when value changes
                    withAnimation {
                        animatedValue = newValue
                    }
                }
    }
}

#Preview {
    RectangleProgressBar(value: 30 / 100, secondaryColor: Color.red)
}
