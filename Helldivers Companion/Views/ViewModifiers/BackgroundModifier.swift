//
//  BackgroundModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct ConditionalBackgroundModifier: ViewModifier {
    
    @ObservedObject var viewModel: PlanetsViewModel
    
    var grayscale = false
    
    var opacity = 1.0

    func body(content: Content) -> some View {
        
        content
        .background {
            if viewModel.darkMode {
                Color.black.ignoresSafeArea()
            } else {
                Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
                    .grayscale(grayscale ? 1.0 : 0.0)
                    .opacity(opacity)
            }
        }
        
        
    }
    
}

extension View {
    func conditionalBackground(viewModel: PlanetsViewModel, grayscale: Bool = false, opacity: CGFloat = 1.0) -> some View {
            modifier(ConditionalBackgroundModifier(viewModel: viewModel, grayscale: grayscale, opacity: opacity))
        }
}
