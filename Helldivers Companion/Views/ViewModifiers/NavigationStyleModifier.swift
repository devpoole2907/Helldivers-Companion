//
//  NavigationStyleModifier.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
#if os(iOS)
import SwiftUIIntrospect

struct HelldiversNavigationStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18, .v26)) { controller in
                print("I am introspecting!")

                DispatchQueue.main.async {
                    let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
                    let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize

                    // default to sf system font
                    let largeFont = UIFont(name: "FSSinclair-Bold", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
                    let inlineFont = UIFont(name: "FSSinclair-Bold", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)

                    let largeAttributes: [NSAttributedString.Key: Any] = [
                        .font: largeFont
                    ]

                    let inlineAttributes: [NSAttributedString.Key: Any] = [
                        .font: inlineFont
                    ]

                    controller.navigationBar.titleTextAttributes = inlineAttributes
                    controller.navigationBar.largeTitleTextAttributes = largeAttributes
                }
            }
    }
}

extension View {
    func helldiversNavigationStyle() -> some View {
        modifier(HelldiversNavigationStyle())
    }
}
#endif
