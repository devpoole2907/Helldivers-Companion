//
//  NewsItemView.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/03/2024.
//

import SwiftUI

struct NewsItemView: View {
    
    var newsMessage: String = "Terminids! Automatons! EVERYWHERE!!??!!"
    
    var body: some View {
        
        VStack {
            Text(newsMessage)
        }
        
        
        
    }
    
    
}

#Preview {
    NewsItemView()
}
