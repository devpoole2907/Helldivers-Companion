//
//  NotificationSettingsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 11/02/2025.
//
import SwiftUI
import FirebaseMessaging

@available(watchOS 9.0, *)
struct NotificationSettingsView: View {
    
    // notifications settings
    @AppStorage("planetEventsEnabled") private var planetEventsEnabled = true
    
    @AppStorage("liberationEnabled") private var liberationEnabled = true
    
    @AppStorage("newsEnabled") private var newsEnabled = true
    
    @AppStorage("dssEnabled") private var dssEnabled = true
    
    private func updateTopicSubscription(topic: String, enabled: Bool) {
        if enabled {
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    print("Error subscribing to \(topic): \(error)")
                } else {
                    print("Subscribed to \(topic)")
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    print("Error unsubscribing from \(topic): \(error)")
                } else {
                    print("Unsubscribed from \(topic)")
                }
            }
        }
    }
    
    var body: some View {
        
        ScrollView {
        VStack(spacing: 20) {
            
            Text("Notifications".uppercased()).font(Font.custom("FSSinclair", size: 28)).bold()
                .multilineTextAlignment(.center)
                .padding()
                .padding(.top, 3)
                .background(
                    AngledLinesShape()
                        .stroke(lineWidth: 3)
                        .foregroundColor(.white)
                        .opacity(0.2)
                        .clipped()
                )
                .padding(.top)
            
            
            Text("Pick the notifications YOU want to see.")
                   .font(Font.custom("FSSinclair", size: 14))
                   .multilineTextAlignment(.center)
                   .foregroundStyle(.gray)
                   .padding()
                   .shadow(radius: 3)
            
            SettingsRow(settingTitle: "Event Updates", settingSubtitle: "See when planets fall under attack, and the outcome of their defense.", image: "shield.lefthalf.filled", selected: $planetEventsEnabled, dashPattern: [54, 18])
                .onTapGesture {
                    withAnimation {
                        planetEventsEnabled.toggle()
                    }
                    updateTopicSubscription(topic: "planetEventUpdates", enabled: planetEventsEnabled)
                }
            
            SettingsRow(settingTitle: "Liberation Updates", settingSubtitle: "Be the first to know when a planet is successfully liberated.", image: "target", selected: $liberationEnabled, dashPattern: [51, 11])
                .onTapGesture {
                    withAnimation {
                        liberationEnabled.toggle()
                    }
                    updateTopicSubscription(topic: "liberationUpdates", enabled: liberationEnabled)
                }
            
            SettingsRow(settingTitle: "News Updates", settingSubtitle: "Stay up to date 24/7 on the latest galactic developments and breaking news.", image: "newspaper.fill", selected: $newsEnabled, dashPattern: [59, 5])
                .onTapGesture {
                    withAnimation {
                        newsEnabled.toggle()
                    }
                    updateTopicSubscription(topic: "newsUpdates", enabled: newsEnabled)
                }
            
            // TODO: add dss enabled once topic is implemented
            SettingsRow(settingTitle: "DSS Updates", settingSubtitle: "Track the Democracy Space Station’s movements and active tacticals.", image: "dssIcon", selected: .constant(false), dashPattern: [62, 15], systemImage: false)
                .opacity(0.3)
                .overlay {
                    Text("Coming Soon".uppercased()).font(Font.custom("FSSinclair", size: smallFont)).bold().foregroundStyle(.white).shadow(radius: 3)
                }
            
            Spacer()
            
        }.padding()
        
    }.scrollContentBackground(.hidden)
        
        .presentationDetents([.fraction(0.8)])
        .customSheetBackground(ultraThin: true)
        .presentationDragIndicator(.visible)
        
        
    }
    
    
}
