//
//  NewsFeedModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import Foundation
import Algorithms
import SwiftUI

@MainActor @Observable
class NewsFeedModel {
    
    // for tab bar badge to indicate new news items
    @ObservationIgnored @AppStorage("newsCount") private var storedNewsCount: Int = 0
    
    var newItemsCount: Int = 0
    
    func markNewsAsSeen() {
        withAnimation {
            newItemsCount = 0
        }
    }
    
    var news: [NewsFeed] = []
    @ObservationIgnored private var timer: Timer?
    
    @ObservationIgnored let netManager = NetworkManager.shared
    
    @ObservationIgnored let apiService = WarAPIService()
    
    func fetchNewsFeed(config: RemoteConfigDetails?, _ enableLocalization: Bool) async -> [NewsFeed] {
        
        // let feedURLString = "\(config?.apiAddress ?? "https://api.helldivers2.dev/raw/api/")raw/api/NewsFeed/801?maxLimit=1024"
        let feedURLString = "https://api.live.prod.thehelldiversgame.com/api/NewsFeed/\(config?.season ?? "801")?maxEntries=1024"
    
        let headers: [String: String] = [
            "Accept-Language": enableLocalization ? apiSupportedLanguage : ""
        ]
        
        do {
            var newsFeed: [NewsFeed] = try await netManager.fetchData(from: feedURLString, headers: headers)
            
            newsFeed.sort { $0.id > $1.id }
            // uniqued in case dupes
            let newsItems = Array(newsFeed.uniqued())
            
            // compare count with stored count
            
            if newsItems.count > storedNewsCount {
                            let difference = newsItems.count - storedNewsCount
                            newItemsCount += difference // increment unseen count
                            storedNewsCount = newsItems.count
                        }
        
            return newsItems
            
        } catch {
            print("Error fetching news feed: \(error)")
            return []
        }

      }
    
    // fetch news feed every 1 min
    func startUpdating(_ enableLocalization: Bool) {
        timer?.invalidate()

        Task {
            
            guard let config = await apiService.fetchConfig() else {
                print("config failed to load")
                return
            }
            
            let newsItems = await fetchNewsFeed(config: config, enableLocalization)
            
            await MainActor.run {
                withAnimation(.bouncy)  {
                    self.news = newsItems
                }
            }
            
        }
        
        setupTimer(enableLocalization)
        
        
    }
    
    func setupTimer(_ enableLocalization: Bool) {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task {
                
                guard let config = await self.apiService.fetchConfig() else {
                    print("config failed to load")
                    return
                }
                
                let newsItems = await self.fetchNewsFeed(config: config, enableLocalization)
                
                await MainActor.run {
                    withAnimation(.bouncy)  {
                        self.news = newsItems
                    }
                }
                
            }
            
            
        }
        
        
        
    }
    
    
    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }


    
    
}
