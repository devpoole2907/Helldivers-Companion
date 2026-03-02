//
//  CloseButton.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI
import UIKit

// wrapped UIKit exit button

struct CloseButton: UIViewRepresentable {
    
    @Environment(\.dismiss) var dismiss
    
    private var action: (() -> Void)?
    
    init(action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func makeUIView(context: Context) -> UIButton {
        
        if let action = action {
            
            UIButton(type: .close, primaryAction: UIAction { _ in action() })
            
        } else {
            UIButton(type: .close, primaryAction: UIAction { _ in dismiss() })
        }
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {}
}

#Preview("Default dismiss") {
    CloseButton()
        .frame(width: 44, height: 44)
        .padding()
        .background(.black)
}

#Preview("Custom action") {
    CloseButton { print("custom close") }
        .frame(width: 44, height: 44)
        .padding()
        .background(.black)
}
