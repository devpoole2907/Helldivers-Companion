//
//  StatRow.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

/// A standard label/value row used in galaxy and planet stat lists.
struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).textCase(.uppercase)
                .font(Font.custom("FSSinclair", size: mediumFont))
            Spacer()
            Text(value)
                .font(Font.custom("FSSinclair", size: smallFont))
                .multilineTextAlignment(.trailing)
        }
    }
}
