//
//  Helldivers_CompanionApp.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import FirebaseCore
import Firebase
import UserNotifications
import FirebaseMessaging
import MijickPopupView
#if os(iOS)
import TipKit
#endif

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        migrateUserDefaults() // migrate users to new user defaults so they dont lose their high score in stratagem hero if they aren't signed in
        
        
        // set defaults for subscribed notification topics
        
        // TODO: implement toggleable settings for users to choose their notification topics
        let userPrefs = UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion") ?? .standard
        
        userPrefs.register(defaults: [
            "planetEventsEnabled": true,
            "liberationEnabled": true,
            "newsEnabled": true,
            "dssEnabled": true,
            "unsubscribedFromOldTopic": false
        ])
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("fcm", fcm)
        }
        
        // TRANSITIONING TO SEPARATED MESSAGE TOPICS
        
        let userPrefs = UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion") ?? .standard
        
        // unsubscribe from the original messages topic
        if !userPrefs.bool(forKey: "unsubscribedFromOldTopic") {
            Messaging.messaging().unsubscribe(fromTopic: "newMessages") { error in
                if let error = error {
                    print("Error unsubscribing from old `newMessages`: \(error)")
                } else {
                    print("Successfully unsubscribed from `newMessages`!")
                    userPrefs.set(true, forKey: "unsubscribedFromOldTopic")
                }
            }
        }
        
        // subscribe to the new notifications topics based on whether user has it turned on, default is true
        
        // subscribe to announcements topic always true
        toggleTopicSubscription(
            topic: "announcements",
            isEnabled: true
        )
        
        toggleTopicSubscription(
            topic: "planetEventUpdates",
            isEnabled: userPrefs.bool(forKey: "planetEventsEnabled")
        )
        
        toggleTopicSubscription(
            topic: "liberationUpdates",
            isEnabled: userPrefs.bool(forKey: "liberationEnabled")
        )
        
        toggleTopicSubscription(
            topic: "newsUpdates",
            isEnabled: userPrefs.bool(forKey: "newsEnabled")
        )
        
        toggleTopicSubscription(
            topic: "dssUpdates",
            isEnabled: userPrefs.bool(forKey: "dssEnabled")
        )
        
    }
    
    private func toggleTopicSubscription(topic: String, isEnabled: Bool) {
        if isEnabled {
            // subscribe to topic if user has it turned on
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    print("Error subscribing to \(topic): \(error)")
                } else {
                    print("Subscribed to \(topic)!")
                }
            }
        } else {
            // unsub from topic if turned off
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    print("Error unsubscribing from \(topic): \(error)")
                } else {
                    print("Unsubscribed from \(topic).")
                }
            }
        }
    }
    
    
    // to show notifications even when app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    
    
    
}

@main
struct Helldivers_CompanionApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
#if os(iOS)
    init() {
        if #available(iOS 17.0, *) {
            try? Tips.configure()
        }
    }
#endif
    
    var body: some Scene {
        WindowGroup {
            
            RootView().preferredColorScheme(.dark).implementPopupView()
                .defaultAppStorage(UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion") ?? .standard)
            
        }
    }
}
