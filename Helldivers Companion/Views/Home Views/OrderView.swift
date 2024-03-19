//
//  OrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct OrderView: View {
    
    var majorOrderString: String = "Stand by for further orders from Super Earth High Command."
    
    var body: some View {
        
   
            VStack {
                
                Text(majorOrderString).font(Font.custom("FS Sinclair", size: 18))
                    .foregroundStyle(Color.cyan)
                
            }  .frame(maxWidth: .infinity) .padding()  .background {
                Color.black
            }
          //  .padding(.horizontal)
          
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
     
        
        
    }
}

#Preview {
    OrderView()
}
