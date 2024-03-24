//
//  WatchConnectivityProvider.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/03/2024.
//

import SwiftUI
import WatchConnectivity

class WatchConnectivityProvider: NSObject, ObservableObject, WCSessionDelegate {
    // Called when the session has been activated.
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            // Handle activation completion, check for errors, etc.
            if let error = error {
                print("WC Session activation failed with error: \(error.localizedDescription)")
                return
            }
            print("WC Session activated with state: \(activationState.rawValue)")
        }
    #if os(iOS)
        // iOS only: Called when the session could not be activated or if the session becomes inactive.
        func sessionDidBecomeInactive(_ session: WCSession) {
            // Handle session becoming inactive.
            print("WC Session did become inactive")
        }
        
        // iOS only: Called when the session has been deactivated.
        func sessionDidDeactivate(_ session: WCSession) {
            // Handle session deactivation, you may need to activate a new session.
            print("WC Session did deactivate")
            session.activate()  // Often you'll want to reactivate the session after it's been deactivated.
        }
    #endif
    
    // for apple watch to receive the high score from the ios app, update its high score if its higher on ios
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
            DispatchQueue.main.async {
                if let receivedHighScore = userInfo["highScore"] as? Int {
                    if receivedHighScore > self.highScore {
                        self.highScore = receivedHighScore
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
    #if os(iOS)
    func sendHighScore(highScore: Int) {
        let userInfo = ["highScore": highScore]
        WCSession.default.transferUserInfo(userInfo)
    }
    #endif

}
