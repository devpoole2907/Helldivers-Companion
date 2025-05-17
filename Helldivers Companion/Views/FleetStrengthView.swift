//
//  FleetStrengthView.swift
//  Helldivers Companion
//
//  Created by James Poole on 18/05/2025.
//

// for illuminate fleet strength

import SwiftUI

struct FleetStrengthView: View {
    let fleetStrengthProgress: Double

    var body: some View {
        VStack(spacing: 0) {
            Text("ILLUMINATE FLEET STRENGTH")
                .foregroundStyle(.white)
                .font(Font.custom("FSSinclair-Bold", size: smallFont))
                .multilineTextAlignment(.center)

            RectangleProgressBar(
                value: fleetStrengthProgress,
                primaryColor: .purple,
                secondaryColor: .clear,
                height: 11
            )
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
            .border(Color.purple, width: 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
