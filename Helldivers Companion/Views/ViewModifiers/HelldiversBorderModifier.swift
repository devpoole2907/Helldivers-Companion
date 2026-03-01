//
//  HelldiversBorderModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct HelldiversBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
    }
}

extension View {
    func helldiversBorder() -> some View {
        modifier(HelldiversBorderModifier())
    }
}
