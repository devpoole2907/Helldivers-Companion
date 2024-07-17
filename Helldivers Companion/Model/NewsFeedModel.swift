//
//  NewsFeedModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import Foundation
import Algorithms
import SwiftUI

@MainActor
class NewsFeedModel: ObservableObject {
    
    @Published var news: [NewsFeed] = []
    private var timer: Timer?
    
    let netManager = NetworkManager.shared
    
    let planetsModel = PlanetsDataModel()
    
    func fetchNewsFeed(config: RemoteConfigDetails?, _ enableLocalization: Bool) async -> [NewsFeed] {
        
        let feedURLString = "\(config?.apiAddress ?? "https://api.helldivers2.dev/raw/api/")raw/api/NewsFeed/801?maxLimit=1024"
       
        let headers: [String: String] = [
            "X-Super-Client": "WarMonitoriOS/3.1",
            "X-Application-Contact": "james@pooledigital.com",
            "X-Super-Contact": "james@pooledigital.com",
            "Accept-Language": enableLocalization ? apiSupportedLanguage : ""
        ]
        
        do {
            var newsFeed: [NewsFeed] = try await netManager.fetchData(from: feedURLString, headers: headers)
            
            newsFeed.sort { $0.id > $1.id }
            // uniqued in case dupes
            let newsItems = Array(newsFeed.uniqued())
            
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
            
            guard let config = await planetsModel.fetchConfig() else {
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
                
                guard let config = await self.planetsModel.fetchConfig() else {
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
