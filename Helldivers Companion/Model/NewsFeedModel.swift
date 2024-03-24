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
    
    func fetchNewsFeed(completion: @escaping ([NewsFeed]) -> Void) {
          let feedURLString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/feed/news.json"
          guard let feedURL = URL(string: feedURLString) else {
              print("Bad URL")
              return
          }
        
        URLSession.shared.dataTask(with: feedURL){ [weak self] data, response, error in
            
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
    
    // fetch news feed every 5 min
    func startUpdating() {
           timer?.invalidate()
           
        
        fetchNewsFeed { _ in
            print("fetched news feed")
        }
           
           timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
               
               
               self?.fetchNewsFeed { _ in
                   print("fetched news feed")
               }
               
               
           }
       }


    
    
}
