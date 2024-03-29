//
//  NewsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import SwiftUI

struct NewsView: View {
    
    @StateObject var feedModel = NewsFeedModel()
    @EnvironmentObject var purchaseManager: StoreManager
    
    var body: some View {
        
        
        NavigationStack {
            ScrollView {
                
                if feedModel.news.isEmpty {
                    Spacer(minLength: 220)
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(feedModel.news, id: \.self) { news in
                            
                            
                            
                            
                            if let message = news.message, !message.isEmpty {
                                NewsItemView(newsTitle: news.title, newsMessage: message)
                                    .padding(.horizontal)
                            }
                            
                            
                            
                        }
                        Spacer(minLength: 150)
                    }.padding()
                }
                
                
            }.scrollContentBackground(.hidden)
                .refreshable {
                    feedModel.fetchNewsFeed { _ in
                        
                        print("fetching news")
                        
                        
                    }
                }
            
                .navigationBarTitleDisplayMode(.inline)
            
#if os(iOS)
.background {
    Image("BackgroundImage").blur(radius: 5).ignoresSafeArea()
    
    
        .toolbar {
            ToolbarItem(placement: .principal) {
                
                Text("STROHMANN NEWS")
                    .font(Font.custom("FS Sinclair", size: 24))
                
            }
            
            
         /*   ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    purchaseManager.showTips.toggle()
                }){
                    Image(systemName: "cart.fill")
                }.foregroundStyle(.white)
                    .bold()
            }*/
            
        }
    
  
    
}
#elseif os(watchOS)
            
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Text("STROHMANN NEWS").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: 18))
    }
    
}
            
            #endif
            
        }.onAppear {
            feedModel.startUpdating()
        }
        

        
        
    }
}

#Preview {
    NewsView()
}
