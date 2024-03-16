//
//  GameCenterManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI
import GameKit

class GameCenterManager: ObservableObject {
    
    @Published var isAuthenticated = false
    
    @AppStorage("signedInBefore") var hasSignedInBefore = false // used to not immediately show game center login/icon if they havent signed in before
    
    func authenticatePlayer(completion: @escaping (Result<GKLocalPlayer, Error>) -> Void) {
           let localPlayer = GKLocalPlayer.local
           localPlayer.authenticateHandler = { viewController, error in
               if let viewController = viewController {
                   // Handle viewController presentation to complete authentication
                   completion(.failure(error ?? NSError(domain: "com.poole.james.helldivers-companion", code: -1, userInfo: nil)))
               } else if localPlayer.isAuthenticated {
                   self.isAuthenticated = true
                   completion(.success(localPlayer))
               } else {
                   // Authentication failed
                   completion(.failure(error ?? NSError(domain: "com.poole.james.helldivers-companion", code: -1, userInfo: nil)))
               }
           }
       }

    func loadTopScores(leaderboardID: String, count: Int = 3) async -> [GKLeaderboard.Entry] {
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            if let leaderboard = leaderboards.first(where: { $0.baseLeaderboardID == leaderboardID }) {
                let entries = try await leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(1...count))
                if !entries.1.isEmpty {
                    print("Got the player count")
                    
                  
                    return entries.1
                }
            }
        } catch {
            print("Error loading leaderboard entries: \(error.localizedDescription)")
        }
        
        return []  
    }

    
    func reportScore(score: Int, leaderboardID: String) {
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
                if let error = error {
                    print("Error submitting score: \(error.localizedDescription)")
                } else {
                    print("Score submitted successfully")
                }
            }
        }
    }
}

