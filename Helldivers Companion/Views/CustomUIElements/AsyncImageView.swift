//
//  AsyncImageView.swift
//  Helldivers Companion
//
//  Created by James Poole on 22/07/2024.
//
import SwiftUI
import UIKit

struct AsyncImageView: View {
    
    let imageUrl: String
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                DualRingSpinner()
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                EmptyView()
            }
        }
   
        .task {
            await fetchImage()
        }
    }
    
    private func fetchImage() async {
           guard let url = URL(string: imageUrl) else {
               print("Invalid URL")
               isLoading = false
               return
           }
           
           let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
           let imageCacheURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
           
           if FileManager.default.fileExists(atPath: imageCacheURL.path) {
               if let cachedImage = UIImage(contentsOfFile: imageCacheURL.path) {
                   image = cachedImage
                   isLoading = false
                   return
               }
           }
           
           do {
               let (data, _) = try await URLSession.shared.data(from: url)
               try data.write(to: imageCacheURL)
               if let fetchedImage = UIImage(data: data) {
                   image = fetchedImage
               }
           } catch {
               print("Failed to fetch image: \(error)")
           }
           isLoading = false
       }
}
