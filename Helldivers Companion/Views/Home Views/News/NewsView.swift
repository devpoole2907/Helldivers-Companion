//
//  NewsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import SwiftUI
#if os(iOS)
import SwiftUIIntrospect
#endif
@available(watchOS 9.0, *)
struct NewsView: View {
    
    @StateObject var feedModel = NewsFeedModel()
    @EnvironmentObject var navPather: NavigationPather
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var dbModel: DatabaseModel
    
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
        SuperStoreList().environmentObject(dbModel)
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
            
        }.onAppear {
            feedModel.startUpdating(viewModel.enableLocalization)
        }
        
        #if os(iOS)
        .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) { controller in
            print("I am introspecting!")

            DispatchQueue.main.async {
                let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
                let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
                
                // default to sf system font
                let largeFont = UIFont(name: "FSSinclair-Bold", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
                let inlineFont = UIFont(name: "FSSinclair-Bold", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)
                
                
                let largeAttributes: [NSAttributedString.Key: Any] = [
                    .font: largeFont
                ]
                
                let inlineAttributes: [NSAttributedString.Key: Any] = [
                    .font: inlineFont
                ]
                
                controller.navigationBar.titleTextAttributes = inlineAttributes
                
                controller.navigationBar.largeTitleTextAttributes = largeAttributes
                
            }
       
        }
        #endif
        
        
        
        
    }
}

