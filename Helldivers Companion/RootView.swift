//
//  RootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct RootView: View {
    
    @State private var currentTab: Tab = .home
    
    @StateObject private var notificationManager = NotificationManager()
    
    @StateObject var viewModel = PlanetsViewModel()
    
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: $currentTab) {
                
                ContentView().environmentObject(viewModel)
                    .tag(Tab.home)
                
                    .toolbarBackground(.hidden, for: .tabBar)
                
                    .task {
                        await notificationManager.request()
                    }
                
                NewsView()
                    .tag(Tab.news)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                GameView()
                    .tag(Tab.game)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                
                
                
            }
            tabButtons
        }.task {
            await notificationManager.getAuthStatus()
        }
        
        .onAppear {
            
            viewModel.startUpdating()

        }
        
    }
    
    var tabButtons: some View {
        VStack(spacing: 0){
            HStack(spacing: 0) {
                TabButton(tab: .home, action: {currentTab = .home})
                TabButton(tab: .news, action: {currentTab = .news})
                TabButton(tab: .game, action: {currentTab = .game})
            }
            .padding(.top, (UIScreen.main.bounds.height) == 667 || (UIScreen.main.bounds.height) == 736 ? 10 : 15)
            .padding(.bottom, (UIScreen.main.bounds.height) == 667 || (UIScreen.main.bounds.height) == 736 ? 10 : 0)
            .ignoresSafeArea(.keyboard)
        }.ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    func TabButton(tab: Tab, action: (() -> Void)? = nil) -> some View {
        
        
        
        Button(action: {
            if let action = action {
                action()
            }
        }){
            VStack(spacing: -10) {
                if let systemImage = tab.systemImage {
                    Image(systemName: systemImage)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(currentTab == tab ? .accentColor : .gray)
                        .padding()
                    
                    
                    
                    
                }
                
                Text(tab.rawValue).textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 20))
            }.padding(.horizontal)
                .padding(.bottom, 10)
                .frame(width: 100)
                .background {
                    Color.black.opacity(0.7)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } .frame(maxWidth: .infinity)
        
        
    }
}

#Preview {
    RootView()
}

extension View {
    func getRect()->CGRect {
        return UIScreen.main.bounds
    }
}

enum Tab: String, CaseIterable {
    case home = "War"
    case news = "News"
    case game = "Game"
    
    var systemImage: String? {
        switch self {
        case .home:
            return "globe.americas.fill"
        case .game:
            return "scope"
        case .news:
            return "newspaper.fill"
        }
    }
}
