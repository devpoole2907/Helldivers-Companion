//
//  TogglePickerPopup.swift
//  Helldivers Companion
//
//  Created by James Poole on 20/04/2024.
//

import SwiftUI
import MijickPopupView

struct TogglePickerPopup: CentrePopup {
    
    @Binding var selection: Bool
    let settingTitle: String
    let settingSubtitle: String
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup.horizontalPadding(28)
            .backgroundColour(Color.clear)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
        
    }
    func createContent() -> some View {
        
        
        VStack(spacing: 12) {
            
     
                
                
                
            Text(settingTitle.uppercased()).font(Font.custom("FSSinclair", size: 28)).bold()
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
                
                Text(settingSubtitle)
                .font(Font.custom("FSSinclair", size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                
                
                CustomTogglePicker(selection: $selection)
                    .frame(height: 30)
                
                    .frame(maxWidth: 200)
                
            }
            
            
        }.frame(minWidth: 260)
        
            .background {
                Color.black
            }
        
        .border(Color.white)
            .padding(4)
            .border(Color.gray)
        
        
    }
    
    
}





