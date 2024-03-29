//
//  GameView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject var purchaseManager: StoreManager
    @StateObject var viewModel = StratagemHeroModel()
    @StateObject var gameCenterManager = GameCenterManager()
    @ObservedObject var watchConnectivity = WatchConnectivityProvider.shared
    
    var body: some View {
        NavigationStack {
           
                
                
            VStack(spacing: getRect().height == 667 ? 0 : 30) {
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
                        
                        Image("superEarth").resizable().aspectRatio(contentMode: .fit).frame(width: 160, height: 160).opacity(0.15)
                        
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
                
          
                buttons.padding(.bottom, getRect().height == 667 ? 30 : 0)
                    
                Spacer()
                    
                }
            
            .background {
                Image("BackgroundImage").blur(radius: 14).ignoresSafeArea()
            }
            
            .padding(.top)
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
                                        viewModel.updateHighScore()
                                        
                                    case .failure(let error):
                                        print("Authentication failed: \(error.localizedDescription)")
                                    }
                                }
                            }) {
                                Text("Sign In").textCase(.uppercase)
                                    .font(Font.custom("FS Sinclair", size: 16))
                                    .accessibility(label: Text("Game Center"))
                            }
                          //  .buttonStyle(.bordered)
                            
                        }
                        
                    }
                    
                }
            #endif
                
            
            
            .navigationBarTitleDisplayMode(.inline)
            
    } 
        
        .onChange(of: viewModel.gameEndCount) { value in
            
            if value == 3 {
                viewModel.gameEndCount = 0
                // 50% chance of showing tips sheet after 3 games played
                if Bool.random() {
                    purchaseManager.showTips.toggle()
                    purchaseManager.tipShownInSession = true // dont show again this session
                            }
            }
            
            
        }
        
        
        
        .onAppear {
        
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
                            .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                            .shadow(radius: 3)
                    }.animation(.none) // needs to ignore the animation system otherwise it gets buggy visually when changing stratagems

                }.shake(times: CGFloat(viewModel.arrowShakeTimes))
                    
                    TimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
            }
            } .frame(maxWidth: getRect().width - 100)
    
    }

    
    var buttons: some View {
        
        HStack(spacing: getRect().height == 667 ? 0 : 8) {
            
            
            
            Button(action: {
                viewModel.buttonInput(input: .left)
            }) {
                Image(systemName: "arrowshape.left.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
            }.keyboardShortcut(.leftArrow, modifiers: [])
            
            VStack(spacing: getRect().height == 667 ? 30 : 50) {
            
            
            Button(action: {
                viewModel.buttonInput(input: .up)
            }) {
                Image(systemName: "arrowshape.up.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
            }.keyboardShortcut(.upArrow, modifiers: [])
            
            Button(action: {
                viewModel.buttonInput(input: .down)
            }) {
                Image(systemName: "arrowshape.down.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
            }.keyboardShortcut(.downArrow, modifiers: [])
                

        }
            
            Button(action: {
                viewModel.buttonInput(input: .right)
            }) {
                Image(systemName: "arrowshape.right.fill")
                    .font(.system(size: getRect().height == 667 ? 60 : 75))
            }.keyboardShortcut(.rightArrow, modifiers: [])
            
        
        
        }.tint(.yellow)
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
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: (geometry.size.width * CGFloat(timeRemaining / totalTime)), height: 10)
                    .foregroundColor(.yellow)
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
