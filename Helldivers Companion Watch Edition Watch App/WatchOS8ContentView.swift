//
//  WatchOS8ContentView.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 03/05/2024.
//

import SwiftUI
import AVFoundation

struct WatchOS8ContentView: View {
    
    @StateObject var gameModel = StratagemHeroModel()
    
    @State private var currentTab: Tab = .game
    
    var body: some View {
        TabView(selection: $currentTab) {
            
            ScrollView {
                Text("This version for watchOS 8 is limited and unsupported, but for those who just want Stratagem Hero I've made it available :) Update to watchOS 10.0 for the complete War Monitor experience!")
                    .multilineTextAlignment(.center)
            }
                .tag(Tab.about)
            
            
            GameViewWatchOS8().environmentObject(gameModel)
                .tag(Tab.game)

            
            
        }
        
        .onAppear {
            gameModel.preloadAssets()
        }
    }
}

#Preview {
    WatchOS8ContentView()
}

struct GameViewWatchOS8: View {
    
    // viewmodel must be enviro as root will load the game sounds
    @EnvironmentObject var viewModel: StratagemHeroModel
    @ObservedObject var connectivityProvider = WatchConnectivityProvider.shared

    
    var body: some View {
        
        
        
        
    
            VStack {
                
                highScoreView
               
         
                    Button(action: {
                        viewModel.showGameSheet.toggle()
                    }){
                        Text("Start Game").font(Font.custom("FSSinclair-Bold", size: 14))
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
            

        
        
        
        .sheet(isPresented: $viewModel.showGameSheet, onDismiss: {
            viewModel.gameOver() // end game on dismiss of the sheet
            viewModel.stopGame()
        }) {
            
            
         
            
           
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
                                            Text(viewModel.selectedStratagems.isEmpty ? "Select some Stratagems from the Glossary first!" : "Swipe in any direction to Start!") .font(Font.custom("FSSinclair-Bold", size: 14))
                                                .foregroundStyle(.yellow)
                                                .multilineTextAlignment(.center)
                       
                                            Rectangle().frame(height: 1).foregroundStyle(.gray)
                                            
                                            
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
                    

                    
                    
                    
                    
                    .navigationBarTitleDisplayMode(.inline)
                    
                    } else {
                        
                        
                        VStack {
                            Text("LOADING ASSETS...")
                            ProgressView()
                        }
                        
                    }
                
            
     
            
          
            
        }
        
 
        
    }
    
    
    
    
    var scoreView: some View {
        
        HStack {
                Text("\(viewModel.totalScore)") .font(Font.custom("FSSinclair-Bold", size: 20))
                .foregroundStyle(viewModel.timeRemaining >= 2 ? .yellow : .red)
                Text("PTs").textCase(.uppercase) .font(Font.custom("FSSinclair-Bold", size: 20))
            
            
            
        }.padding(.horizontal, 10)
       
    }
    
    var highScoreView: some View {
        VStack {
     
            Text("High Score").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: 20))
            
            Text("\(viewModel.highScore)").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: 20))
                .foregroundStyle(.yellow)
       
        }
    }
    
    var gameOverView: some View {
        VStack(spacing: -5) {
            Text("GAME OVER").textCase(.uppercase)
                .font(Font.custom("FSSinclair-Bold", size: 20))
            
            Text("Your final score") .font(Font.custom("FSSinclair-Bold", size: 16)).textCase(.uppercase)
            Text("\(viewModel.totalScore)") .font(Font.custom("FSSinclair-Bold", size: 18)).foregroundStyle(.yellow)
            
            Text("Swipe in any direction to Continue!") .font(Font.custom("FSSinclair-Bold", size: 14))
                .foregroundStyle(.yellow)
                .multilineTextAlignment(.center)
                .padding(.top)
               
            
        }
    }
    
    var roundEndView: some View {
        VStack(spacing: -5) {
            Spacer().frame(maxHeight: 35)
            HStack {
                Text("R Bonus").font(Font.custom("FSSinclair-Bold", size: 14))
                Spacer()
                Text("\(viewModel.roundBonus)").font(Font.custom("FSSinclair-Bold", size: 16))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Time Bonus").font(Font.custom("FSSinclair-Bold", size: 14))
                Spacer()
                Text("\(viewModel.timeBonus)").font(Font.custom("FSSinclair-Bold", size: 16))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Perfect Bonus").font(Font.custom("FSSinclair-Bold", size: 14))
                Spacer()
                Text("\(viewModel.perfectBonus)").font(Font.custom("FSSinclair-Bold", size: 16)).foregroundStyle(.yellow)
            }
            HStack {
                Text("Total").font(Font.custom("FSSinclair-Bold", size: 14))
                Spacer()
                Text("\(viewModel.totalScore)").font(Font.custom("FSSinclair-Bold", size: 16))
                    .foregroundStyle(.yellow)
            }
        }//.padding(.horizontal, 70)
          //  .frame(maxHeight: 90)
    }
    
    var roundStartView: some View {
        
        VStack(spacing: -5) {
            Text("Get Ready").textCase(.uppercase)
                .font(Font.custom("FSSinclair-Bold", size: 20))
                .padding(.vertical)
            
            Text("Round") .font(Font.custom("FSSinclair-Bold", size: 14))
            Text("\(viewModel.currentRound)") .font(Font.custom("FSSinclair-Bold", size: 26))
                .foregroundStyle(viewModel.timeRemaining >= 2 ? Color.yellow : Color.red)
            
        }
        
        
    }
    
    var centerView: some View {
       
        VStack(spacing: 10) {
            if let stratagem = viewModel.currentStratagem {
                ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10) {
                    
                    Image(uiImage: getImage(named: stratagem.name))
                     
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 40)
                        .border(viewModel.timeRemaining >= 2 ? .yellow : .red)
                    
                    ForEach(viewModel.stratagems.prefix(3), id: \.id) { stratagem in // shows the next 3 stratagems
                        Image(uiImage: getImage(named: stratagem.name))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .opacity(0.6)
                    }
                }
                
                }.allowsHitTesting(false)
                    
                    
                    
                    Text(stratagem.name).foregroundStyle(.black)
                        .textCase(.uppercase)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .font(Font.custom("FSSinclair-Bold", size: 14))
                        .padding(.horizontal)
                        .background {
                           viewModel.timeRemaining >= 2 ? Color.yellow : Color.red
                        }
                    
                HStack {
                    
                    ForEach(Array(stratagem.sequence.enumerated()), id: \.offset) { index, input in
                        
                        if #available(watchOS 10.0, *) {
                            Image(systemName: "arrowshape.\(input).fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                                .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                                .shadow(radius: 3)
                            
                        } else {
                            
                            Image(systemName: "arrowtriangle.\(input).fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                                .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                                .shadow(radius: 3)
                            
                            
                            
                        }
                            
                    }.animation(.none) // needs to ignore the animation system otherwise it gets buggy visually when changing stratagems

                }.shake(times: CGFloat(viewModel.arrowShakeTimes))
                .frame(maxWidth: 150)
                WatchTimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
                    .frame(maxWidth: 100)
            }
            }
    
    }
    
}
