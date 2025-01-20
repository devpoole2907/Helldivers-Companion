//
//  CentrePopup.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI
import MijickPopupView

struct OrdersPopup: CentrePopup {
    
    @ObservedObject var viewModel: PlanetsDataModel
    var ordersType: OrderType = .major
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup.horizontalPadding(28)
            .backgroundColour(Color.clear)
            .tapOutsideToDismiss(true)
            .cornerRadius(0)
            
    }
    
    var ordersTitle: String {
        ordersType == .major ? "MAJOR ORDER" : "PERSONAL ORDER"
    }
    
    func createContent() -> some View {
        
        ZStack(alignment: .top) {
            
            if ordersType == .major {
                OrderView().environmentObject(viewModel)
                
                    .offset(CGSize(width: 7, height: 0))
                
            } else {
                PersonalOrderView().environmentObject(viewModel)
                    .offset(CGSize(width: 7, height: 0))
            }
            
            Image("MajorOrdersBanner").resizable()
#if os(iOS)
                .frame(width: isIpad ? 600 : UIScreen.main.bounds.width - 5, height: 45)
#endif
                .offset(CGSize(width: 0, height: -4))
           //     .clipShape(Rectangle())
            //   .border(Color.white, width: 2)
            // .padding(.bottom)
                //.opacity(0.8)
            
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Image(systemName: ordersType == .major ? "scope" : "checkmark.circle").bold()
                
                Text(ordersTitle).textCase(.uppercase) .font(Font.custom("FSSinclair", size: 24)).bold()
                
            }.padding(.top, 5)
            
                /*HStack {
                Spacer()
                
                Button(action: dismiss){
                    Image(systemName: "xmark")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.white)
                    
                
                      
                }
                .padding(5)
                .background(
                    ZStack {
                        Color.black
                        AngledLinesShape()
                            .stroke(lineWidth: 3)
                            .foregroundColor(.white)
                            .opacity(0.4)
                            .clipped()
                        
                    }
                )
                
                .border(Color.white, width: 4)
                
            }.padding(.trailing)
                .padding(.bottom, 40)*/
            
            
        }    .offset(CGSize(width: -7, height: 0))
        
        
        
          
    }
    
    
    
    
}

