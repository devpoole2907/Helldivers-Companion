//
//  AboutView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI
@available(watchOS 9.0, *)
struct AboutView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var navPather: NavigationPather
    
    let gitUrl = "https://github.com/devpoole2907/Helldivers-Companion"
    let supportUrl = "https://devpoole2907.github.io/helldivers-companion-support/"
    let discordUrl = "https://discord.gg/3zMFwyyWPc"
    let shareUrl = "https://apps.apple.com/us/app/war-monitor-for-helldivers-2/id6479404407"
    
    @State private var showLanguageOptions = false
    @State private var showDarkModeOptions = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack(path: $navPather.navigationPath) {
            ScrollView {
           
                VStack(spacing: 20){
                    
                    if let url = URL(string: shareUrl) {
                        ShareLink(item: url) {
                            SettingsRow(settingTitle: "Share War Monitor", image: "square.and.arrow.up.fill", dashPattern: [67, 6])
                        }.buttonStyle(PlainButtonStyle())
                        
                    }
#if os(iOS)
                    if let url = URL(string: discordUrl) {
                        
                        Link(destination: url) {
                            SettingsRow(settingTitle: "Discord", image: "discordLogoSmall", dashPattern: [62, 15], systemImage: false)
                        }.tint(.white)

                    }
                    
                    if let url = URL(string: supportUrl) {
                        
                        Link(destination: url) {
                            SettingsRow(settingTitle: "Support", image: "hammer.fill", dashPattern: [69, 19])
                        }.tint(.white)

                    }
                    #endif
                    SettingsRow(settingTitle: "Language", image: "globe", selected: $viewModel.enableLocalization, dashPattern: [54, 18])
                        .onTapGesture {
                            showLanguageOptions.toggle()
                        }
                    
                    SettingsRow(settingTitle: "Dark Mode", image: "circle.lefthalf.filled", selected: $viewModel.darkMode, dashPattern: [51, 11])
                        .onTapGesture {
                            showDarkModeOptions.toggle()
                        }
                    
                    SettingsRow(settingTitle: "About", image: "info.circle.fill", dashPattern: [59, 5])
                        .onTapGesture {
                            showAbout.toggle()
                        }
                    
                }.padding()
            
                
            }
            
            .onChange(of: viewModel.enableLocalization) { _ in
                
                viewModel.refresh()
                
            }
            
            .sheet(isPresented: $showLanguageOptions) {
                
                SettingsSheet(selection: $viewModel.enableLocalization, settingTitle: "Language", settingSubtitle: "War Monitor for Helldivers 2 supports partial localisations. If enabled, any data received from the API will be displayed in your local language if supported, otherwise it will be presented in English. Recommend to restart the app after changing this setting.")
                
             
            }
            
            .sheet(isPresented: $showDarkModeOptions) {
                
                SettingsSheet(selection: $viewModel.darkMode, settingTitle: "Dark Mode", settingSubtitle: "Disables blurred backgrounds.")

            }
            
            .sheet(isPresented: $showAbout) {
                
                ScrollView {
                VStack(spacing: 20) {
                    
                    Text("ABOUT").font(Font.custom("FSSinclair", size: 18)).bold()
                        .padding()
                        .padding(.horizontal, 40)
                        .padding(.top, 3)
                        .background(
                            AngledLinesShape()
                                .stroke(lineWidth: 3)
                                .foregroundColor(.white)
                                .opacity(0.2)
                                .clipped()
                                .background {
                                    Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                                        .foregroundStyle(.gray)
                                        .opacity(0.9)
                                        .shadow(radius: 3)
                                }
                        )
                    
                    Text("This application utilizes the unofficial Helldivers 2 API, a collaborative project lead by dealloc available at https://github.com/helldivers-2/api, to fetch and display the latest data from the ongoing galactic war in the Helldivers 2 universe.")
                        .font(Font.custom("FSSinclair", size: 18))
                    
                    Text("This application also utilizes the Hellhub API developed by Fabio Nettis, available at https://github.com/hellhub-collective/api, to fetch and display additional information such as Stratagem statistics.")
                        .font(Font.custom("FSSinclair", size: 18))
                    
                    Text("To fetch the current Super Store rotation, the diveharder api available at https://github.com/helldivers-2/diveharder_api.py created by chatterchats is used.")
                        .font(Font.custom("FSSinclair", size: 18))
                    
                    Text("This application is not affiliated with, endorsed by, or in any way officially connected to Arrowhead Game Studios or Sony. All game content, including images and trademarks, are the property of their respective owners. The use of such content within this app falls under fair use for informational purposes and does not imply any association with the game developers or publishers.")
                        .font(Font.custom("FSSinclair", size: 18))
                    
                    Text("Sector map backdrop created by Shalzuth. Check out https://helldivers.io!")
                        .font(Font.custom("FSSinclair", size: 16))
                    
                    Text("Credit for the backgrounds goes to u/IMann110 on Reddit.")
                        .font(Font.custom("FSSinclair", size: 16))
                    
                    if let alert = viewModel.configData.alert {
                        Text(alert)      .font(Font.custom("FSSinclair-Bold", size: 18))
                            .foregroundStyle(Color.yellow)
                    }
                    
                    Spacer()
                    
                }.padding(.horizontal)
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
            }.scrollContentBackground(.hidden)
                
                    .presentationDetents([.medium, .large])
                    .customSheetBackground()
             
            }
            
            
            .toolbar {
#if os(iOS)
              
                    
                    ToolbarItem(placement: .principal) {
                        Text("Settings").textCase(.uppercase)
                            .font(Font.custom("FSSinclair-Bold", size: 24))
                    }
                    
                
#endif
#if os(watchOS)
                if #available(watchOS 10, *) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("SETTINGS").textCase(.uppercase)  .font(Font.custom("FSSinclair", size: largeFont)).bold()
                    }
                }
