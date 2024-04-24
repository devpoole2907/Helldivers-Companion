//
//  BackgroundModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct ConditionalBackgroundModifier: ViewModifier {
    
    @ObservedObject var viewModel: PlanetsViewModel

    func body(content: Content) -> some View {
        
        content
        .background {
            if viewModel.darkMode {
                Color.black.ignoresSafeArea()
            } else {
                Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
            }
        }
        
        
    }
    
}

extension View {
    func conditionalBackground(viewModel: PlanetsViewModel) -> some View {
            modifier(ConditionalBackgroundModifier(viewModel: viewModel))
        }
}
