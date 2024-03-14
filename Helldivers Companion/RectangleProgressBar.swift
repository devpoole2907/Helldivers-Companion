//
//  RectangleProgressBar.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct RectangleProgressBar: View {
    var value: Double // Expected to be between 0.0 and 1.0
    
    var secondaryColor: Color

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width))
                
                Rectangle()
                    .fill(secondaryColor)
                    .frame(width: max((1 - CGFloat(self.value))*geometry.size.width, 0))
            }
       
        }
        .frame(height: 20)
    }
}

#Preview {
    RectangleProgressBar(value: 30 / 100, secondaryColor: Color.red)
}
