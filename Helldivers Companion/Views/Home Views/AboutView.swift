//
//  AboutView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct AboutView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    let gitUrl = "https://github.com/devpoole2907/Helldivers-Companion"
    let supportUrl = "https://devpoole2907.github.io/helldivers-companion-support/"
    let discordUrl = "https://discord.gg/3zMFwyyWPc"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("This application utilizes the unofficial Helldivers 2 API developed by dealloc, available at https://github.com/dealloc/helldivers2-api, to fetch and display the latest data from the ongoing galactic war in the Helldivers 2 universe.")
                        .font(Font.custom("FS Sinclair", size: 18))
                    
                    Text("This application is not affiliated with, endorsed by, or in any way officially connected to Arrowhead Game Studios or Sony. All game content, including images and trademarks, are the property of their respective owners. The use of such content within this app falls under fair use for informational purposes and does not imply any association with the game developers or publishers.")
                        .font(Font.custom("FS Sinclair", size: 18))
                    
                    if let alert = viewModel.configData.alert {
                        Text(alert)      .font(Font.custom("FS Sinclair", size: 18))
                            .foregroundStyle(Color.yellow)
                    }
                    
                }.padding(.horizontal)
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
                #if os(iOS)
                
                if let supportUrl = URL(string: supportUrl) {
                    Link(destination: supportUrl, label: {
                        Text("Support") .font(Font.custom("FS Sinclair", size: 20))
                            .underline()
                    }).padding()
                }
                
                if let discordUrl = URL(string: discordUrl) {
                    Link(destination: discordUrl, label: {
                        Image("discordLogo").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                    }).padding()
                }
                
                #endif
                
                
                Spacer()
                
            }
            
            
            .toolbar {
#if os(iOS)
                if #available(iOS 17.0, *) {
                    
                    ToolbarItem(placement: .principal) {
                        Text("About").textCase(.uppercase)
                            .font(Font.custom("FS Sinclair", size: 24))
                    }
                    
                }
#endif
#if os(watchOS)
                ToolbarItem(placement: .topBarLeading) {
                    Text("ABOUT").textCase(.uppercase)  .font(Font.custom("FS Sinclair", size: largeFont))
                }
#endif
                
            }
            
            
            
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

#Preview {
    AboutView()
}
