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
    @Binding var showPlanetNames: Bool
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup.horizontalPadding(28)
            .backgroundColour(Color.clear)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
        
    }
    func createContent() -> some View {
        
        
        VStack(spacing: 12) {
            
     
                
                
                
            Text("MAP SETTINGS").font(Font.custom("FSSinclair", size: 28)).bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.top, 3)
                    .angledLinesBackground()
                    .padding(.top)
            
            
            VStack(spacing: 6) {
                Text("SUPPLY LINES").font(Font.custom("FSSinclair", size: 24))
                    .foregroundStyle(.gray)
                
                CustomTogglePicker(selection: $showSupplyLines)
                    .frame(height: 30)
                
                    .frame(maxWidth: 200)
            }
            
            VStack(spacing: 6) {
                Text("ALL PLANETS").font(Font.custom("FSSinclair", size: 24))
                    .foregroundStyle(.gray)
                
                CustomTogglePicker(selection: $showAllPlanets)
                    .frame(height: 30)
                
                    .frame(maxWidth: 200)
                
            }
            
            
            VStack(spacing: 6) {
                Text("PLANET NAMES").font(Font.custom("FSSinclair", size: 24))
                    .foregroundStyle(.gray)
                
                CustomTogglePicker(selection: $showPlanetNames)
                    .frame(height: 30)
                
                    .frame(maxWidth: 200)
                
                Text("Several Super Earth scientists were prosecuted for the planet name feature due to its democracy shattering performance impact.")
                    .font(Font.custom("FSSinclair", size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding()
                
                
            }.padding(.bottom, 25)
            
            
        }.frame(minWidth: 260)
        
            .background {
                Color.black
            }
        
        .helldiversBorder()
        
        
    }
    
    
}

#if DEBUG
#Preview {
    @Previewable @State var supplyLines = true
    @Previewable @State var allPlanets = false
    @Previewable @State var planetNames = false
    MapSettingsPopup(
        showSupplyLines: $supplyLines,
        showAllPlanets: $allPlanets,
        showPlanetNames: $planetNames
    ).createContent()
        .background(.black)
}
#endif
