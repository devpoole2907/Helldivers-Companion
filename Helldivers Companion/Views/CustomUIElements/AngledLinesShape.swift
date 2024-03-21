//
//  AngledLinesShape.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

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
