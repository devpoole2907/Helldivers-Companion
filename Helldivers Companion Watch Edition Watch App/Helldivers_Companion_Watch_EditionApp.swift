//
//  Helldivers_Companion_Watch_EditionApp.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI

@main
struct Helldivers_Companion_Watch_Edition_Watch_AppApp: App {
    
    // specifies the store to use here because the root view below is the one injected w default app storage as the store
    @AppStorage("isMigrationDone", store: UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion")) var isMigrationDone: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentViewWatchVersion() .defaultAppStorage(UserDefaults(suiteName: "group.com.poole.james.HelldiversCompanion") ?? .standard)
                // migrate high scores to new user defaults store for app groups (to allow widgets to read the high score)
                    .onAppear {
                                    if !isMigrationDone {
                                        migrateUserDefaults()
                                    }
                                }
                
            
            
        }
    }
}
