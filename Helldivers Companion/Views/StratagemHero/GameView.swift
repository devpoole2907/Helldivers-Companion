//
//  GameView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct GameView: View {
    
    @StateObject var viewModel = StratagemHeroModel()
    @StateObject var gameCenterManager = GameCenterManager()
    @ObservedObject var watchConnectivity = WatchConnectivityProvider.shared
    
    #if os(iOS)
    @EnvironmentObject var planetModel: PlanetsViewModel
    #endif
    
    var body: some View {
        NavigationStack {
            
       
            ZStack(alignment: .bottom) {
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .clear, .black]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .blendMode(.multiply)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                VStack(spacing: getRect().height == 667 ? 2 : 30) {
                    Group {
                        switch viewModel.gameState {
                        case .started:
                            scoreView
                        case .notStarted:
                            highScoreView
                        case .roundEnded:
                            roundEndView
                        case .roundStarting:
                            roundEndView
                        case .gameOver:
                            highScoreView
                        }
                    }  .padding(.top, getRect().height == 667 ? 30 : 10)
                        .contentShape(Rectangle())
                    
                    ZStack {
                        
                        VStack {
                            
                            Image("superEarth").resizable().aspectRatio(contentMode: .fit).frame(width: 160, height: 160).opacity(0.15)
                            
                        }
                        VStack {
                            
                            Rectangle().frame(height: 6).foregroundStyle(.gray)
                            VStack {
                                if viewModel.gameState == .notStarted || viewModel.gameState == .roundEnded {
                                    VStack(spacing: 4) {
                                        Text(viewModel.selectedStratagems.isEmpty ? "Select some Stratagems from the Glossary first!" : "Enter any Stratagem Input to Start!") .font(Font.custom("FSSinclair-Bold", size: 18))
                                            .foregroundStyle(.yellow)
                                            .multilineTextAlignment(.center)
                                        if viewModel.isCustomGame {
                                            Text("ALERT: High Score is not saved with a custom Stratagem loadout selected.")
                                                .font(Font.custom("FSSinclair-Bold", size: 12))
                                                .foregroundStyle(.yellow)
                                                .multilineTextAlignment(.center)
                                                .shadow(radius: 3)
                                                .padding(.horizontal)
                                        }
                                    }
                                    
                                    
                                } else if viewModel.gameState == .roundStarting {
                                    
                                    roundStartView
                                    
                                } else if viewModel.gameState == .gameOver {
                                    
                                    gameOverView
                                    
                                } else {
                                    // game view
                                    centerView
                                    
                                }
                                
                            }.frame(minHeight: 175)
                            
                            Rectangle().frame(height: 6).foregroundStyle(.gray)
                            
                            
                            
                        }
                        
                    }.frame(maxHeight: .infinity)
                        .contentShape(Rectangle())
                    
                    if !viewModel.enableSwipeGestures {
                        buttons.padding(.bottom, getRect().height == 667 ? 30 : 0)
                  
                        
                    } else {
                        ZStack {
                            
                            Text("Swipe Here!").textCase(.uppercase)
                                .font(Font.custom("FSSinclair-Bold", size: 28))
                            
                            Rectangle().foregroundStyle(Color.clear)
                                .contentShape(Rectangle())
                            
                                .highPriorityGesture(
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
                            }.allowsHitTesting(false)
                            
                        }.padding(.bottom, getRect().height == 667 ? 30 : 0)
                            
                    }
                    // Spacer()
                    
                }
                
                
                
                
                
            }
                
             
            
        
            
          
            
            .persistentSystemOverlays(.hidden)
            
            .conditionalBackground(viewModel: planetModel)
            
            
            .padding(.top)
#if os(iOS)
                    .toolbar {
                        ToolbarItem(placement: gameCenterManager.isAuthenticated ? .principal : .topBarLeading) {
                            
                            Text("Stratagem Hero").textCase(.uppercase)
                                .font(Font.custom("FSSinclair-Bold", size: 24))
                        }
                
                        
                        ToolbarItemGroup(placement: .topBarLeading) {
                            HStack(spacing: 6) {
                                Button(action: {
                                    withAnimation {
                                        viewModel.enableSwipeGestures.toggle()
                                    }
                                }) {
                                    Image(systemName: viewModel.enableSwipeGestures ? "hand.draw.fill" : "hand.draw")
                                }.foregroundStyle(viewModel.enableSwipeGestures ? .accent : .gray)
                                
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
                             
                                
                            }
                        }

                        // show login button if not authenticated for game center
                        if !gameCenterManager.isAuthenticated && !gameCenterManager.hasSignedInBefore {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                gameCenterManager.authenticatePlayer { result in
                                    switch result {
                                    case .success(_):
                                        print("Authentication successful")
                                        
                                        gameCenterManager.hasSignedInBefore = true
                                        viewModel.updateHighScore()
                                        
                                    case .failure(let error):
                                        print("Authentication failed: \(error.localizedDescription)")
                                    }
                                }
                            }) {
                                Text("Sign In").textCase(.uppercase)
                                    .font(Font.custom("FSSinclair-Bold", size: 16))
                                    .accessibility(label: Text("Game Center"))
                            }
                          //  .buttonStyle(.bordered)
                            
                        }
                        
                    }
                    
                }
            #endif
                
            
            
            .navigationBarTitleDisplayMode(.inline)
            
            .sheet(isPresented: $viewModel.showGlossary) {
                
                StratagemGlossaryView().environmentObject(viewModel)
                
                    .customSheetBackground()
                
            }
            
    } 
        
        .onChange(of: viewModel.gameEndCount) { value in
            
          
            
            
        }
        
        
        
        .onAppear {
            
            if viewModel.gameState == .started {
                viewModel.playBackgroundSound()
                }
        
        viewModel.viewCount += 1
        
        // auto sign in if viewing this for the first time, or has signed in before
        if gameCenterManager.hasSignedInBefore || viewModel.viewCount == 1 {
            GKAccessPoint.shared.isActive = true
            GKAccessPoint.shared.location = .topTrailing
            
            gameCenterManager.authenticatePlayer { result in
                switch result {
                case .success(_):
                    print("Authentication successful")
                    viewModel.updateHighScore()
                case .failure(let error):
                    print("Authentication failed: \(error.localizedDescription)")
                }
            }
            
            
            
            
        }
        
    }
    .onDisappear {
        GKAccessPoint.shared.isActive = false
        viewModel.stopBackgroundSound()
        
    }
        
    }
    
    var scoreView: some View {
        
        HStack {
            VStack(spacing: -5) {
                Text("Round") .font(Font.custom("FSSinclair-Bold", size: 22))
                
                Text("\(viewModel.currentRound)") .font(Font.custom("FSSinclair-Bold", size: 36))
                    .foregroundStyle(viewModel.timeRemaining >= 2 ? .yellow : .red)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: -14) {
                Text("\(viewModel.totalScore)") .font(Font.custom("FSSinclair-Bold", size: 36))
                    .foregroundStyle(viewModel.timeRemaining >= 2 ? .yellow : .red)
                Text("Score").textCase(.uppercase) .font(Font.custom("FSSinclair-Bold", size: 22))
            }
            
            
        }.padding(.horizontal, 50)
       
    }
    
    var highScoreView: some View {
        VStack(spacing: 2) {
     
            VStack {
                Text("High Score").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: 22))
                
                Text("\(viewModel.highScore)").textCase(.uppercase).font(Font.custom("FSSinclair-Bold", size: 36))
                    .foregroundStyle(.yellow)
            }

              glossaryButton
       
        }
    }
    
    var gameOverView: some View {
        VStack(spacing: -5) {
            Text("GAME OVER").textCase(.uppercase)
                .font(Font.custom("FSSinclair-Bold", size: 36))
               
            if viewModel.topScores.count > 0 {
                Text("High Scores").textCase(.uppercase) .font(Font.custom("FSSinclair-Bold", size: 18))
                
                ForEach(viewModel.topScores, id: \.self) { score in
                    
                    Text("\(score.rank). \(score.player.displayName) | \(score.score.formatted(.number))")
                        .textCase(.uppercase) .font(Font.custom("FSSinclair-Bold", size: 16))
                        .padding(.bottom, 5)
                }
            }
            
            Text("Your final score") .font(Font.custom("FSSinclair-Bold", size: 18)).textCase(.uppercase)
            Text("\(viewModel.totalScore)") .font(Font.custom("FSSinclair-Bold", size: 22)).foregroundStyle(.yellow)
            
            VStack(spacing: 2) {
                Text("Enter any Stratagem Input to Continue!") .font(Font.custom("FSSinclair-Bold", size: 18))
                    .foregroundStyle(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                if viewModel.isCustomGame {
                    Text("ALERT: High Score is not saved with a custom Stratagem loadout selected.")
                        .font(Font.custom("FSSinclair-Bold", size: 12))
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                        .lineLimit(2, reservesSpace: true)
                }
                
            }
               
            
        }
    }
    
    var roundEndView: some View {
        VStack(spacing: -5) {
            HStack {
                Text("Round Bonus").font(Font.custom("FSSinclair-Bold", size: 18))
                Spacer()
                Text("\(viewModel.roundBonus)").font(Font.custom("FSSinclair-Bold", size: 26))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Time Bonus").font(Font.custom("FSSinclair-Bold", size: 18))
                Spacer()
                Text("\(viewModel.timeBonus)").font(Font.custom("FSSinclair-Bold", size: 26))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Perfect Bonus").font(Font.custom("FSSinclair-Bold", size: 18))
                Spacer()
                Text("\(viewModel.perfectBonus)").font(Font.custom("FSSinclair-Bold", size: 26)).foregroundStyle(.yellow)
            }
            HStack {
                Text("Total Score").font(Font.custom("FSSinclair-Bold", size: 18))
                Spacer()
                Text("\(viewModel.totalScore)").font(Font.custom("FSSinclair-Bold", size: 26))
                    .foregroundStyle(.yellow)
            }

            glossaryButton.padding(.top)
            
        }.padding(.horizontal, 70)
          //  .frame(maxHeight: 90)
        
    }
    
    var roundStartView: some View {
        
        VStack(spacing: -5) {
            Text("Get Ready").textCase(.uppercase)
                .font(Font.custom("FSSinclair-Bold", size: 36))
                .padding(.vertical)
            
            Text("Round") .font(Font.custom("FSSinclair-Bold", size: 18))
            Text("\(viewModel.currentRound)") .font(Font.custom("FSSinclair-Bold", size: 26))
                .foregroundStyle(.yellow)
            
        }
        
        
    }
    
    var centerView: some View {
       
        VStack(spacing: 20) {
            if let stratagem = viewModel.currentStratagem {
                ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10) {
                    
                  //  Image(stratagem.name)
                    
                    Image(uiImage: getImage(named: stratagem.name))
                    
                    
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100) // Adjust the size as needed
                    
                        .border(viewModel.timeRemaining >= 2 ? .yellow : .red)
                    
                    ForEach(viewModel.stratagems.prefix(3), id: \.id) { stratagem in // shows the next 3 stratagems
                        Image(uiImage: getImage(named: stratagem.name))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .opacity(0.6)
                    }
                }
                
                }.allowsHitTesting(false)
                    
                    
                    
                    Text(stratagem.name).foregroundStyle(.black)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .font(Font.custom("FSSinclair-Bold", size: 22))
                        .frame(minWidth: UIScreen.main.bounds.width - 100)
                        .background {
                            viewModel.timeRemaining >= 2 ? Color.yellow : Color.red
                        }
                    
                HStack {
                    
                    // Text("Stratagem: \(stratagem.sequence.joined(separator: " "))")
                    
                    ForEach(Array(stratagem.sequence.enumerated()), id: \.offset) { index, input in
                        
                        
                        if #available(iOS 17.0, *) {
                            Image(systemName: "arrowshape.\(input).fill")
                                .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                                .shadow(radius: 3)
                            
                        } else {
                            Image(systemName: "arrowtriangle.\(input).fill")
                                .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                                .shadow(radius: 3)
                            
                        }
                        
                      
                           
                        
                        
                        
                        
                    }.animation(.none) // needs to ignore the animation system otherwise it gets buggy visually when changing stratagems

                }.shake(times: CGFloat(viewModel.arrowShakeTimes))
                    
                    TimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
            }
            } .frame(maxWidth: getRect().width - 100)
        
        
            
        
    
    }

    var glossaryButton: some View {
        
        Button(action: {
            
            if viewModel.gameState == .notStarted || viewModel.gameState == .gameOver {
                
                viewModel.showGlossary.toggle()
                
            } else {
                viewModel.gameOver()
            }
            
        }){
            HStack(spacing: 4) {
              
                Text(viewModel.gameState == .notStarted || viewModel.gameState == .gameOver ? "Loadout".uppercased() : "End Game") .font(Font.custom("FSSinclair-Bold", size: 18))
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
        
        
    }
    
    var buttons: some View {
        
        HStack(spacing: getRect().height == 667 ? 0 : 8) {

            Button(action: {
                viewModel.buttonInput(input: .left)
            }) {
                if #available(iOS 17.0, *) {
                    Image(systemName: "arrowshape.left.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
                    
                } else {
                    
                    Image(systemName: "arrowtriangle.left.fill")
                        .font(.system(size: 60))
                    
                }
                
            }
                    
                    .keyboardShortcut(.leftArrow, modifiers: [])
            
            VStack(spacing: getRect().height == 667 ? 30 : 50) {
            
            
            Button(action: {
                viewModel.buttonInput(input: .up)
            }) {

                if #available(iOS 17.0, *) {
                    Image(systemName: "arrowshape.up.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
                    
                } else {
                    
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 60))
                    
                }
                
                
            }.keyboardShortcut(.upArrow, modifiers: [])
            
            Button(action: {
                viewModel.buttonInput(input: .down)
            }) {
               
                if #available(iOS 17.0, *) {
                    Image(systemName: "arrowshape.down.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
                    
                } else {
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 60))
                    
                }
                
                
            }.keyboardShortcut(.downArrow, modifiers: [])
                

        }
            
            Button(action: {
                viewModel.buttonInput(input: .right)
            }) {
                if #available(iOS 17.0, *) {
                    Image(systemName: "arrowshape.right.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
                    
                } else {
                    
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.system(size: 60))
                    
                }
            }.keyboardShortcut(.rightArrow, modifiers: [])
            
        
        
        }.tint(viewModel.selectedStratagems.isEmpty ? .gray : .yellow)
            .disabled(viewModel.selectedStratagems.isEmpty)
            .shadow(radius: 3)
        
        
    }
    
}

#Preview {
    GameView()
}

import SwiftUI
import GameKit

struct TimerBarView: View {
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
        .frame(height: 10)
    }
}

extension View {
    func getRect()->CGRect {
        return UIScreen.main.bounds
    }
}
