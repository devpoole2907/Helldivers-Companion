//
//  NewsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import SwiftUI

struct NewsView: View {
    
    @Environment(NewsFeedModel.self) var feedModel
    @Environment(NavigationPather.self) var navPather
    @Environment(PlanetsDataModel.self) var viewModel
    @Environment(DatabaseModel.self) var dbModel
    
    var body: some View {
        @Bindable var navPather = navPather
        
        NavigationStack(path: $navPather.navigationPath) {
            ScrollView {
                
                if feedModel.news.isEmpty {
                    Spacer(minLength: 220)
                    DualRingSpinner()
                        .frame(maxWidth: .infinity)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(feedModel.news, id: \.id) { news in
                            
                            if let message = news.message, !message.isEmpty, message != "void msg", let published = news.published {
                                NewsItemView(newsTitle: news.title, newsMessage: message, published: published, configData: viewModel.configData, warTime: viewModel.warTime)
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
                    .font(Font.custom("FSSinclair-Bold", size: smallFont))
                    .padding()
                
                
                Spacer(minLength: 30)
                
                
            }.refreshable {
                feedModel.stopUpdating()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    feedModel.startUpdating(viewModel.enableLocalization)
                }
            }
#if os(iOS)
            
            .scrollPositioniOS17($navPather.scrollPosition)
#endif
            .onChange(of: navPather.scrollPosition) { value in
                
                print("scroll pos is \(value)")
                
            }
            
            .scrollContentBackground(.hidden)
            
            .navigationBarTitleDisplayMode(.inline)
            
#if os(iOS)
            .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
            
            
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            
                            Text("DISPATCH")
                                .font(Font.custom("FSSinclair", size: 24)).bold()
                            
                        }
                        
                 
                        
                    }
            
    .navigationDestination(for: ContentViewPage.self) { _ in
        SuperStoreList().environment(dbModel)
    }
                
            
  
        

                
                
            
#elseif os(watchOS)
            
            .toolbar {
                if #available(watchOS 10, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("DISPATCH").textCase(.uppercase)  .font(Font.custom("FSSinclair", size: 18)).bold()
                    }
                }
                
            }
            
#endif
            
        }
        
        #if os(iOS)
        .helldiversNavigationStyle()
        #endif
        
        
        
        
    }
}
