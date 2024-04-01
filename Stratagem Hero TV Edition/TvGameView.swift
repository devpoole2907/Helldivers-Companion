//
//  TvGameView.swift
//  Stratagem Hero TV Edition
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI
import GameController

struct TvGameView: View {
    
    @StateObject var viewModel = StratagemHeroModel()
    
    var body: some View {

          
        if viewModel.isPreLoadingDone {
            RemoteControlView(
                onLeftArrow: { viewModel.buttonInput(input: .left) },
                onRightArrow: { viewModel.buttonInput(input: .right) },
                onUpArrow: { viewModel.buttonInput(input: .up) },
                onDownArrow: { viewModel.buttonInput(input: .down) }
            )
            .frame(width: 0, height: 0)
            
        }
        
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
                    roundEndView
                case .gameOver:
                    highScoreView
                }
            } 
            
            ZStack {
                
                VStack {
                    
                    Image("superEarth").resizable().aspectRatio(contentMode: .fit).frame(width: 270, height: 270).opacity(0.15)
                    
                }
                VStack {
                    
                    Rectangle().frame(height: 6).foregroundStyle(.gray)
                    VStack {
                        if viewModel.gameState == .notStarted || viewModel.gameState == .roundEnded {
                            
                            if viewModel.isPreLoadingDone == false {
                                
                                Text("Loading assets...") .font(Font.custom("FS Sinclair", size: 32))
                                    .foregroundStyle(.yellow)
                                    .multilineTextAlignment(.center)
                                
                                
                            } else {
                                
                                Text("Enter any Stratagem Input to Start!") .font(Font.custom("FS Sinclair", size: 32))
                                    .foregroundStyle(.yellow)
                                    .multilineTextAlignment(.center)
                            }
                        } else if viewModel.gameState == .roundStarting {
                            
                            roundStartView
                            
                        } else if viewModel.gameState == .gameOver {
                            
                            gameOverView
                            
                        } else {
                            // game view
                            centerView
                            
                        }
                        
                    }.frame(minHeight: 350)
                    
                    Rectangle().frame(height: 6).foregroundStyle(.gray)
                    
                }
            }.frame(maxHeight: .infinity)
            

                
            }
        
        .onAppear {
            // preload assets
            viewModel.preloadAssets()
        }
        
        .background {
            Image("BackgroundImage").blur(radius: 14).ignoresSafeArea()
        }
        
        
       
            .onChange(of: viewModel.gameState) { value in
                          
                          print("tv game state is \(value)")
                          
                      }
        
        
    }
    
    
    
    var scoreView: some View {
        
        HStack {
            VStack(spacing: -5) {
                Text("Round") .font(Font.custom("FS Sinclair", size: 44))
                
                Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair", size: 66))
                    .foregroundStyle(viewModel.timeRemaining >= 2 ? .yellow : .red)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: -14) {
                Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair", size: 72))
                    .foregroundStyle(viewModel.timeRemaining >= 2 ? .yellow : .red)
                Text("Score").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 44))
            }
            
            
        }.padding(.horizontal, 50)
       
    }
    
    var highScoreView: some View {
        VStack {
     
            Text("High Score").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 44))
            
            Text("\(viewModel.highScore)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 72))
                .foregroundStyle(.yellow)
       
        }
    }
    
    var gameOverView: some View {
        VStack(spacing: -5) {
            Text("GAME OVER").textCase(.uppercase)
                .font(Font.custom("FS Sinclair", size: 72))
               
            if viewModel.topScores.count > 0 {
                Text("High Scores").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 36))
                
                ForEach(viewModel.topScores, id: \.self) { score in
                    
                    Text("\(score.rank). \(score.player.displayName) | \(score.score.formatted(.number))")
                        .textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 32))
                        .padding(.bottom, 5)
                }
            }
            
            Text("Your final score") .font(Font.custom("FS Sinclair", size: 36)).textCase(.uppercase)
            Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair", size: 44)).foregroundStyle(.yellow)
            
            Text("Enter any Stratagem Input to Continue!") .font(Font.custom("FS Sinclair", size: 36))
                .foregroundStyle(.yellow)
                .multilineTextAlignment(.center)
                .padding(.top)
               
            
        }
    }
    
    var roundEndView: some View {
        VStack(spacing: -5) {
            HStack {
                Text("Round Bonus").font(Font.custom("FS Sinclair", size: 36))
                Spacer()
                Text("\(viewModel.roundBonus)").font(Font.custom("FS Sinclair", size: 52))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Time Bonus").font(Font.custom("FS Sinclair", size: 36))
                Spacer()
                Text("\(viewModel.timeBonus)").font(Font.custom("FS Sinclair", size: 52))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Perfect Bonus").font(Font.custom("FS Sinclair", size: 36))
                Spacer()
                Text("\(viewModel.perfectBonus)").font(Font.custom("FS Sinclair", size: 52)).foregroundStyle(.yellow)
            }
            HStack {
                Text("Total Score").font(Font.custom("FS Sinclair", size: 36))
                Spacer()
                Text("\(viewModel.totalScore)").font(Font.custom("FS Sinclair", size: 52))
                    .foregroundStyle(.yellow)
            }
        }.padding(.horizontal, 70)
          //  .frame(maxHeight: 90)
        
    }
    
    var roundStartView: some View {
        
        VStack(spacing: -5) {
            Text("Get Ready").textCase(.uppercase)
                .font(Font.custom("FS Sinclair", size: 72))
                .padding(.vertical)
            
            Text("Round") .font(Font.custom("FS Sinclair", size: 36))
            Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair", size: 52))
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
                        .frame(width: 200)
                    
                        .border(viewModel.timeRemaining >= 2 ? .yellow : .red, width: 4)
                    
                    ForEach(viewModel.stratagems.prefix(3), id: \.id) { stratagem in // shows the next 3 stratagems
                        Image(stratagem.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .opacity(0.6)
                    }
                }
                
            }
                    
                    
                    
                    Text(stratagem.name).foregroundStyle(.black)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .font(Font.custom("FS Sinclair", size: 44))
                        .frame(minWidth: UIScreen.main.bounds.width - 100)
                        .background {
                            viewModel.timeRemaining >= 2 ? Color.yellow : Color.red
                        }
                    
                HStack {
                    
                    // Text("Stratagem: \(stratagem.sequence.joined(separator: " "))")
                    
                    ForEach(Array(stratagem.sequence.enumerated()), id: \.offset) { index, input in
                        
                        Image(systemName: "arrowshape.\(input).fill")
                            .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : Color(red: 189, green: 185, blue: 185)))
                            .font(.largeTitle)
                            .shadow(radius: 3)
                    }.animation(.none) // needs to ignore the animation system otherwise it gets buggy visually when changing stratagems

                }.shake(times: CGFloat(viewModel.arrowShakeTimes))
                    
                    TimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
            }
            }
    
    }
    
    
}

