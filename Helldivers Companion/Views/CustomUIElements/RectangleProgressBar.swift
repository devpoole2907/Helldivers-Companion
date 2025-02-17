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

//
//  MiniRectangleProgressBar.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import Combine

struct MiniRectangleProgressBar: View {
    
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

    @State private var animatedValue: Double = 0.0
    @State private var jitterOffsets: [CGFloat] = Array(repeating: 0, count: 50) // for jittering effect, needs same count as bars
    @State private var timerSubscription: AnyCancellable? // Store the timer subscription

    var value: Double // Expected to be between 0.0 and 1.0
    var primaryColor: Color = .purple
    var secondaryColor: Color
    var height: CGFloat = 80
    var barCount: Int = 50 // Number of mini rectangles
    var unfilledScale: CGFloat = 0.5 // Scale factor for unfilled bars (smaller ones)

    var body: some View {
        GeometryReader { geometry in
            let barWidth = (geometry.size.width - CGFloat(barCount - 1) * 2) / CGFloat(barCount) // Adjust for spacing

            HStack(spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    let isFilled = index < Int(animatedValue * Double(barCount))
                    Rectangle()
                        .fill(index < Int(animatedValue * Double(barCount)) ? primaryColor : primaryColor)
                        .frame(
                            width: barWidth,
                                                    height: isFilled ? height + jitterOffsets[index] : (height * unfilledScale) + jitterOffsets[index]
                                                )
                        .cornerRadius(10)
                        .opacity(isFilled ? backgroundOpacity : 0.5)
                        .shadow(color: isFilled ? primaryColor.opacity(0.8) : .clear, radius: isFilled ? 10 : 0)
                                                .overlay(
                                                    Rectangle()
                                                        .fill(primaryColor.opacity(isFilled ? 0.6 : 0.2)) // Glow only on filled bars
                                                        
                                                        .blur(radius: isFilled ? 6 : 3) // Intense glow effect
                                                )
                                                .animation(.easeInOut(duration: 0.2), value: jitterOffsets[index])
                }
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation {
                animatedValue = value
            }
            startJittering()
        }
        .onDisappear {
            timerSubscription?.cancel() // Stop the timer when the view disappears
        }
        .onChange(of: value) { newValue in
            withAnimation {
                animatedValue = newValue
            }
        }
    }
    
    // Starts jittering the bar heights randomly within 5 points
    private func startJittering() {
        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    jitterOffsets = (0..<barCount).map { _ in CGFloat.random(in: -5...5) }
                }
            }
    }
}

#Preview {
    MiniRectangleProgressBar(value: 0.6, secondaryColor: Color.black.opacity(0.2))
}
