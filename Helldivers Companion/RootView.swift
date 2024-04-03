//
//  RootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI
import MijickPopupView

struct RootView: View {
    
    @StateObject private var notificationManager = NotificationManager()
    
    @StateObject var viewModel = PlanetsViewModel()
    
    @StateObject var purchaseManager = StoreManager()
    
    @StateObject var contentNavPather = NavigationPather()
    
    @StateObject var statsNavPather = NavigationPather()
    
    @StateObject var newsNavPather = NavigationPather()
    
    @State var showMajorOrderButton: Bool = true
    
    // use func to change state of major order bool so it can be animated
    private func updateMajorOrderButtonVisibility() {
        withAnimation(.bouncy) {
                showMajorOrderButton = (viewModel.currentTab == .home && contentNavPather.navigationPath.isEmpty) || viewModel.currentTab == .news
            }
        }
    
    init(){
        // preload game sounds, mainly for slow watches but for ios itll load the buttons sound
        SoundPoolManager.shared.preloadAllSounds {
            
        }
    }
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
        ZStack(alignment: .bottom){
            TabView(selection: $viewModel.currentTab) {
                
                ContentView().environmentObject(viewModel).environmentObject(purchaseManager).environmentObject(contentNavPather)
                    .tag(Tab.home)
                
                    .toolbarBackground(.hidden, for: .tabBar)
                
                    .task {
                        await notificationManager.request()
                    }
                
              
                
                GalaxyStatsView().environmentObject(viewModel).environmentObject(purchaseManager).environmentObject(statsNavPather)
                    .tag(Tab.stats)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                NewsView().environmentObject(purchaseManager).environmentObject(newsNavPather).environmentObject(viewModel)
                    .tag(Tab.news)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                GameView().environmentObject(purchaseManager)
                    .tag(Tab.game)
                    .toolbarBackground(.hidden, for: .tabBar)
                
              
                
              
                
                
                
                
            }
            tabButtons
            
            

            
            
        }.task {
            await notificationManager.getAuthStatus()
        }
            
        .ignoresSafeArea(.keyboard)
            
            // deeplink from planet widget to the view of the planet
        .onOpenURL { url in
            
            if url.scheme == "helldiverscompanion"  {
                
                if let selectedPlanet = viewModel.allPlanetStatuses.first(where: { $0.planet.name == url.host }) {
                    
                    if viewModel.currentTab == .home {
                        if !contentNavPather.navigationPath.isEmpty {
                            contentNavPather.navigationPath.removeLast() // remove anything if somethings on the stack already
                        }
                        contentNavPather.navigationPath.append(selectedPlanet)
                    } else if viewModel.currentTab == .stats {
                        
                        if !statsNavPather.navigationPath.isEmpty {
                            statsNavPather.navigationPath.removeLast()
                        }
                        statsNavPather.navigationPath.append(selectedPlanet)
                        
                    }
                    
                    else {
                        // change tab to home, nav to the planet
                        viewModel.currentTab = .home
                        contentNavPather.navigationPath.append(selectedPlanet)
                    }
                } else if url.host == "orders" {
                    
                    CentrePopup_MoreFeatures(viewModel: viewModel)
                    
                                .showAndStack()
                    
                } else if url.host == "news" {
                    
                    viewModel.currentTab = .news
                    
                }
                
                
                
                
                
            }
            
            
        }
            
        .onChange(of: viewModel.currentTab) { _ in
                        updateMajorOrderButtonVisibility()
                    }
                    .onChange(of: contentNavPather.navigationPath) { _ in
                        updateMajorOrderButtonVisibility()
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
            if showMajorOrderButton {
                majorOrderButton.padding(.bottom, 85) 
                    .transition(.opacity)
            }
        
                
                #endif
        }
        
       /* .fullScreenCover(isPresented: $purchaseManager.showTips) {
            NavigationStack {
                // scrollview declared seperately because tip jar view is in about view on watchOS which contains scrollview already
                ScrollView {
                TipJarView()
                }
                    #if os(iOS)
                    .background {
                        Image("helldivers2planet").resizable().aspectRatio(contentMode: .fill).offset(CGSize(width: 400, height: 0)).blur(radius: 20.0).ignoresSafeArea()
                    }
                    #endif
            }
            
        }*/
        
       
        
    }
    
    var majorOrderButton: some View {
        
        Button(action: {
            
            CentrePopup_MoreFeatures(viewModel: viewModel)
            
                        .showAndStack()
            
            
        }){
            VStack(alignment: .trailing, spacing: 2){
                Text("Major Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                    .font(Font.custom("FS Sinclair", size: 20))
                
                if let timeRemaining = viewModel.majorOrder?.expiresIn {
                    MajorOrderTimeView(timeRemaining: timeRemaining, isMini: true)
                }
            }
            
            
        }.padding()
        
            .background {
                Color.black.opacity(0.8)
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
                TabButton(tab: .home, action: {
                    
                    
                    // remove all items on nav stack, pop to root if button pressed already in this tab
                    if viewModel.currentTab == .home {
                        
                        // if scroll position is greater than 0, and the nav path is empty (we're not in a subview) scroll to top
                        if let scrollPos = contentNavPather.scrollPosition, scrollPos > 0, contentNavPather.navigationPath.isEmpty {
                            withAnimation(.bouncy) {
                                contentNavPather.scrollPosition = 0
                            }
                        } else {
                            
                            // otherwise pop to root
                            
                            contentNavPather.popToRoot()
                            
                        }
                    } else {
                        // otherwise change tab to home, we must have been in another tab
                        viewModel.currentTab = .home
                    }
                    
                    
                })
          
                TabButton(tab: .stats, action: {
                    
                    // remove all items on nav stack, pop to root if button pressed already in this tab
                    if viewModel.currentTab == .stats {
                        
                        // if scroll position is greater than 0, and the nav path is empty (we're not in a subview) scroll to top
                        if let scrollPos = statsNavPather.scrollPosition, scrollPos > 0, statsNavPather.navigationPath.isEmpty {
                            withAnimation(.bouncy) {
                                statsNavPather.scrollPosition = 0
                            }
                        } else {
                            
                            // otherwise pop to root
                            
                            statsNavPather.popToRoot()
                            
                        }
                    } else {
                        // otherwise change tab to stats, we must have been in another tab
                        viewModel.currentTab = .stats
                    }
                    
                    
                })
                TabButton(tab: .news, action: {
                    
                    if viewModel.currentTab == .news {
                        
                        // if scroll position is greater than 0, and the nav path is empty (we're not in a subview) scroll to top
                        if let scrollPos = newsNavPather.scrollPosition, scrollPos > 0, newsNavPather.navigationPath.isEmpty {
                            withAnimation(.bouncy) {
                                newsNavPather.scrollPosition = 0
                            }
                        } else {
                            
                            // otherwise pop to root
                            
                            newsNavPather.popToRoot()
                            
                        }
                    } else {
                        // otherwise change tab to stats, we must have been in another tab
                        viewModel.currentTab = .news
                    }
                    
                    
                })
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
                        .frame(width: 26, height: 26)
                        .foregroundColor(viewModel.currentTab == tab ? .accentColor : .gray)
                        .padding()
 
                }
                
                Text(tab.rawValue).textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 16))
                    .dynamicTypeSize(.medium ... .large)
                    .foregroundColor(viewModel.currentTab == tab ? .accentColor : .gray)
            }.padding(.horizontal)
                .padding(.bottom, 10)
                .frame(width: 80)
                .background {
                    Color.black.opacity(0.8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } .frame(maxWidth: .infinity)
        
        
    }
}

#Preview {
    RootView()
}




