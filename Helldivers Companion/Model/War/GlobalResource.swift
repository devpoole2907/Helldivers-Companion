//
//  GlobalResource.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct GlobalResource: Codable {
    let id32: Int64
    let currentValue: Int64
    let maxValue: Int64
    let flags: Int64
}
