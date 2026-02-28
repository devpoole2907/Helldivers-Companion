//
//  RootView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI
import MijickPopupView
import Haptics

struct RootView: View {
    
    @Environment(\.accessibilityShowButtonShapes) var buttonShapesEnabled // to reduce tab bar padding if button shapes active
    @Environment(\.scenePhase) var scenePhase
    
    @State private var notificationManager = NotificationManager()
    
    @State private var newsModel = NewsFeedModel()
    
    @State var viewModel = PlanetsDataModel()
    
    @State var dbModel = DatabaseModel()
    
    @State var contentNavPather = NavigationPather()
    
    @State var statsNavPather = NavigationPather()
    
    @State var newsNavPather = NavigationPather()
    
    @State var mapNavPather = NavigationPather()
    
    @State var settingsNavPather = NavigationPather()
    
    @State var showMajorOrderButton: Bool = true
    
    @State var showNotificationOptions: Bool = false
    
    @AppStorage("notifOptionsShown") private var notifOptionsShown = false
    
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
        @Bindable var viewModel = viewModel
        @Bindable var contentNavPather = contentNavPather
        @Bindable var statsNavPather = statsNavPather
        @Bindable var newsNavPather = newsNavPather
        @Bindable var mapNavPather = mapNavPather
        ZStack(alignment: .bottomTrailing) {
        ZStack(alignment: .bottom){
            TabView(selection: $viewModel.currentTab) {
                
                ContentView().environment(viewModel).environment(contentNavPather).environment(dbModel)
                    .tag(Tab.home)
                
                    .task {
                        await notificationManager.request()
                    }
                
                GalaxyMapRootView().environment(viewModel).environment(mapNavPather)
                    .tag(Tab.map)
              
                GameView().environment(viewModel)
                    .tag(Tab.game)
                
                GalaxyStatsView().environment(viewModel).environment(statsNavPather).environment(dbModel)
                    .tag(Tab.stats)
                
              
                
                NewsView().environment(newsNavPather).environment(viewModel).environment(dbModel).environment(newsModel)
                    .tag(Tab.news)
                
             
                
              
                
              
                
                
                
                
            }
            tabButtons
            
            

            
            
        }.task {
            await notificationManager.getAuthStatus()
        }
            
        .ignoresSafeArea()
        .ignoresSafeArea(.keyboard)
            
        .onReceive(viewModel.popMapToRoot) { _ in
                   // switch to map tab
            viewModel.currentTab  = .map
                    // wait for tab switch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        // pop map to root
                        mapNavPather.popToRoot()
                    }
                }
            
        .onReceive(viewModel.popToWarBonds) { _ in
                   // switch to map tab
            viewModel.currentTab  = .stats
                    // wait for tab switch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        // pop map to root
                        statsNavPather.navigationPath.append(DatabasePage.warbondsList)
                    }
                }
            
            // deeplink from planet widget to the view of the planet
        .onOpenURL { url in
            
            if url.scheme == "helldiverscompanion"  {
                
                if let selectedPlanet = viewModel.updatedPlanets.first(where: { $0.name == url.host }) {
                    
                    if viewModel.currentTab == .home {
                        if !contentNavPather.navigationPath.isEmpty {
                            contentNavPather.navigationPath.removeLast() // remove anything if somethings on the stack already
                        }
                        contentNavPather.navigationPath.append(selectedPlanet.index)
                    } else if viewModel.currentTab == .stats {
                        
                        if !statsNavPather.navigationPath.isEmpty {
                            statsNavPather.navigationPath.removeLast()
                        }
                        statsNavPather.navigationPath.append(selectedPlanet.index)
                        
                    } else {
                        // change tab to home, nav to the planet
                        viewModel.currentTab = .home
                        contentNavPather.navigationPath.append(selectedPlanet.index)
                    }
                } else if url.host == "orders" {
                    // wait 2 seconds to fetch orders info
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        
                        OrdersPopup(viewModel: viewModel)
                        
                            .showAndStack()
                        
                    }
                    
                } else if url.host == "news" {
                    
                    viewModel.currentTab = .news
                    
                }
                
                
                
                
                
            }
            
            
        }
            
        .onChange(of: viewModel.currentTab) {
                        updateMajorOrderButtonVisibility()
                    }
                    .onChange(of: contentNavPather.navigationPath) {
                        updateMajorOrderButtonVisibility()
                    }
        
        .onAppear {
            
            viewModel.startUpdating()
            newsModel.startUpdating(viewModel.enableLocalization)

        }
            
