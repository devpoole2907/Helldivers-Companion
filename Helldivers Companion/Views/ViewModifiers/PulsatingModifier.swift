//
//  PulsatingModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import SwiftUI

struct PulsatingModifier: ViewModifier {
    var activeColor: Color = .red
    var inactiveColor: Color = .white

    @State private var pulsate = false

    func body(content: Content) -> some View {
        content
            .foregroundStyle(pulsate ? activeColor : inactiveColor)
            .opacity(pulsate ? 1.0 : 0.4)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulsate)
            .onAppear {
                pulsate = true
            }
    }
}

extension View {
    func pulsating(active: Color = .red, inactive: Color = .white) -> some View {
        modifier(PulsatingModifier(activeColor: active, inactiveColor: inactive))
    }
}

#Preview("Pulsating text") {
    Text("DEFEND")
        .font(Font.custom("FSSinclair-Bold", size: 24))
        .pulsating()
        .padding()
        .background(.black)
}
