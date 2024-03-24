//
//  WatchConnectivityProvider.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/03/2024.
//

import SwiftUI
import WatchConnectivity
#if os(iOS)
import GameKit
#endif

class WatchConnectivityProvider: NSObject, ObservableObject, WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
#if os(iOS)
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
        print("WC Session did become inactive")
    }
    
    
    func sessionDidDeactivate(_ session: WCSession) {
        
        print("WC Session did deactivate")
        session.activate()  // reactivate session if deactivated
    }
#endif
    
    // for apple watch to receive the high score from the ios app, update its high score if its higher on ios
    // and vice versa
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let receivedHighScore = userInfo["highScore"] as? Int {
                if receivedHighScore > self.highScore {
                    self.highScore = receivedHighScore
                    
#if os(iOS)
                    // update the game center score with the new one
                    let gameCenterManager = GameCenterManager()
                    let leaderboardId = "com.poole.james.helldiverscompanion.highscores"
                    gameCenterManager.reportScore(score: self.highScore, leaderboardID: leaderboardId)
#endif
                    
                }
            }
        }
    }
    
    static let shared = WatchConnectivityProvider()
    
    @AppStorage("highScore") var highScore: Int = 0
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    // uses transfer user info not send message, in order to queue the sent data if the app on the device to send to is inactive
    func sendHighScore(highScore: Int) {
        let userInfo = ["highScore": highScore]
        WCSession.default.transferUserInfo(userInfo)
    }
    
    
}
