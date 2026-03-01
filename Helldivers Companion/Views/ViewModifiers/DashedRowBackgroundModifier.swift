//
//  DashedRowBackgroundModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct DashedRowBackgroundModifier: ViewModifier {
    var dashPattern: [CGFloat]
    var dashPhase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background {
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: dashPhase))
                    .foregroundStyle(.gray)
                    .opacity(0.5)
                    .shadow(radius: 3)
            }
    }
}

extension View {
    func dashedRowBackground(dashPattern: [CGFloat], dashPhase: CGFloat = 0) -> some View {
        modifier(DashedRowBackgroundModifier(dashPattern: dashPattern, dashPhase: dashPhase))
    }
}

extension Text {
    /// Standard section header style used in database list views.
    func dbSectionHeader() -> some View {
        self
            .font(Font.custom("FSSinclair-Bold", size: 16))
            .foregroundStyle(.white).opacity(0.8)
            .padding(.horizontal)
            .padding(.bottom, -8)
            .minimumScaleFactor(0.8)
    }
}
