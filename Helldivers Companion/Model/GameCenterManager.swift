//
//  GameCenterManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI
import GameKit

@MainActor
@Observable
class GameCenterManager {
    
    var isAuthenticated = false
    
    // UserDefaults-backed stored var (avoids @AppStorage + @Observable redeclaration conflict)
    var hasSignedInBefore: Bool = UserDefaults.standard.bool(forKey: "signedInBefore") {
        didSet { UserDefaults.standard.set(hasSignedInBefore, forKey: "signedInBefore") }
    }
    
    func authenticatePlayer(completion: @escaping (Result<GKLocalPlayer, Error>) -> Void) {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                // Present the Game Center sign-in UI on the root view controller
                Task { @MainActor in
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(viewController, animated: true)
                    }
                }
            } else if localPlayer.isAuthenticated {
                // Set state and deliver success callback together on MainActor
                // to avoid a race where the caller reads isAuthenticated before it is set
                Task { @MainActor [weak self] in
                    self?.isAuthenticated = true
                    completion(.success(localPlayer))
                }
            } else {
                // Authentication failed
                completion(.failure(error ?? NSError(domain: "com.poole.james.helldivers-companion", code: -1, userInfo: nil)))
            }
        }
    }

    func fetchHighScore(leaderboardId: String, completion: @escaping (Int) -> Void) {
            GKLeaderboard.loadLeaderboards(IDs: [leaderboardId]) { (leaderboards, error) in
                guard let leaderboard = leaderboards?.first(where: { $0.baseLeaderboardID == leaderboardId }) else {
                    print("Leaderboard not found or error occurred: \(String(describing: error))")
                    completion(0)
                    return
                }

                leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime) { (localPlayerEntry, _, _) in
                    let score = localPlayerEntry?.score ?? 0
                    completion(score)
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
