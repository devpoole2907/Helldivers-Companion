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
    
    var body: some View {
        NavigationStack {
           
                
                
            VStack(spacing: 30) {
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
                
                ZStack {
                    
                    VStack {
                        
                        Image("Super_Earth").opacity(0.15)
                        
                    }
                    VStack {
                        
                        Rectangle().frame(height: 6).foregroundStyle(.gray)
                        VStack {
                            if viewModel.gameState == .notStarted || viewModel.gameState == .roundEnded {
                                Text("Enter any Stratagem Input to Start!") .font(Font.custom("FS Sinclair", size: 18))
                                    .foregroundStyle(.yellow)
                                    .multilineTextAlignment(.center)
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
                
                if getRect().height != 667 {
                Spacer()
            }
                buttons.padding(.bottom, getRect().height == 667 ? 30 : 0)
                    
                    
                }.padding(.top)
#if os(iOS)
                    .toolbar {
                        ToolbarItem(placement: gameCenterManager.isAuthenticated ? .principal : .topBarLeading) {
                            
                            Text("Stratagem Hero").textCase(.uppercase)
                                .font(Font.custom("FS Sinclair", size: 32))
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
                                        
                                    case .failure(let error):
                                        print("Authentication failed: \(error.localizedDescription)")
                                    }
                                }
                            }) {
                                Image(systemName: "gamecontroller.fill")
                                    .accessibility(label: Text("Game Center"))
                            }
                            .buttonStyle(.bordered)
                            
                        }
                        
                    }
                    
                }
            #endif
                
            
            
            .navigationBarTitleDisplayMode(.inline)
            
    } .onAppear {
        if gameCenterManager.hasSignedInBefore {
            GKAccessPoint.shared.isActive = true
            GKAccessPoint.shared.location = .topTrailing
            
            gameCenterManager.authenticatePlayer { result in
                switch result {
                case .success(_):
                    print("Authentication successful")
                case .failure(let error):
                    print("Authentication failed: \(error.localizedDescription)")
                }
            }
        }
        
    }
    .onDisappear {
        GKAccessPoint.shared.isActive = false
    }
        
    }
    
    var scoreView: some View {
        
        HStack {
            VStack(spacing: -5) {
                Text("Round") .font(Font.custom("FS Sinclair", size: 22))
                
                Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair", size: 36))
                    .foregroundStyle(.yellow)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: -14) {
                Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair", size: 36))
                    .foregroundStyle(.yellow)
                Text("Score").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 22))
            }
            
            
        }.padding(.horizontal, 50)
       
    }
    
    var highScoreView: some View {
        VStack {
     
            Text("High Score").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 22))
            
            Text("\(viewModel.highScore)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 36))
                .foregroundStyle(.yellow)
       
        }
    }
    
    var gameOverView: some View {
        VStack(spacing: -5) {
            Text("GAME OVER").textCase(.uppercase)
                .font(Font.custom("FS Sinclair", size: 36))
               
            if viewModel.topScores.count > 0 {
                Text("High Scores").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 18))
                
                ForEach(viewModel.topScores, id: \.self) { score in
                    
                    Text("\(score.rank). \(score.player.displayName) | \(score.score.formatted(.number))")
                        .textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 16))
                        .padding(.bottom, 5)
                }
            }
            
            Text("Your final score") .font(Font.custom("FS Sinclair", size: 18)).textCase(.uppercase)
            Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair", size: 22)).foregroundStyle(.yellow)
            
            Text("Enter any Stratagem Input to Continue!") .font(Font.custom("FS Sinclair", size: 18))
                .foregroundStyle(.yellow)
                .multilineTextAlignment(.center)
                .padding(.top)
               
            
        }
    }
    
    var roundEndView: some View {
        VStack(spacing: -5) {
            HStack {
                Text("Round Bonus").font(Font.custom("FS Sinclair", size: 18))
                Spacer()
                Text("\(viewModel.roundBonus)").font(Font.custom("FS Sinclair", size: 26))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Time Bonus").font(Font.custom("FS Sinclair", size: 18))
                Spacer()
                Text("\(viewModel.timeBonus)").font(Font.custom("FS Sinclair", size: 26))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Perfect Bonus").font(Font.custom("FS Sinclair", size: 18))
                Spacer()
                Text("\(viewModel.perfectBonus)").font(Font.custom("FS Sinclair", size: 26)).foregroundStyle(.yellow)
            }
            HStack {
                Text("Total Score").font(Font.custom("FS Sinclair", size: 18))
                Spacer()
                Text("\(viewModel.totalScore)").font(Font.custom("FS Sinclair", size: 26))
                    .foregroundStyle(.yellow)
            }
        }.padding(.horizontal, 70)
          //  .frame(maxHeight: 90)
    }
    
    var roundStartView: some View {
        
        VStack(spacing: -5) {
            Text("Get Ready").textCase(.uppercase)
                .font(Font.custom("FS Sinclair", size: 36))
                .padding(.vertical)
            
            Text("Round") .font(Font.custom("FS Sinclair", size: 18))
            Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair", size: 26))
                .foregroundStyle(.yellow)
            
        }
        
        
    }
    
    var centerView: some View {
       
        VStack(spacing: 20) {
            if let stratagem = viewModel.currentStratagem {
                ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10) {
                    
                    Image(stratagem.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100) // Adjust the size as needed
                    
                        .border(.yellow)
                    
                    ForEach(viewModel.stratagems.prefix(3), id: \.id) { stratagem in // shows the next 3 stratagems
                        Image(stratagem.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .opacity(0.6)
                    }
                }
                
            }
                    
                    
                    
                    Text(stratagem.name).foregroundStyle(.black)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .font(Font.custom("FS Sinclair", size: 22))
                        .frame(minWidth: UIScreen.main.bounds.width - 100)
                        .background {
                            Color.yellow
                        }
                    
                HStack {
                    
                    // Text("Stratagem: \(stratagem.sequence.joined(separator: " "))")
                    
                    ForEach(Array(stratagem.sequence.enumerated()), id: \.offset) { index, input in
                        
                        Image(systemName: "arrowshape.\(input).fill")
                            .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : .gray))
                        
                    }

                }.shake(times: CGFloat(viewModel.arrowShakeTimes))
                    
                    TimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
            }
            } .frame(maxWidth: getRect().width - 100)
    
    }

    
    var buttons: some View {
        
        HStack {
            
            
            
            Button(action: {
                viewModel.buttonInput(input: .left)
            }) {
                Image(systemName: "arrowshape.left.fill")
                    .font(.system(size: 75))
            }.keyboardShortcut(.leftArrow, modifiers: [])
            
            VStack(spacing: 50) {
            
            
            Button(action: {
                viewModel.buttonInput(input: .up)
            }) {
                Image(systemName: "arrowshape.up.fill")
                    .font(.system(size: 75))
            }.keyboardShortcut(.upArrow, modifiers: [])
            
            Button(action: {
                viewModel.buttonInput(input: .down)
            }) {
                Image(systemName: "arrowshape.down.fill")
                    .font(.system(size: 75))
            }.keyboardShortcut(.downArrow, modifiers: [])
                

        }
            
            Button(action: {
                viewModel.buttonInput(input: .right)
            }) {
                Image(systemName: "arrowshape.right.fill")
                    .font(.system(size: 75))
            }.keyboardShortcut(.rightArrow, modifiers: [])
            
        
        
        }.tint(.yellow)
        
        
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
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: (geometry.size.width * CGFloat(timeRemaining / totalTime)), height: 10)
                    .foregroundColor(.yellow)
            }
        }
        .frame(height: 10)
    }
}
