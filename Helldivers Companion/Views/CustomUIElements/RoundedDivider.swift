//
//  RoundedDivider.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

/// A thin rounded-rectangle divider used between stat sections.
struct RoundedDivider: View {
    var width: CGFloat
    var bottomPadding: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .frame(width: width, height: 2)
            .padding(.bottom, bottomPadding)
    }
}
