//
//  RootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var notificationManager = NotificationManager()
    
    @StateObject var viewModel = PlanetsViewModel()
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
        ZStack(alignment: .bottom){
            TabView(selection: $viewModel.currentTab) {
                
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
        
        .sheet(isPresented: $viewModel.showOrders) {
            
            ordersSheet
            
            
                .presentationDetents([.fraction(0.65), .fraction(0.8), .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.thinMaterial)
            
        }
        
        .onAppear {
            
            viewModel.startUpdating()

        }
            
#if os(iOS)
            if viewModel.currentTab != .game {
                majorOrderButton.padding(.bottom, 85)
            }
        
                
                #endif
        }
        
    }
    
    var majorOrderButton: some View {
        
        Button(action: {
            viewModel.showOrders.toggle()
        }){
            Text("Major Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                .font(Font.custom("FS Sinclair", size: 20))
        }.padding()
        
            .background {
                Color.black.opacity(0.7)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
            .padding()
        

        
    }
    
    var ordersSheet: some View {
        
        NavigationStack {
            ScrollView {
                OrderView().environmentObject(viewModel).padding(.horizontal)

            Spacer()
            
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                 
                    ZStack(alignment: .leading) {
                        Image("MajorOrdersBanner").resizable()
                            .frame(width: getRect().width + 50, height: 60).ignoresSafeArea()
                            .offset(CGSize(width: 0, height: 0))
                            .border(Color.white, width: 2)
                            .padding(.bottom)
                            .opacity(0.8)
                          
                        
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            Image(systemName: "scope").bold()
                           
                            Text("MAJOR ORDER").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 24))
                                    
                        }.padding(.leading, 70)
                    }
                    
                
                        
                }
            }
            #endif
            
        }.scrollContentBackground(.hidden)
     
            .toolbarBackground(.hidden, for: .navigationBar)
            
          
            
            .navigationBarTitleDisplayMode(.inline)
        }
        
      

        
        
    }
    
    var tabButtons: some View {
        VStack(spacing: 0){
            HStack(spacing: 0) {
                TabButton(tab: .home, action: {viewModel.currentTab = .home})
                TabButton(tab: .news, action: {viewModel.currentTab = .news})
                TabButton(tab: .game, action: {viewModel.currentTab = .game})
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
                        .foregroundColor(viewModel.currentTab == tab ? .accentColor : .gray)
                        .padding()
                    
                    
                    
                    
                }
                
                Text(tab.rawValue).textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 20))
                    .dynamicTypeSize(.medium ... .large)
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




