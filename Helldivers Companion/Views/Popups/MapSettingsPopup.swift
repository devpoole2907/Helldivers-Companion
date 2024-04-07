//
//  MapSettingsPopup.swift
//  Helldivers Companion
//
//  Created by James Poole on 07/04/2024.
//

import SwiftUI
import MijickPopupView

struct MapSettingsPopup: CentrePopup {
    
    @Binding var showSupplyLines: Bool
    @Binding var showAllPlanets: Bool
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup.horizontalPadding(28)
            .backgroundColour(Color.clear)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
        
    }
    func createContent() -> some View {
        
        
        VStack(spacing: 12) {
            
     
                
                
                
                Text("MAP SETTINGS").font(Font.custom("FS Sinclair", size: 28))
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
                Text("SUPPLY LINES").font(Font.custom("FS Sinclair", size: 24))
                    .foregroundStyle(.gray)
                
                CustomTogglePicker(selection: $showSupplyLines)
                    .frame(height: 30)
                
                    .frame(maxWidth: 200)
            }
            
            VStack(spacing: 6) {
                Text("ALL PLANETS").font(Font.custom("FS Sinclair", size: 24))
                    .foregroundStyle(.gray)
                
                CustomTogglePicker(selection: $showAllPlanets)
                    .frame(height: 30)
                
                    .frame(maxWidth: 200)
                
            }.padding(.bottom, 25)
            
            
        }.frame(minWidth: 260)
        
            .background {
                Color.black
            }
        
        .border(Color.white)
            .padding(4)
            .border(Color.gray)
        
        
    }
    
    
}





