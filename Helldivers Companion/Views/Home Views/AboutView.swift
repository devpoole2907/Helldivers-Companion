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
                
#if os(watchOS)
                
                if let githubUrl = URL(string: gitUrl) {
                    
                    
                    Link(destination: githubUrl, label: {
                        Image("github-mark-white")
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    })
                    
                    
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
                
                if let githubUrl = URL(string: gitUrl) {
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Link(destination: githubUrl, label: {
                            Image("github-mark-white")
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        })
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
