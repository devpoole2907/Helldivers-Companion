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

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

            application.registerForRemoteNotifications()
            FirebaseApp.configure()
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
        
            return true
        }
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
        }
        
        
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            if let fcm = Messaging.messaging().fcmToken {
                print("fcm", fcm)
            }
            
            // subscribe to the liberation notifications topic
            Messaging.messaging().subscribe(toTopic: "liberationMessages") { error in
                        if let error = error {
                            print("Error subscribing to liberationMessages topic: \(error)")
                        } else {
                            print("Successfully subscribed to liberationMessages topic")
                        }
                    }
            
        }
        
        
 
    
}

@main
struct Helldivers_CompanionApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            
            RootView().preferredColorScheme(.dark)
            
        }
    }
}