#endif
                
            }
            
            
            
            .navigationBarTitleDisplayMode(.inline)
            
        }.presentationDetents([.fraction(0.8), .large])
    }
}
@available(watchOS 9.0, *)
struct SettingsRow: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    let settingTitle: String
    let image: String
    var systemImage: Bool
    
    @Binding var selected: Bool
    let dashPattern: [CGFloat]
    #if os(iOS)
    
    let fontSize: CGFloat = 20
    let imageSize: CGFloat = 30
    #else
    
    let fontSize: CGFloat = 10
    let imageSize: CGFloat = 25
    
    #endif
    
    init(settingTitle: String, image: String, selected: Binding<Bool> = .constant(false), dashPattern: [CGFloat], systemImage: Bool = true) {
        self.settingTitle = settingTitle
        self.image = image
        _selected = selected
        self.dashPattern = dashPattern
        self.systemImage = systemImage
    }
    
    var body: some View {

        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.16)
                .shadow(radius: 3)
            HStack(spacing: 12) {
                
                if systemImage {
                    
                    
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                } else {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                }
                Text(settingTitle.uppercased())
                    .font(Font.custom("FSSinclair-Bold", size: fontSize))
                    .padding(.top, 2)
                Spacer()
            }.frame(maxWidth: .infinity)
                .padding(.leading, 10)
                .padding(.vertical, 8)
            
    
            
        }
        
        .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
        
        .overlay(
                       GeometryReader { geometry in
                           HStack {
                               Spacer()
                               if selected {
                               ZStack {
                                   Triangle()
                                       .fill(Color.green)
                                       .frame(width: geometry.size.height - 2, height: geometry.size.height - 2)
                                       .alignmentGuide(.trailing) { d in d[.trailing] }
                                   
                                   Image(systemName: "checkmark").font(.callout)
                                       .bold()
                                       .foregroundStyle(.white)
                                       .padding(.leading, 22)
                                       .padding(.bottom)
                                   
                               }.shadow(radius: 3)
                           }
                           }
                       },
                       alignment: .trailing
                   )
    
        
    }
    
}
@available(watchOS 9.0, *)
struct SettingsSheet: View {
    
    @Binding var selection: Bool
    let settingTitle: String
    let settingSubtitle: String
    
    
    var body: some View {
        
        ScrollView {
        VStack(spacing: 6) {
            
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
            
            
            
            
            Text(settingSubtitle)
                .font(Font.custom("FSSinclair", size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding()
                .shadow(radius: 3)
            
            CustomTogglePicker(selection: $selection)
            
            
                .frame(height: 30)
                .padding(4)
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
            
            
            
            Spacer()
            
        }
        
    }.scrollContentBackground(.hidden)
        
        .presentationDetents([.fraction(0.4)])
        .customSheetBackground(ultraThin: true)
        .presentationDragIndicator(.visible)
        
        
    }
    
    
}
