//
//  StratagemHeroModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import Foundation
import SwiftUI
import GameKit

class StratagemHeroModel: ObservableObject {
    @Published var currentStratagem: Stratagem?
    @Published var inputSequence: [StratagemInput] = []
    @Published var timeRemaining: Double = 10
    @Published var gameState: GameState = .notStarted
    @Published var showError = false
    
    @Published var topScores: [GKLeaderboard.Entry] = []
    
    @Published var currentRound = 1
    private var stratagemsPerRound = 6
    
    private let roundBonusPoints = 100
    private let timeBonusPointsPerSecond = 10
    private let perfectBonusPoints = 50
    
    @Published var roundScore: Int = 0
        @Published var roundBonus: Int = 0
        @Published var timeBonus: Int = 0
        @Published var perfectBonus: Int = 0
        @Published var totalScore: Int = 0
    
    @AppStorage("highScore") var highScore = 0 // store high score
    
    @Published var arrowShakeTimes = 0
    
    var stratagems: [Stratagem] = []
    var timer: Timer?

    init() {
        loadStratagems(forRound: currentRound)
    }
    
    func startGame() {
            currentRound = 1
            stratagemsPerRound = 6
            loadStratagems(forRound: currentRound)
            nextStratagem()
            startTimer()
            gameState = .started
        }
    
    func stopGame() {
        totalScore = 0 // clear total score
        gameState = .notStarted
    }
    
    enum GameState {
        
        case started
        case notStarted
        case roundEnded
        case roundStarting
        case gameOver
        
    }
    
    func buttonInput(input: StratagemInput) {
        if gameState == .roundStarting {
            // do nothing
        } else if gameState == .gameOver {
            stopGame()
        }
        else if gameState == .notStarted {
            startGame()
        } else if gameState == .roundEnded {
           startNextRound()
        } else {
            inputArrowKey(input)
        }
    }


   
    func loadStratagems(forRound round: Int) {
            let totalStratagems = min(globalStratagems.count, stratagemsPerRound)
            stratagems = Array(globalStratagems.shuffled().prefix(totalStratagems))
        }
    
    func gameOver() {
        
        self.timer?.invalidate()
        self.timer = nil
        
        
        
      
        
        if totalScore > highScore {
            highScore = totalScore
        }
        
        // report high score to game center leaderboard
        let gameCenterManager = GameCenterManager()
        let leaderboardId = "com.poole.james.helldiverscompanion.highscores"
        gameCenterManager.reportScore(score: highScore, leaderboardID: leaderboardId)
        
        Task {
            self.topScores = await gameCenterManager.loadTopScores(leaderboardID: leaderboardId, count: 3)
            gameState = .gameOver
        }
  
       

    }
    
    func endRound() {
        gameState = .roundEnded
        
        totalScore += roundScore + roundBonus + timeBonus + perfectBonus

        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func startNextRound() {
        currentRound += 1
        stratagemsPerRound += 1
        loadStratagems(forRound: currentRound)
        nextStratagem()
        
        
        
        gameState = .roundStarting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // reset scores
            self.roundScore = 0
            self.roundBonus = 0
            self.timeBonus = 0
            self.perfectBonus = 0
            self.startTimer()
            self.gameState = .started
        }
    }

    func nextStratagem() {
        
        
        if let stratagem = stratagems.first {
            currentStratagem = stratagem
            stratagems.removeFirst()
            
            inputSequence = []
            
        } else {
            // end round, no stratagems left
            
            
            roundBonus += roundBonusPoints
            timeBonus += Int(timeRemaining) * timeBonusPointsPerSecond
            
            endRound()

            
            
        }
    }

    func startTimer() {
        
        timeRemaining = 10
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                // Game over
                self.gameOver()
                
                
            }
        }
    }

    func inputArrowKey(_ key: StratagemInput) {
        guard let currentStratagem = currentStratagem else { return }

        inputSequence.append(key)
        if inputSequence == currentStratagem.sequence {
            // Correct sequence
            timeRemaining += 2
                   let stratagemScore = currentStratagem.sequence.count * 10
                   roundScore += stratagemScore

                   // Update total score live
                   totalScore += stratagemScore
                   if inputSequence.count == currentStratagem.sequence.count {
                      
                       perfectBonus += perfectBonusPoints
                       totalScore += perfectBonusPoints
                   }
            
            // game score added per correct stratagem
            nextStratagem()
        } else if !currentStratagem.sequence.starts(with: inputSequence) {
            // wrong sequence
            inputSequence = []
            showError = true //
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // flash red for 0.3 seconds when wrongly entered
                            self.showError = false
                        }
            
            withAnimation(.linear(duration: 0.3)) {
                arrowShakeTimes += 1 //  shake when entered wrong
            }
            
        }
    }
}

struct Stratagem {
    var id: UUID = UUID()
    var name: String = ""
    var sequence: [StratagemInput] // arrow key sequence
}

enum StratagemInput {
    
    case up
    case down
    case left
    case right
    
}

