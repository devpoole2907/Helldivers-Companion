//
//  LayoutConstants.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

enum LayoutConstants {
#if os(iOS)
    static let raceIconSize: CGFloat = 25
    static let helldiverImageSize: CGFloat = 25
    static let spacingSize: CGFloat = 10
    static let zStackAlignment: Alignment = .topTrailing
#elseif os(watchOS)
    static let raceIconSize: CGFloat = 20
    static let helldiverImageSize: CGFloat = 10
    static let spacingSize: CGFloat = 4
    static let zStackAlignment: Alignment = .topLeading
#endif
}
