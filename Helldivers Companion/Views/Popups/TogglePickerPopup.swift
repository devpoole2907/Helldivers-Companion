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
                    .angledLinesBackground()
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
            .padding()
            .background {
                Color.black
            }
        
        .helldiversBorder()
        
        
    }
    
    
}

#if DEBUG
#Preview("Enabled") {
    @Previewable @State var selection = true
    TogglePickerPopup(
        selection: $selection,
        settingTitle: "Dark Mode",
        settingSubtitle: "Swap the app background for plain black."
    ).createContent()
        .background(.black)
}

#Preview("Disabled") {
    @Previewable @State var selection = false
    TogglePickerPopup(
        selection: $selection,
        settingTitle: "Illuminate UI",
        settingSubtitle: "Show Illuminate faction information and icons."
    ).createContent()
        .background(.black)
}
#endif