let globalStratagems: [Stratagem] = [
    Stratagem(name: "Machine Gun", sequence: [.down, .left, .down, .up, .right]),
    Stratagem(name: "Anti-Materiel Rifle", sequence: [.down, .left, .right, .up, .down]),
    Stratagem(name: "Stalwart", sequence: [.down, .left, .down, .up, .up, .left]),
    Stratagem(name: "Expendable Anti-Tank", sequence: [.down, .down, .left, .up, .right]),
    Stratagem(name: "Recoilless Rifle", sequence: [.down, .left, .right, .right, .left]),
    Stratagem(name: "Flamethrower", sequence: [.down, .left, .up, .down, .up]),
    Stratagem(name: "Autocannon", sequence: [.down, .right, .left, .down, .down, .up, .up, .right]),
    Stratagem(name: "Railgun", sequence: [.down, .right, .left, .down, .down, .up, .left, .down, .right]),
    Stratagem(name: "Spear", sequence: [.down, .down, .up, .down, .down]),
    Stratagem(name: "Orbital Gatling Barrage", sequence: [.right, .down, .left, .up, .up]),
    Stratagem(name: "Orbital Airburst Strike", sequence: [.right, .right, .right]),
    Stratagem(name: "Orbital 120MM HE Barrage", sequence: [.right, .down, .down, .left, .down, .right, .down, .down]),
    Stratagem(name: "Orbital 380MM HE Barrage", sequence: [.right, .down, .down, .up, .up, .left, .down, .down, .down]),
    Stratagem(name: "Orbital Walking Barrage", sequence: [.right, .down, .right, .down, .right, .down]),
    Stratagem(name: "Orbital Laser Strike", sequence: [.right, .up, .left, .up, .right, .left]),
    Stratagem(name: "Orbital Railcannon Strike", sequence: [.right, .down, .up, .down, .left]),
    Stratagem(name: "Eagle Strafing Run", sequence: [.up, .right, .right]),
    Stratagem(name: "Eagle Airstrike", sequence: [.up, .right, .down, .right]),
    Stratagem(name: "Eagle Cluster Bomb", sequence: [.up, .right, .down, .down, .right, .down]),
    Stratagem(name: "Eagle Napalm Airstrike", sequence: [.up, .right, .down, .up]),
    Stratagem(name: "Jump Pack", sequence: [.down, .up, .up, .down, .up]),
    Stratagem(name: "Eagle Smoke Strike", sequence: [.up, .right, .up, .down]),
    Stratagem(name: "Eagle 110MM Rocket Pods", sequence: [.up, .down, .up, .left]),
    Stratagem(name: "Eagle 500KG Bomb", sequence: [.up, .left, .down, .down, .down]),
    Stratagem(name: "Orbital Precision Strike", sequence: [.right, .right, .up]),
    Stratagem(name: "Orbital Gas Strike", sequence: [.right, .right, .down, .right]),
    Stratagem(name: "Orbital EMS Strike", sequence: [.right, .right, .left, .down]),
    Stratagem(name: "Orbital Smoke Strike", sequence: [.right, .right, .down, .up]),
    Stratagem(name: "HMG Emplacement", sequence: [.up, .down, .left, .right, .right, .left]),
    Stratagem(name: "Shield Generator Relay", sequence: [.down, .up, .left, .right, .left, .down]),
    Stratagem(name: "Tesla Tower", sequence: [.down, .up, .right, .up, .left, .right]),
    Stratagem(name: "Anti-Personnel Minefield", sequence: [.down, .left, .down, .up, .right]),
    Stratagem(name: "Supply Pack", sequence: [.down, .left, .down, .up, .up, .down]),
    Stratagem(name: "Grenade Launcher", sequence: [.down, .left, .down, .up, .left, .down, .down]),
    Stratagem(name: "Laser Cannon", sequence: [.down, .left, .down, .up, .left]),
    Stratagem(name: "Incendiary Mines", sequence: [.down, .left, .left, .down]),
    Stratagem(name: "Guard Dog Rover", sequence: [.down, .left, .down, .up, .left, .down, .down]),
    Stratagem(name: "Ballistic Shield Backpack", sequence: [.down, .left, .up, .up, .right]),
    Stratagem(name: "Arc Thrower", sequence: [.down, .right, .up, .left, .down]),
    Stratagem(name: "Shield Generator Pack", sequence: [.down, .up, .left, .down, .right, .right]),
    Stratagem(name: "Machine Gun Sentry", sequence: [.down, .up, .right, .right, .up]),
    Stratagem(name: "Gatling Sentry", sequence: [.down, .up, .right, .left, .down]),
    Stratagem(name: "Mortar Sentry", sequence: [.down, .up, .right, .right, .down]),
    Stratagem(name: "Guard Dog", sequence: [.down, .up, .left, .up, .right, .down]),
    Stratagem(name: "Autocannon Sentry", sequence: [.down, .up, .right, .up, .left, .up]),
    Stratagem(name: "Rocket Sentry", sequence: [.down, .up, .right, .right, .left]),
    Stratagem(name: "EMS Mortar Sentry", sequence: [.down, .down, .up, .up, .left]),
    Stratagem(name: "Reinforce", sequence: [.up, .down, .right, .left, .up]),
    Stratagem(name: "SOS Beacon", sequence: [.up, .down, .right, .up]),
    Stratagem(name: "Super Earth Flag", sequence: [.down, .up, .down, .up]),
    Stratagem(name: "Upload Data", sequence: [.left, .right, .up, .up, .up]),
    Stratagem(name: "Hellbomb", sequence: [.down, .up, .left, .down, .up, .right, .down, .up])
]
