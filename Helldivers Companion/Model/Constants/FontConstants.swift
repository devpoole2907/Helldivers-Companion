//
//  FontConstants.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import Foundation

#if os(iOS)
let smallFont: CGFloat = 16
let mediumFont: CGFloat = 18
let largeFont: CGFloat = 24
let weatherIconSize: CGFloat = 16
#elseif os(watchOS)
let smallFont: CGFloat = 12
let mediumFont: CGFloat = 12
let largeFont: CGFloat = 16
let weatherIconSize: CGFloat = 8
#endif
