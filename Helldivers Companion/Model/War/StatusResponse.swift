//
//  StatusResponse.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct StatusResponse: Codable {
    let planetActiveEffects: [GalacticEffect]
    let globalResources: [GlobalResource]
}
