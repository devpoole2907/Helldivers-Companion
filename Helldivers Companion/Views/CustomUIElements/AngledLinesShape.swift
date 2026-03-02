//
//  AngledLinesShape.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

struct AngledLinesBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                AngledLinesShape()
                    .stroke(lineWidth: 3)
                    .foregroundColor(.white)
                    .opacity(0.2)
                    .clipped()
            )
    }
}

extension View {
    func angledLinesBackground() -> some View {
        modifier(AngledLinesBackgroundModifier())
    }
}

struct AngledLinesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Determine line spacing
        let spacing: CGFloat = 12

        // Draw slanted lines
        for index in stride(from: 0, to: rect.width + rect.height, by: spacing) {
            path.move(to: CGPoint(x: index, y: 0))
            path.addLine(to: CGPoint(x: 0, y: index))
        }
        
        return path
    }
}

#Preview("Angled lines background") {
    Text("DEMOCRACY PREVAILS")
        .font(Font.custom("FSSinclair-Bold", size: 20))
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .angledLinesBackground()
        .padding()
        .background(.black)
}
