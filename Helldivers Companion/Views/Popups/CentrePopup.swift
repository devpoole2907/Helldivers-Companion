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
            .backgroundColour(Color.clear)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
            
    }
    func createContent() -> some View {
        
        ZStack(alignment: .top) {
            OrderView().environmentObject(viewModel)
                .frame(maxWidth: UIScreen.main.bounds.width - 35)
                .offset(CGSize(width: 7, height: 0))
            
            Image("MajorOrdersBanner").resizable()
#if os(iOS)
                .frame(width: UIScreen.main.bounds.width - 5, height: 45)
#endif
                .offset(CGSize(width: 0, height: -4))
           //     .clipShape(Rectangle())
            //   .border(Color.white, width: 2)
            // .padding(.bottom)
                //.opacity(0.8)
            
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Image(systemName: "scope").bold()
                
                Text("MAJOR ORDER").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 24))
                
            }.padding(.top, 5)
            
          /*  HStack {
                Spacer()
                
                Button(action: dismiss){
                    Image(systemName: "xmark.square.fill")
                        .font(.largeTitle)
                        .symbolRenderingMode(.monochrome)
                        
                        .tint(.black)
                    
                
                      
                }
                
            }.padding(.trailing)
                .padding(.bottom, 40)
            */
            
        }    .offset(CGSize(width: -7, height: 0))
        
          
    }
    
    
    
    
}

