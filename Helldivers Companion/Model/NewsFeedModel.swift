//
//  NewsFeedModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 19/03/2024.
//

import Foundation
import Algorithms
import SwiftUI

class NewsFeedModel: ObservableObject {
    
    @Published var news: [NewsFeed] = []
    private var timer: Timer?
    
    func fetchNewsFeed(config: RemoteConfigDetails?, _ enableLocalization: Bool, completion: @escaping ([NewsFeed]) -> Void) {
        
        
        
        
        let feedURLString = "\(config?.apiAddress ?? "https://api.helldivers2.dev/raw/api/")raw/api/NewsFeed/801?maxLimit=1024"
        
        guard let url = URL(string: feedURLString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("WarMonitoriOS/3.1", forHTTPHeaderField: "X-Super-Client")
         request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Application-Contact")
         request.addValue("james@pooledigital.com", forHTTPHeaderField: "X-Super-Contact")
        
        request.addValue(enableLocalization ? apiSupportedLanguage : "en-US", forHTTPHeaderField: "Accept-Language")
       
        
        
        URLSession.shared.dataTask(with: request){ [weak self] data, response, error in
            
            guard let feedData = data else {
                completion([])
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var newsFeed = try decoder.decode([NewsFeed].self, from: feedData)
                DispatchQueue.main.async {
    
                    newsFeed.sort { $0.id > $1.id }
                    // uniqued in case dupes
                    let newsItems = Array(newsFeed.uniqued())
                    withAnimation(.bouncy)  {
                        self?.news = newsItems
                    }
                    completion(newsItems)
                }
                
            } catch {
                print("Error fetching news feed: \(error)")
                completion([])
            }
            
            
        }.resume()

      }
    
    // fetch news feed every 1 min
    func startUpdating(_ enableLocalization: Bool) {
        timer?.invalidate()
        
        PlanetsViewModel().fetchConfig { config in
            self.fetchNewsFeed(config: config, enableLocalization) { _ in
                print("fetched news feed")
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                
                
                self?.fetchNewsFeed(config: config, enableLocalization) { _ in
                    print("fetched news feed")
                }
                
                
            }
        }
        
    }
    
    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }


    
    
}
