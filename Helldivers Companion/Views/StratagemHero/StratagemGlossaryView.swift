//
//  StratagemGlossaryView.swift
//  Helldivers Companion
//
//  Created by James Poole on 13/04/2024.
//

import SwiftUI
#if os(iOS)
import SwiftUIIntrospect
#endif

struct StratagemGlossaryView: View {
    
    @EnvironmentObject var viewModel: StratagemHeroModel
    
    
    let stratagems: [StratagemType: [Stratagem]]

       init() {
           self.stratagems = Dictionary(grouping: globalStratagems, by: { $0.type })
       }
    
    #if os(iOS)
    
    let buttonTextSize: CGFloat = 18
    
    #else
    
    let buttonTextSize: CGFloat = 10
    
    
    #endif
    
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottom) {
            ScrollView {
                
                #if os(watchOS)

                if viewModel.isCustomGame {
                    Text("ALERT: High Score is not saved with a custom Stratagem loadout selected.")
                        .font(Font.custom("FS Sinclair Bold", size: 10))
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                }
                
                #endif
                
                LazyVStack(alignment: .leading) {
                    
                    ForEach(StratagemType.allCases, id: \.self) { type in
                        if let stratagemsOfType = stratagems[type] {
                            Section {
                                ForEach(stratagemsOfType, id: \.id) { stratagem in
                                    StratagemInfoRow(stratagem).environmentObject(viewModel)
                                    
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                }
                            } header: {
                                Text(type.title.uppercased())
                                    .font(Font.custom("FS Sinclair Bold", size: 16))
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal)
                                    .padding(.bottom, -8)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                    
                }
                
                Spacer(minLength: 100)
                
            }.scrollContentBackground(.hidden)
            
            
                Button(action: {
                    withAnimation {
                        
                        if viewModel.selectedStratagems.isEmpty {
                            
                            viewModel.selectedStratagems = globalStratagems
                            
                        } else {
                            
                            viewModel.selectedStratagems = []
                            
                            
                        }
                        
                        
                    }
                }){
                    HStack(spacing: 4) {
                        Text(viewModel.selectedStratagems.isEmpty ? "SELECT ALL" : "DESELECT ALL") .font(Font.custom("FS Sinclair Bold", size: buttonTextSize))
                            .padding(.top, 2)
                        
                    }
                }.padding(5)
                    .padding(.horizontal, 5)
                    .shadow(radius: 3)
                
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
                                    .background {
                                        Color.black.opacity(0.7)
                                    }
                            }
                    )
                    .tint(.white)
                #if os(iOS)
                    .padding()
                #endif
                    .buttonStyle(PlainButtonStyle())
        }
            
            
            #if os(iOS)
            
                .navigationTitle("STRATAGEMS")
                .inlineLargeTitleiOS17()
            #else
            
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text("STRATAGEMS").font(Font.custom("FS Sinclair Bold", size: 14))
                        
                    }
                }
            
            
            #endif
            
        }  
        #if os(iOS)
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) { controller in
            print("I am introspecting!")
            
            
            let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
            let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
            
            // default to sf system font
            let largeFont = UIFont(name: "FS Sinclair Bold", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
            let inlineFont = UIFont(name: "FS Sinclair Bold", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)
            
            
            let largeAttributes: [NSAttributedString.Key: Any] = [
                .font: largeFont
            ]
            
            let inlineAttributes: [NSAttributedString.Key: Any] = [
                .font: inlineFont
            ]
            
            controller.navigationBar.titleTextAttributes = inlineAttributes
            
            controller.navigationBar.largeTitleTextAttributes = largeAttributes

        }
        #endif
    }
}
@available(iOS 17.0, *)
#Preview {
    StratagemGlossaryView()
}

struct StratagemInfoRow: View {
    
    @EnvironmentObject var viewModel: StratagemHeroModel
    
    let dashPattern: [CGFloat] = [CGFloat.random(in: 50...70), CGFloat.random(in: 5...20)]
    
    var stratagem: Stratagem
    
    
    var selected: Bool {
        
        viewModel.selectedStratagems.contains(where: { $0.name == stratagem.name })
        
    }
    
    init(_ stratagem: Stratagem) {
        self.stratagem = stratagem
    }
    
    #if os(iOS)
    
    let fontSize: CGFloat = 20
    let imageSize: CGFloat = 30
    #else
    
    let fontSize: CGFloat = 10
    let imageSize: CGFloat = 25
    
    #endif
    
    var body: some View {

        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.16)
                .shadow(radius: 3)
            HStack {
                Image(stratagem.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                
                Text(stratagem.name.uppercased())
                    .font(Font.custom("FS Sinclair Bold", size: fontSize))
                    .padding(.top, 2)
                Spacer()
            }.frame(maxWidth: .infinity)
                .padding(.leading, 10)
                .padding(.vertical, 8)
            
    
            
        }
        
        .onTapGesture {
            withAnimation {
            if !selected {
                
                    viewModel.selectedStratagems.append(stratagem)
                
            } else {
                if let index = viewModel.selectedStratagems.firstIndex(where: { $0.name == stratagem.name }), viewModel.selectedStratagems.count > 1 {
                
                        viewModel.selectedStratagems.remove(at: index)
                    
                }
            }
            
            
        }
            
        }
        
        .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: viewModel.dashPattern(for: stratagem)))
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




struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
           var path = Path()

           // Start from the top left point
           path.move(to: CGPoint(x: rect.minX, y: rect.minY))
           // Add line to top right
           path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
           // Add line to bottom right
           path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
           // Close the path (connects back to the top left)
           path.closeSubpath()

           return path
       }
}
