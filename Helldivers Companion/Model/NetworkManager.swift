//
//  NetworkManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 17/07/2024.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchData<T: Decodable>(from urlString: String, headers: [String: String]? = nil) async throws -> T {
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            
            if let headers = headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(T.self, from: data)
        }
    
    func fetchFileList(from urlString: String) async throws -> [GitHubFile] {
           let apiToken = ProcessInfo.processInfo.environment["GITHUB_API_KEY"]
         
           
           guard let url = URL(string: urlString) else {
               throw URLError(.badURL)
           }
           
           var request = URLRequest(url: url)
        if let apiToken = apiToken {
            request.addValue("token \(apiToken)", forHTTPHeaderField: "Authorization")
        }
           
           let (data, _) = try await URLSession.shared.data(for: request)
           let decoder = JSONDecoder()
           decoder.keyDecodingStrategy = .convertFromSnakeCase
           return try decoder.decode([GitHubFile].self, from: data)
       }
       
       func fetchFileData<T: Decodable>(from urlString: String) async throws -> T {
           return try await fetchData(from: urlString)
       }
    
}
