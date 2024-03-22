//
//  GameViewWatch.swift
//  Helldivers Companion Watch Edition Watch App
//
//  Created by James Poole on 22/03/2024.
//
/*
import SwiftUI

struct GameViewWatch: View {
    
    @StateObject var viewModel = StratagemHeroModel()
    
    var body: some View {
        NavigationStack {
            
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
                                Text("Enter any Stratagem Input to Start!") .font(Font.custom("FS Sinclair", size: 14))
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
                
                
                
                
                /*  ZStack {
                 
                 
                 
                 }*/
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            viewModel.buttonInput(input: .left)
                        }) {
                            Image(systemName: "arrowshape.left.fill")
                                .font(.system(size: 25))
                        }.buttonStyle(PlainButtonStyle())
                            .foregroundStyle(Color.yellow)
                        Spacer()
                        Button(action: {
                            viewModel.buttonInput(input: .right)
                        }) {
                            Image(systemName: "arrowshape.right.fill")
                                .font(.system(size: 25))
                        }.buttonStyle(PlainButtonStyle())
                            .foregroundStyle(Color.yellow)
                    }
                    Spacer(minLength: 100)
                    HStack {
                        Button(action: {
                            viewModel.buttonInput(input: .up)
                        }) {
                            Image(systemName: "arrowshape.up.fill")
                                .font(.system(size: 25))
                        }.buttonStyle(PlainButtonStyle())
                            .foregroundStyle(Color.yellow)
                            .contentShape(Circle())
                        Spacer()
                        Button(action: {
                            viewModel.buttonInput(input: .down)
                        }) {
                            Image(systemName: "arrowshape.down.fill")
                                .font(.system(size: 25))
                        }.buttonStyle(PlainButtonStyle())
                            .foregroundStyle(Color.yellow)
                    }
                    
                }
                
         
                
            }
            
        }

                
            
            
            .navigationBarTitleDisplayMode(.inline)
            
    }
        
    }
    
    var scoreView: some View {
        
        HStack {
            VStack(spacing: -5) {
                Text("R") .font(Font.custom("FS Sinclair", size: 20))
                
                Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair", size: 20))
                    .foregroundStyle(.yellow)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: -8) {
                Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair", size: 20))
                    .foregroundStyle(.yellow)
                Text("PTs").textCase(.uppercase) .font(Font.custom("FS Sinclair", size: 20))
            }
            
            
        }.padding(.horizontal, 50)
       
    }
    
    var highScoreView: some View {
        VStack {
     
            Text("High Score").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 20))
            
            Text("\(viewModel.highScore)").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 20))
                .foregroundStyle(.yellow)
       
        }
    }
    
    var gameOverView: some View {
        VStack(spacing: -5) {
            Text("GAME OVER").textCase(.uppercase)
                .font(Font.custom("FS Sinclair", size: 20))
            
            Text("Your final score") .font(Font.custom("FS Sinclair", size: 16)).textCase(.uppercase)
            Text("\(viewModel.totalScore)") .font(Font.custom("FS Sinclair", size: 18)).foregroundStyle(.yellow)
            
            Text("Enter any Stratagem Input to Continue!") .font(Font.custom("FS Sinclair", size: 14))
                .foregroundStyle(.yellow)
                .multilineTextAlignment(.center)
                .padding(.top)
               
            
        }
    }
    
    var roundEndView: some View {
        VStack(spacing: -5) {
            Spacer().frame(maxHeight: 35)
            HStack {
                Text("R Bonus").font(Font.custom("FS Sinclair", size: 14))
                Spacer()
                Text("\(viewModel.roundBonus)").font(Font.custom("FS Sinclair", size: 16))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Time Bonus").font(Font.custom("FS Sinclair", size: 14))
                Spacer()
                Text("\(viewModel.timeBonus)").font(Font.custom("FS Sinclair", size: 16))
                    .foregroundStyle(.yellow)
            }
            HStack {
                Text("Perfect Bonus").font(Font.custom("FS Sinclair", size: 14))
                Spacer()
                Text("\(viewModel.perfectBonus)").font(Font.custom("FS Sinclair", size: 16)).foregroundStyle(.yellow)
            }
            HStack {
                Text("Total").font(Font.custom("FS Sinclair", size: 14))
                Spacer()
                Text("\(viewModel.totalScore)").font(Font.custom("FS Sinclair", size: 16))
                    .foregroundStyle(.yellow)
            }
        }//.padding(.horizontal, 70)
          //  .frame(maxHeight: 90)
    }
    
    var roundStartView: some View {
        
        VStack(spacing: -5) {
            Text("Get Ready").textCase(.uppercase)
                .font(Font.custom("FS Sinclair", size: 20))
                .padding(.vertical)
            
            Text("Round") .font(Font.custom("FS Sinclair", size: 14))
            Text("\(viewModel.currentRound)") .font(Font.custom("FS Sinclair", size: 26))
                .foregroundStyle(.yellow)
            
        }
        
        
    }
    
    var centerView: some View {
       
        VStack(spacing: 10) {
            if let stratagem = viewModel.currentStratagem {
                ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 10) {
                    
                    Image(stratagem.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40) // Adjust the size as needed
                    
                        .border(.yellow)
                    
                    ForEach(viewModel.stratagems.prefix(3), id: \.id) { stratagem in // shows the next 3 stratagems
                        Image(stratagem.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .opacity(0.6)
                    }
                }
                
            }
                    
                    
                    
                    Text(stratagem.name).foregroundStyle(.black)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .font(Font.custom("FS Sinclair", size: 14))
                        .padding(.horizontal)
                        .background {
                            Color.yellow
                        }
                    
                HStack {
                    
                    // Text("Stratagem: \(stratagem.sequence.joined(separator: " "))")
                    
                    ForEach(Array(stratagem.sequence.enumerated()), id: \.offset) { index, input in
                        
                        Image(systemName: "arrowshape.\(input).fill")
                            .foregroundStyle(viewModel.showError ? .red.opacity(0.8) : (index < viewModel.inputSequence.count ? .yellow : .gray))
                        
                    }

                }//.shake(times: CGFloat(viewModel.arrowShakeTimes))
                .frame(maxWidth: 200)
                WatchTimerBarView(timeRemaining: $viewModel.timeRemaining, totalTime: 10)
                    .frame(maxWidth: 100)
            }
            }
    
    }

    
    var buttons: some View {
        
        HStack {
            
            
            
            Button(action: {
                viewModel.buttonInput(input: .left)
            }) {
                Image(systemName: "arrowshape.left.fill")
                    .font(.system(size: 75))
            }
            
            VStack(spacing: 50) {
            
            
            Button(action: {
                viewModel.buttonInput(input: .up)
            }) {
                Image(systemName: "arrowshape.up.fill")
                    .font(.system(size: 75))
            }
            
            Button(action: {
                viewModel.buttonInput(input: .down)
            }) {
                Image(systemName: "arrowshape.down.fill")
                    .font(.system(size: 75))
            }
                

        }
            
            Button(action: {
                viewModel.buttonInput(input: .right)
            }) {
                Image(systemName: "arrowshape.right.fill")
                    .font(.system(size: 75))
            }
            
        
        
        }.tint(.yellow)
        
        
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
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: (geometry.size.width * CGFloat(timeRemaining / totalTime)), height: 10)
                    .foregroundColor(.yellow)
            }
        }
        .frame(height: 5)
    }
}


*/
