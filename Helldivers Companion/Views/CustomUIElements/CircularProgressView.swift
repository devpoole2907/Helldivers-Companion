//
//  CircularProgressView.swift
//  Helldivers Companion
//
//  Created by James Poole on 08/04/2024.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(color)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.cyan,
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .shadow(radius: 3)
                .rotationEffect(.degrees(-90))
        }
    }
}
