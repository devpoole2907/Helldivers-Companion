//
//  GameViewWatch.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 22/03/2024.
//

import SwiftUI
import AVFoundation

struct GameViewWatch: View {
    
    // viewmodel must be enviro as root will load the game sounds
    @EnvironmentObject var viewModel: StratagemHeroModel
    @ObservedObject var connectivityProvider = WatchConnectivityProvider.shared

    
    var body: some View {
        
        
        
        
        NavigationStack {
            VStack {
                
                highScoreView
               
         
                    Button(action: {
                        viewModel.showGameSheet.toggle()
                    }){
                        Text("Start Game").font(Font.custom("FS Sinclair Bold", size: 14))
                            .multilineTextAlignment(.center)
                    }
     
                        .foregroundStyle(.yellow)
                
                HStack {
                    Button(action: {
                        viewModel.enableSound.toggle()
                        
                        if !viewModel.enableSound {
                            viewModel.stopBackgroundSound()
                        } else if viewModel.gameState == .started {
                            viewModel.playBackgroundSound()
                        }
                    }) {
                        Image(systemName: viewModel.enableSound ? "speaker.fill" : "speaker.slash.fill")
                    }.foregroundStyle(viewModel.enableSound ? .accent : .gray)
                    
                    if !viewModel.showGlossary {
                        VolumeView()
                    }
                }.padding(.horizontal, 5)
                
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Stratagem Hero").textCase(.uppercase)  .font(Font.custom("FS Sinclair Bold", size: largeFont))
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
        }
        
        
        
        .sheet(isPresented: $viewModel.showGameSheet, onDismiss: {
            viewModel.gameOver() // end game on dismiss of the sheet
            viewModel.stopGame()
        }) {
            
            
         
            
                NavigationStack {
                    // if preloading is done show the game, or if sound is disabled, dont bother waiting for it to load as the sounds are not called
                    if viewModel.isPreLoadingDone || !viewModel.enableSound {
                    ZStack {
                        VStack {
                            
                            Image("superEarth").resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100).opacity(0.12)
                            
                        }
                        ZStack(alignment: .top) {
                            VStack {
                                Group {
                                    switch viewModel.gameState {
                                    case .started:
                                        scoreView
                                    case .notStarted:
                                        highScoreView
                                    case .roundEnded:
                                        roundEndView
                                    case .roundStarting:
                                        //roundEndView
                                        Spacer().frame(maxHeight: 45)
                                    case .gameOver:
                                        highScoreView
                                    }
                                }
                                
                                VStack {
                                    
                                    
                                    VStack {
                                        if viewModel.gameState == .notStarted || viewModel.gameState == .roundEnded {
                                            Rectangle().frame(height: 1).foregroundStyle(.gray)
                                            Text(viewModel.selectedStratagems.isEmpty ? "Select some Stratagems from the Glossary first!" : "Swipe in any direction to Start!") .font(Font.custom("FS Sinclair Bold", size: 14))
                                                .foregroundStyle(.yellow)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2, reservesSpace: true)
                                            Rectangle().frame(height: 1).foregroundStyle(.gray)
                                            
                                            glossaryButton
                                            
                                        } else if viewModel.gameState == .roundStarting {
                                            
                                            roundStartView
                                            
                                        } else if viewModel.gameState == .gameOver {
                                            
                                            gameOverView
                                            
                                        } else {
                                            // game view
                                            centerView
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                        }
                        
                        ForEach(viewModel.arrows, id: \.id) { arrow in
                            Image(systemName: viewModel.arrowName(for: arrow.direction))
                                .font(.system(size: 100))
                                .opacity(arrow.opacity)
                                .foregroundStyle(viewModel.showError ? .red : .accent)
                                .offset(arrow.offset)
                                .animation(.easeOut(duration: 0.5), value: arrow.offset)
                                .animation(.easeOut(duration: 0.5), value: arrow.opacity)
                                .onAppear {
                                    withAnimation {
                                        viewModel.moveArrow(id: arrow.id, to: viewModel.movementOffset(for: arrow.direction))
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation {
                                            viewModel.fadeOutArrow(id: arrow.id)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            viewModel.removeArrow(id: arrow.id)
                                        }
                                    }
                                }
                        }
                        
                    }.gesture(
                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                            .onEnded { value in
                                
                                // dont allow swipes if no selected strats
                                if !viewModel.selectedStratagems.isEmpty {
                                
                                let horizontalAmount = value.translation.width as CGFloat
                                let verticalAmount = value.translation.height as CGFloat
                                
                                if abs(horizontalAmount) > abs(verticalAmount) {
                                    if horizontalAmount < 0 {
                                        // Left swipe
                                        viewModel.buttonInput(input: .left)
                                        viewModel.addArrow(direction: .left)
                                        print("Swiped left")
                                    } else {
                                        // Right swipe
                                        viewModel.buttonInput(input: .right)
                                        viewModel.addArrow(direction: .right)
                                        print("Swiped right")
                                    }
                                } else {
                                    if verticalAmount < 0 {
                                        // Up swipe
                                        viewModel.buttonInput(input: .up)
                                        viewModel.addArrow(direction: .up)
                                        print("Swiped up")
                                    } else {
                                        // Down swipe
                                        viewModel.buttonInput(input: .down)
                                        viewModel.addArrow(direction: .down)
                                        print("Swiped down")
                                    }
                                }
                                
                                
                            }
                            }
                    )
                    
                    .onAppear {
                        
                        // show a quick indicator that you swipe to input on the watch version
                        let delay = 0.3
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 1) {
                            viewModel.addArrow(direction: .right)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 2) {
                            viewModel.addArrow(direction: .left)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 3) {
                            viewModel.addArrow(direction: .down)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 4) {
                            viewModel.addArrow(direction: .up)
                        }
                    }
                    
                    
                    .toolbar {
                        if viewModel.gameState == .started {
                            ToolbarItem(placement: .topBarTrailing){
                                HStack(spacing: -4) {
                                    Text("R") .font(Font.custom("FS Sinclair Bold", size: 20))
                                    
                                    Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair Bold", size: 20))
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    .navigationBarTitleDisplayMode(.inline)
                    
                    } else {
                        
                        
                        VStack {
                            Text("LOADING ASSETS...")
                            ProgressView()
                        }
                        
                    }
                
            }
            .dynamicTypeSize(.small)
            .interactiveDismissDisabled()
            
            
            
            .onChange(of: viewModel.gameEndCount) { value in
                
               
                
                
            }
            
          
            
        }
        
 
        
    }
    
    var glossaryButton: some View {
        
        Button(action: {
            viewModel.showGlossary.toggle()
        }){
            HStack(spacing: 4) {
                Text("Stratagem Glossary".uppercased()) .font(Font.custom("FS Sinclair Bold", size: 14))
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
                    }
            )
            .tint(.white)
            .buttonStyle(PlainButtonStyle())
        
            .sheet(isPresented: $viewModel.showGlossary) {
                
                StratagemGlossaryView().environmentObject(viewModel)
                
                    .customSheetBackground()
                
            }
        
        
    }
    
    
    
    var scoreView: some View {
        
        HStack {
                Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair Bold", size: 20))
                .foregroundStyle(viewModel.timeRemaining >= 2 ? .yellow : .red)
                Text("PTs").textCase(.uppercase) .font(Font.custom("FS Sinclair Bold", size: 20))
            
            
            
        }.padding(.horizontal, 10)
       
    }
    
    var highScoreView: some View {
        VStack {
     
            Text("High Score").textCase(.uppercase).font(Font.custom("FS Sinclair Bold", size: 20))
            
            Text("\(viewModel.highScore)").textCase(.uppercase).font(Font.custom("FS Sinclair Bold", size: 20))
                .foregroundStyle(.yellow)
       
        }
    }
    
    var gameOverView: some View {
        VStack(spacing: -5) {
            Text("GAME OVER").textCase(.uppercase)
                .font(Font.custom("FS Sinclair Bold", size: 20))
            
            Text("Your final score") .font(Font.custom("FS Sinclair Bold", size: 16)).textCase(.uppercase)
            Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair Bold", size: 18)).foregroundStyle(.yellow)
            
            Text("Swipe in any direction to Continue!") .font(Font.custom("FS Sinclair Bold", size: 14))
                .foregroundStyle(.yellow)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
                .padding(.top)
               
            
        }
    }
    
    var roundEndView: some View {
        VStack(spacing: -5) {
            Spacer().frame(maxHeight: 35)
            HStack {
                Text("R Bonus").font(Font.custom("FS Sinclair Bold", size: 14))
                Spacer()
                Text("\(viewModel.roundBonus)").font(Font.custom("FS Sinclair Bold", size: 16))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Time Bonus").font(Font.custom("FS Sinclair Bold", size: 14))
                Spacer()
                Text("\(viewModel.timeBonus)").font(Font.custom("FS Sinclair Bold", size: 16))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Perfect Bonus").font(Font.custom("FS Sinclair Bold", size: 14))
                Spacer()
                Text("\(viewModel.perfectBonus)").font(Font.custom("FS Sinclair Bold", size: 16)).foregroundStyle(.yellow)
            }
            HStack {
                Text("Total").font(Font.custom("FS Sinclair Bold", size: 14))
                Spacer()
                Text("\(viewModel.totalScore)").font(Font.custom("FS Sinclair Bold", size: 16))
                    .foregroundStyle(.yellow)
            }
        }//.padding(.horizontal, 70)
          //  .frame(maxHeight: 90)
    }
    
    var roundStartView: some View {
        
        VStack(spacing: -5) {
            Text("Get Ready").textCase(.uppercase)
                .font(Font.custom("FS Sinclair Bold", size: 20))
                .padding(.vertical)
            
            Text("Round") .font(Font.custom("FS Sinclair Bold", size: 14))
            Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair Bold", size: 26))
                .foregroundStyle(viewModel.timeRemaining >= 2 ? Color.yellow : Color.red)
            
        }
        
        
    }
    
    var centerView: some View {
       
        VStack(spacing: 10) {
            if let stratagem = viewModel.currentStratagem {
                ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10) {
                    
                    Image(stratagem.name)
                     
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 40)
                        .border(viewModel.timeRemaining >= 2 ? .yellow : .red)
                    
                    ForEach(viewModel.stratagems.prefix(3), id: \.id) { stratagem in // shows the next 3 stratagems
                        Image(stratagem.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .opacity(0.6)
                    }
                }
                
                }.scrollDisabled(true)
                    
                    
                    
                    Text(stratagem.name).foregroundStyle(.black)
                        .textCase(.uppercase)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .font(Font.custom("FS Sinclair Bold", size: 14))
                        .padding(.horizontal)
                        .background {
                           viewModel.timeRemaining >= 2 ? Color.yellow : Color.red
                        }
                    
                HStack {
                    
                    ForEach(Array(stratagem.sequence.enumerated()), id: \.offset) { index, input in
                        
                        Image(systemName: "arrowshape.\(input).fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFit()
                            .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                            .shadow(radius: 3)
                            
                    }.animation(.none) // needs to ignore the animation system otherwise it gets buggy visually when changing stratagems

                }.shake(times: CGFloat(viewModel.arrowShakeTimes))
                .frame(maxWidth: 150)
                WatchTimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
                    .frame(maxWidth: 100)
            }
            }
    
    }
    
}

#Preview {
    GameViewWatch()
}

struct WatchTimerBarView: View {
    @Binding var timeRemaining: Double
    let totalTime: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 10)
                    .foregroundStyle(.gray)

                Rectangle()
                    .frame(width: (geometry.size.width * CGFloat(timeRemaining / totalTime)), height: 10)
                    .foregroundStyle(timeRemaining >= 2 ? Color.yellow : Color.red)
            }
        }
        .frame(height: 5)
    }
}

struct VolumeView: WKInterfaceObjectRepresentable {
    typealias WKInterfaceObjectType = WKInterfaceVolumeControl


    func makeWKInterfaceObject(context: Self.Context) -> WKInterfaceVolumeControl {
        let view = WKInterfaceVolumeControl(origin: .local)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak view] timer in
            if let view = view {
                view.focus()
            } else {
                timer.invalidate()
            }
        }
        DispatchQueue.main.async {
            view.focus()
        }
        return view
    }
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceVolumeControl, context: WKInterfaceObjectRepresentableContext<VolumeView>) {
    }
}

