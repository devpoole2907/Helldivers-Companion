//
//  WhiteCircleBackgroundModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct WhiteCircleBackgroundModifier: ViewModifier {
    var padding: CGFloat = 4
    var shadowRadius: CGFloat = 3.0
    var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                Circle()
                    .foregroundStyle(Color.white)
                    .shadow(radius: shadowRadius)
                    .opacity(opacity)
            }
    }
}

extension View {
    func whiteCircleBackground(padding: CGFloat = 4, shadowRadius: CGFloat = 3.0, opacity: Double = 1.0) -> some View {
        modifier(WhiteCircleBackgroundModifier(padding: padding, shadowRadius: shadowRadius, opacity: opacity))
    }
}
