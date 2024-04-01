//
//  WatchNewsView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

struct WatchNewsView: View {
    
    @StateObject var feedModel = NewsFeedModel()
    @EnvironmentObject var purchaseManager: StoreManager
    @EnvironmentObject var navPather: NavigationPather
    
    var body: some View {
        
        
        NavigationStack(path: $navPather.navigationPath) {
            TabView {
           
                if feedModel.news.isEmpty {
                    Spacer(minLength: 220)
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    ForEach(feedModel.news, id: \.id) { news in
                        
                        ScrollView {
                            
                        LazyVStack(spacing: 15) {
                            
                            
                            if let message = news.message, !message.isEmpty {
                                NewsItemView(newsTitle: news.title, newsMessage: message)
                                  //  .padding(.horizontal)
                            
                            }
                            
                            
                            
                        }.padding()
                    } .scrollContentBackground(.hidden)
                }
                }
                
                
            
            
            
           
            
            }.tabViewStyle(.verticalPage)
            
        
            
            .navigationBarTitleDisplayMode(.inline)
            
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("STROHMANN NEWS").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 18))
                }
                
            }
            
        }.onAppear {
            feedModel.startUpdating()
        }
        
        
        
        
    }
}


#Preview {
    WatchNewsView()
}
