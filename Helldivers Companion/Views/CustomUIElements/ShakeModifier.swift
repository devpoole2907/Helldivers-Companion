//
//  ShakeModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct Shake: AnimatableModifier {
    var times: CGFloat = 0
    var amplitude: CGFloat = 5
    
    private var randomFactor: CGFloat {
            CGFloat.random(in: 0.5...1.5)
        }
    
    var animatableData: CGFloat {
        get { times }
        set { times = newValue }
    }
    
    func body(content: Content) -> some View {
        content.offset(x: sin(times * .pi * 2 * randomFactor) * amplitude)
    }
}

extension View {
    func shake(times: CGFloat) -> some View {
        self.modifier(Shake(times: times))
    }
}
