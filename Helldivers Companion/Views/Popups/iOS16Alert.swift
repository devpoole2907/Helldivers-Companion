//
//  iOS16Alert.swift
//  Helldivers Companion
//
//  Created by James Poole on 07/04/2024.
//

import SwiftUI
import MijickPopupView

struct iOS16AlertPopup: CentrePopup {
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup.horizontalPadding(28)
            .backgroundColour(Color.clear)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
        
    }
    func createContent() -> some View {
        
        
        VStack(spacing: 12) {
            
     
                
                
                
            Text("ALERT").font(Font.custom("FSSinclair", size: 28)).bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.top, 3)
                    .background(
                        AngledLinesShape()
                            .stroke(lineWidth: 3)
                            .foregroundColor(.white)
                            .opacity(0.2)
                            .clipped()
                    )
                    .padding(.top)
            
            
            VStack(spacing: 6) {
                Text("Zooming the galactic map has issues on iOS 16. If possible, it is highly suggested by Super Earth scientists to update your device to iOS 17 for a more enhanced experience. If iOS 17 is unavailable, try double tapping to zoom accurately instead.").font(Font.custom("FSSinclair", size: 18))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                    .padding()
                
            }.padding(.bottom, 20)
            
            
        }.frame(minWidth: 260)
        
            .background {
                Color.black
            }
        
        .border(Color.white)
            .padding(4)
            .border(Color.gray)
        
        
    }
    
    
}
