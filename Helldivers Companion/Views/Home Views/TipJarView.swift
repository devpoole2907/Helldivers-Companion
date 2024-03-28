//
//  TipJarView.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    
    @ObservedObject var purchaseManager: StoreManager = StoreManager()
    
    var iconSize: CGFloat {
        
        #if os(watchOS)
            return 40
        #else
            return 160
        #endif
        
    }

    
    var body: some View {
        
        
        ScrollView {
        LazyVStack(alignment: .leading) {
            
            VStack(alignment: .center, spacing: 20) {
                Image("WarMonitorIcon").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .frame(maxWidth: .infinity)
                
                Text("Support the ongoing development of War Monitor!")
                    .font(Font.custom("FS Sinclair", size: largeFont))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
            }
            
            
            
            ForEach(purchaseManager.products, id: \.self) { product in
                
                ProductView(id: product.id)//.productIconBorder()
                    .productViewStyle(CustomProductStyle())
                
                    .padding()
                
            }
            
            
            
        }.padding()
        
    }
        #if os(iOS)
        .background {
            Image("helldivers2planet").resizable().aspectRatio(contentMode: .fill).offset(CGSize(width: 400, height: 0)).blur(radius: 20.0).ignoresSafeArea()
        }
        #endif
        
    
        
            .toolbar {

                
#if os(iOS)
                
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButton()
                        
                }
                
                
                #endif
                
            }
        
   
        
            
            
            
        
    }
}

#Preview {
    TipJarView()
}

struct CustomProductStyle: ProductViewStyle {

    func getProductImage(id: Product.ID) -> String {
        if id == "small_tip" {
            return "commonSample"
        }
        
        if id == "medium_tip" {
            return "rareSample"
        }
        
        if id == "large_tip" {
            return "superSample"
        }
        
        return ""
        
    }
    
    #if os(watchOS)
    func makeBody(configuration: Configuration) -> some View {
        
        switch configuration.state {
        case .loading:
            ProgressView()
        case .success(let product):
            
            
           
                
                VStack(alignment: .leading, spacing : 4) {
                    HStack(spacing: 10) {
                        
                        Image(getProductImage(id: product.id))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                        Text(product.displayName).textCase(.uppercase)
                            .font(Font.custom("FS Sinclair", size: largeFont))
                        
                        
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.description)
                            .font(Font.custom("FS Sinclair", size: smallFont))
                        
                        Button(action: {
                            configuration.purchase()
                        }) {
                            Text(verbatim: product.displayPrice)
                                .foregroundStyle(.black)
                                .padding(.top, 1.7)
                        }
                        .font(Font.custom("FS Sinclair", size: largeFont))
                        .buttonStyle(.borderedProminent)
                    }
                
            }
            
        
            
           
        default:
            Text("Something went wrong...")
                .font(Font.custom("FS Sinclair", size: 24))
        }
        
        
    }
    
    #elseif os(iOS)
    
    func makeBody(configuration: Configuration) -> some View {
        switch configuration.state {
        case .loading:
            ProgressView()
        case .success(let product):
            
            
            HStack(spacing: 26) {
                
                Image(getProductImage(id: product.id))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing : 4) {
                
                    Text(product.displayName).textCase(.uppercase)
                    .font(Font.custom("FS Sinclair", size: largeFont))
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.description)
                            .font(Font.custom("FS Sinclair", size: smallFont))
                        
                        Button(action: {
                            configuration.purchase()
                        }) {
                            Text(verbatim: product.displayPrice)
                                .foregroundStyle(.black)
                                .padding(.top, 1.7)
                        }
                        .font(Font.custom("FS Sinclair", size: mediumFont))
                        .buttonStyle(.borderedProminent)
                    }
                
            }
            
        }
            
           
        default:
            Text("Something went wrong...")
                .font(Font.custom("FS Sinclair", size: 24))
        }
    }
    #endif
}