#if os(iOS)
            if showMajorOrderButton {
                VStack(alignment: .trailing, spacing: 10) {
                    
                    
                    
                    majorOrderButton
                    // gone now :(
                  /*  personalOrderButton
                    superStoreButton */
                    
                }.padding(.bottom, 60)
                    .padding(.trailing, 10)
                    .transition(.opacity)
                
            }
        
                
                #endif
        }.hapticFeedback(.selection, trigger: contentNavPather.navigationPath)
            .hapticFeedback(.selection, trigger: statsNavPather.navigationPath)
            .hapticFeedback(.selection, trigger: mapNavPather.navigationPath)
  
            .onAppear {
                dbModel.startUpdating()
#if os(iOS)
                if !notifOptionsShown {
                    showNotificationOptions = true
                    notifOptionsShown = true
                }
                #endif
            }
        
            .sheet(isPresented: $showNotificationOptions) {
                NotificationSettingsView()
            }
        
            .sheet(isPresented: $viewModel.showPlayerCount) {
                PlayerCountPieChart().environment(viewModel)
            }
       
        
    }
    
    var superStoreButton: some View {
        
        Button(action: {
            
                // append super store view to nav path
            
            if viewModel.currentTab == .home {
                contentNavPather.navigationPath.append(ContentViewPage.superStore)
            }
            
            
            if viewModel.currentTab == .news {
                newsNavPather.navigationPath.append(ContentViewPage.superStore)
            
            }
            
        }){
            HStack(spacing: 6){
     
                Image("superCredit").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .padding(.bottom, 1.8)
                     
                    
                    Text("Super Store").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                        .font(Font.custom("FSSinclair", size: 16))
                
                    if let expireDate = dbModel.storeRotation?.expireTime {
                        let timeRemaining = expireDate.timeIntervalSince(Date())
                        OrderTimeView(timeRemaining: Int64(timeRemaining), isMini: true)
                            .padding(.bottom, 2)
                    }
                    
                }
            
            
            
        }.padding(.horizontal)
            .padding(.vertical, 5)
            .frame(height: 40)
            .background(Material.thin)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
   
         //   .disabled(dbModel.storeRotation == nil)
        
        
        
    }
    
    var majorOrderButton: some View {
        
        Button(action: {
            
            OrdersPopup(viewModel: viewModel)
            
                        .showAndStack()
            
            
        }){
            HStack(spacing: 6){
                Text("Major Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                    .font(Font.custom("FSSinclair", size: 16))
                
                if let timeRemaining = viewModel.majorOrders.first?.expiresIn {
                    OrderTimeView(timeRemaining: timeRemaining, isMini: true)
                        .padding(.bottom, 2)
                }
            }
            
            
        }.padding(.horizontal)
            .padding(.vertical, 5)
            .frame(height: 40)
            .background(Material.thin)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
         
       

        
    }
    
    var personalOrderButton: some View {
        
        Button(action: {
            
            OrdersPopup(viewModel: viewModel, ordersType: .personal)
            
                        .showAndStack()
            
            
        }){
            HStack(spacing: 6){
                Text("Personal Order").textCase(.uppercase).tint(.white).fontWeight(.heavy)
                    .font(Font.custom("FSSinclair", size: 16))
                
                if let timeRemaining = viewModel.personalOrder?.expiresIn {
                    OrderTimeView(timeRemaining: timeRemaining, isMini: true)
                        .padding(.bottom, 2)
                }
            }
            
            
        }.padding(.horizontal)
            .padding(.vertical, 5)
            .frame(height: 40)
            .background(Material.thin)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
    }
    
    
    
    var tabButtons: some View {
        VStack(spacing: 0){
            HStack(spacing: -6) {
                tabButton(tab: .home, action: {
                    
                    
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
                
                tabButton(tab: .map, action: {
                    
                    if viewModel.currentTab == .map {
                        
                        mapNavPather.popToRoot()
                        
                    } else {
                        
                        viewModel.currentTab = .map
                        
                    }
                    
                })
                
                tabButton(tab: .game, action: {viewModel.currentTab = .game})
      
          
                tabButton(tab: .stats, action: {
                    
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
                tabButton(tab: .news, action: {
                    
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
                        
                        // and clear new items count
                        newsModel.markNewsAsSeen()
                    }
                    
                    
                }, badgeCount: newsModel.newItemsCount)
                
            
                
              
              
            }

            .padding(.bottom, (UIScreen.main.bounds.height) == 667 || (UIScreen.main.bounds.height) == 736 ? 0 : isIpad ? 8 : 26)
            .ignoresSafeArea(.keyboard)
        }.ignoresSafeArea(.keyboard)
        
    }
    
    @ViewBuilder
    func tabButton(tab: Tab, action: (() -> Void)? = nil, badgeCount: Int = 0) -> some View {
        
        let frameSize: CGFloat = (UIScreen.main.bounds.height) == 667 || (UIScreen.main.bounds.height) == 736 ? 20 : 23
        
        
        Button(action: {
            if let action = action {
                action()
            }
        }){
            
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    if let systemImage = tab.systemImage {
                        Image(systemName: systemImage)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: frameSize, height: frameSize)
                            .foregroundColor(viewModel.currentTab == tab ? .accentColor : .gray)
                        //   .padding()
                        
                    }
                    
                    Text(tab.rawValue).textCase(.uppercase)  .font(Font.custom("FSSinclair-Bold", size: 15))
                        .dynamicTypeSize(.medium ... .large)
                        .foregroundColor(viewModel.currentTab == tab ? .accentColor : .gray)
                    
                    
                }
                
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(Font.custom("FSSinclair", size: 12))
                        .foregroundStyle(.white)
                        .padding(5)
                        .padding(.top, 1)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
                
                
            }.padding(.horizontal, buttonShapesEnabled ? 0 : 10)
                .frame(width: buttonShapesEnabled ? 54 : 64)
           
              
             
        } .frame(maxWidth: .infinity)
            .shadow(radius: 3)
        
    }
}

#Preview {
    RootView()
}

public enum ContentViewPage: String, CaseIterable {
    
    case superStore = "Super Store"

}
