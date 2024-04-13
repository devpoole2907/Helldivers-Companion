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

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        migrateUserDefaults() // migrate users to new user defaults so they dont lose their high score in stratagem hero if they aren't signed in
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("fcm", fcm)
        }
        
        // subscribe to notifications topic
        Messaging.messaging().subscribe(toTopic: "newMessages") { error in
            if let error = error {
                print("Error subscribing to new messages topic: \(error)")
            } else {
                print("Successfully subscribed to messages topic")
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
    
    var body: some Scene {
        WindowGroup {
            
            RootView().preferredColorScheme(.dark).implementPopupView()
                .defaultAppStorage(UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion") ?? .standard)
            
        }
    }
}
