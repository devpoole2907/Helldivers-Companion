//
//  AlertView.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

struct AlertView: View {
    
    var alert: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("helldiverIcon").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                Text("ALERT").foregroundStyle(Color.yellow)
                    .font(Font.custom("FSSinclair-Bold", size: largeFont))
            }
            
            Text(alert) .font(Font.custom("FSSinclair-Bold", size: mediumFont))
          
        } .padding() .frame(maxWidth: .infinity)
            .background {
            Color.black
        }
        
       
        .border(Color.white)
        .padding(4)
        .border(Color.gray)
    }
}

#Preview {
    AlertView()
}
