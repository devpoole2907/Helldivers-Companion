//
//  DualRingSpinner.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/05/2025.
//

import SwiftUI

// loading

struct DualRingSpinner: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            
            // outer ring background (gray)
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 100, height: 100)
            
            // outer white ring
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.white, lineWidth: 8)
                .frame(width: 100, height: 100)
                .rotationEffect(Angle(degrees: animate ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: animate)

            // inner yellow ring
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.yellow, lineWidth: 8)
                .frame(width: 70, height: 70)
                .rotationEffect(Angle(degrees: animate ? -360 : 0))
                .animation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false), value: animate)
        }
        .scaleEffect(0.44)
        .onAppear {
            animate = true
        }
    }
}
