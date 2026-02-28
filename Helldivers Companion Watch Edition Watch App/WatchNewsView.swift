//
//  WatchNewsView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

@available(watchOS 10.0, *)
struct WatchNewsView: View {
    
    @State var feedModel = NewsFeedModel()
    @Environment(NavigationPather.self) var navPather
    @Environment(PlanetsDataModel.self) var viewModel
    
    
    var body: some View {
        @Bindable var navPather = navPather
        
        NavigationStack(path: $navPather.navigationPath) {
            TabView {
           
                if feedModel.news.isEmpty {
                    Spacer(minLength: 220)
                    DualRingSpinner()
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
                    Text("STROHMANN NEWS").textCase(.uppercase)  .font(Font.custom("FSSinclair", size: 18)).bold()
                }
                
            }
            
        }.onAppear {
            feedModel.startUpdating(viewModel.enableLocalization)
        }.onDisappear {
            feedModel.stopUpdating()
        }
        
        
        
        
    }
}
