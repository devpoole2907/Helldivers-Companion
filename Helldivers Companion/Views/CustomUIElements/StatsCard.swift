//
//  StatsCard.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

/// Reusable stats card: gray background, dashed border stroke, optional floating label in top-left corner.
struct StatsCard<Content: View>: View {
    var label: String?
    var dashPhase: CGFloat = 30
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            content
                .padding()
                .background {
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: dashPhase))
                        .foregroundStyle(.gray)
                        .opacity(0.5)
                        .shadow(radius: 3)
                }
            if let label {
                Text(label)
                    .offset(x: 20, y: -12)
                    .font(Font.custom("FSSinclair", size: 20))
                    .bold()
                    .foregroundStyle(.white)
                    .opacity(0.8)
                    .shadow(radius: 5.0)
            }
        }
        .shadow(radius: 3.0)
        .padding()
    }
}
