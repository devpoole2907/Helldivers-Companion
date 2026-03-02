//
//  DarkGradientOverlay.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

/// A clear-to-black gradient overlay with multiply blend mode,
/// used to darken the bottom of planet images.
struct DarkGradientOverlay: View {
    var maxHeight: CGFloat?

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, .black]),
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.multiply)
        .frame(maxHeight: maxHeight ?? .infinity)
    }
}
