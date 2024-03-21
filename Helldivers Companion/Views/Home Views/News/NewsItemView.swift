//
//  NewsItemView.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/03/2024.
//

import SwiftUI

struct NewsItemView: View {
    
    var newsTitle: String? = nil
    var newsMessage: String = "Terminids! Automatons! EVERYWHERE!!??!!"
    
    var body: some View {

            VStack(alignment: .leading, spacing: 4) {
                
                if let title = newsTitle {
                    Text(title).textCase(.uppercase) .font(Font.custom("FS Sinclair", size: mediumFont)).foregroundStyle(Color.yellow)
                }
                
                Text(newsMessage).font(Font.custom("FS Sinclair", size: mediumFont))
                
            }
            .padding()
            .frame(maxWidth: .infinity)
                .background {
                    Color.black
                }.border(Color.blue.opacity(0.4), width: 6)
   
        
    }
    
    
}

#Preview {
    NewsItemView()
}