#Preview {
    TvGameView()
}

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
        .frame(height: 20)
    }
}

import SwiftUI
import UIKit

struct RemoteControlView: UIViewRepresentable {
    var onLeftArrow: () -> Void
    var onRightArrow: () -> Void
    var onUpArrow: () -> Void
    var onDownArrow: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let upGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.upArrowPressed))
        upGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.upArrow.rawValue)]
        view.addGestureRecognizer(upGesture)
        
        let downGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.downArrowPressed))
        downGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.downArrow.rawValue)]
        view.addGestureRecognizer(downGesture)
        
        let leftGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.leftArrowPressed))
        leftGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.leftArrow.rawValue)]
        view.addGestureRecognizer(leftGesture)
        
        let rightGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.rightArrowPressed))
        rightGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.rightArrow.rawValue)]
        view.addGestureRecognizer(rightGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onLeftArrow: onLeftArrow, onRightArrow: onRightArrow, onUpArrow: onUpArrow, onDownArrow: onDownArrow)
    }

    class Coordinator: NSObject {
        var onLeftArrow: () -> Void
        var onRightArrow: () -> Void
        var onUpArrow: () -> Void
        var onDownArrow: () -> Void

        init(onLeftArrow: @escaping () -> Void, onRightArrow: @escaping () -> Void, onUpArrow: @escaping () -> Void, onDownArrow: @escaping () -> Void) {
            self.onLeftArrow = onLeftArrow
            self.onRightArrow = onRightArrow
            self.onUpArrow = onUpArrow
            self.onDownArrow = onDownArrow
        }

        @objc func upArrowPressed() {
            onUpArrow()
        }

        @objc func downArrowPressed() {
            onDownArrow()
        }

        @objc func leftArrowPressed() {
            onLeftArrow()
        }

        @objc func rightArrowPressed() {
            onRightArrow()
        }
    }
}
