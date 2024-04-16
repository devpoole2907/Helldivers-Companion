//
//  WatchNewsView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

struct WatchNewsView: View {
    
    @StateObject var feedModel = NewsFeedModel()
    @EnvironmentObject var navPather: NavigationPather
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    
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
                            
                            
                            if let message = news.message, !message.isEmpty, let published = news.published {
                                NewsItemView(newsTitle: news.title, newsMessage: message, published: published, configData: viewModel.configData)
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
                    Text("STROHMANN NEWS").textCase(.uppercase)  .font(Font.custom("FS Sinclair Bold", size: 18))
                }
                
            }
            
        }.onAppear {
            feedModel.startUpdating(viewModel.enableLocalization)
        }
        
        
        
        
    }
}


#Preview {
    WatchNewsView()
}
