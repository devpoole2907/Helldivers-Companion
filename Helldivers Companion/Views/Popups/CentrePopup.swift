//
//  CentrePopup.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI
import MijickPopupView

struct CentrePopup_MoreFeatures: CentrePopup {
    
    @ObservedObject var viewModel: PlanetsViewModel
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup.horizontalPadding(28)
            .backgroundColour(Color.black)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
            
    }
    func createContent() -> some View {
        
        OrderView().environmentObject(viewModel)
        
          
    }
    
    
    
    
}

