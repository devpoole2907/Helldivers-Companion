//
//  NewsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import SwiftUI

struct NewsView: View {
    
    @StateObject var feedModel = NewsFeedModel()
    @EnvironmentObject var navPather: NavigationPather
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    var body: some View {
        
        
        NavigationStack(path: $navPather.navigationPath) {
            ScrollView {
                
                if feedModel.news.isEmpty {
                    Spacer(minLength: 220)
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(feedModel.news, id: \.id) { news in
                            
                            if let message = news.message, !message.isEmpty, message != "void msg", let published = news.published {
                                NewsItemView(newsTitle: news.title, newsMessage: message, published: published, configData: viewModel.configData)
                                    .padding(.horizontal)
                                // set id as 0 if first news item to programmatic scroll to top
                                    .id(feedModel.news.first == news ? 0 : news.id)
                            }
                            
                        }
                      
                    }.padding()
#if os(iOS)
                        .scrollTargetLayoutiOS17()
#endif
                }
                
                Text("Pull to Refresh").textCase(.uppercase)
                    .opacity(0.5)
                    .foregroundStyle(.gray)
                    .font(Font.custom("FS Sinclair Bold", size: smallFont))
                    .padding()
                
                
                Spacer(minLength: 30)
                
                
            }.refreshable {
                feedModel.stopUpdating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    feedModel.startUpdating()
                }
            }
#if os(iOS)
            
            .scrollPositioniOS17($navPather.scrollPosition)
#endif
            .onChange(of: navPather.scrollPosition) { value in
                
                print("scroll pos is \(value)")
                
            }
            
            .scrollContentBackground(.hidden)
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
                                .font(Font.custom("FS Sinclair Bold", size: 24))
                            
                        }
                        
                 
                        
                    }
                
                
                
            }
#elseif os(watchOS)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("STROHMANN NEWS").textCase(.uppercase)  .font(Font.custom("FS Sinclair Bold", size: 18))
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
