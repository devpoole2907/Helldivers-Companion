//
//  StratagemHeroModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import Foundation
import SwiftUI
import WatchConnectivity
#if os(iOS)
import GameKit
#endif

import AVFoundation

class StratagemHeroModel: ObservableObject {
    @Published var currentStratagem: Stratagem?
    @Published var inputSequence: [StratagemInput] = []
    @Published var timeRemaining: Double = 10
    @Published var gameState: GameState = .notStarted
    @Published var showError = false
    
    // mutes sounds
    @Published var enableSound = true
    
    @AppStorage("gameEndCount") var gameEndCount = 0
    
    // tracks times this screen is viewed
    @AppStorage("gameViewCount") var viewCount = 0
    
    #if os(iOS)
    @Published var topScores: [GKLeaderboard.Entry] = []
    #endif
   
    // used on watchos, display a sheet with interactive dismiss disabled so the gestures for playing dont interact with the tab view
    #if os(watchOS)
    @Published var showGameSheet = false
    @Published var showArrow = false
    @Published var swipeDirection: SwipeDirection = .none
    @Published var arrowOffset: CGSize = .zero
    @Published var arrows: [Arrow] = []
    #endif
    
    #if os(iOS)
    let gameCenterManager = GameCenterManager()
    let leaderboardId = "com.poole.james.helldiverscompanion.highscores"
    #endif
    
    // for sending high scores between watch and ios
    let watchConnectivity = WatchConnectivityProvider.shared
    
    
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
    
    // for sound effects
    
    // for background music
    private var backgroundAudioPlayer: AVAudioPlayer?
    
    private var audioPlayers: [AVAudioPlayer] = []
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
           if let index = audioPlayers.firstIndex(of: player) {
               audioPlayers.remove(at: index)
           }
       }

    init() {
        loadStratagems(forRound: currentRound)
        prepareAudioPlayer()
        
    }
    
    private func prepareAudioPlayer() {
            // Set the audio session category
            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    
    func playBackgroundSound() {
        if enableSound {
            guard let url = Bundle.main.url(forResource: "Stratagem Hero Game Music", withExtension: "mp3") else { return }
            
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.numberOfLoops = -1 // Loop indefinitely
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                backgroundAudioPlayer = audioPlayer
            } catch {
                print("Could not load or play the sound file.")
            }
        }
    }

       func stopBackgroundSound() {
           backgroundAudioPlayer?.stop()
           backgroundAudioPlayer = nil // Optionally reset the player
       }
    
    // for swipe gestures on watch
    #if os(watchOS)
    enum SwipeDirection {
            case up, down, left, right, none
        }
    
    struct Arrow: Identifiable {
        var id = UUID()
            var direction: SwipeDirection
        var offset: CGSize = .zero
        var opacity: Double = 0.4
        }
    
    func moveArrow(id: UUID, to offset: CGSize) {
           guard let index = arrows.firstIndex(where: { $0.id == id }) else { return }
           arrows[index].offset = offset
       }

       func fadeOutArrow(id: UUID) {
           guard let index = arrows.firstIndex(where: { $0.id == id }) else { return }
           arrows[index].opacity = 0.0
       }

       func removeArrow(id: UUID) {
           arrows.removeAll { $0.id == id }
       }
    
    func arrowName(for direction: SwipeDirection) -> String {
           switch direction {
               case .up: return "arrowshape.up.fill"
               case .down: return "arrowshape.down.fill"
               case .left: return "arrowshape.left.fill"
               case .right: return "arrowshape.right.fill"
               case .none: return ""
           }
       }
    
    
     func determineDirection(from translation: CGSize) -> SwipeDirection {
            if abs(translation.width) > abs(translation.height) {
                return translation.width < 0 ? .left : .right
            } else {
                return translation.height < 0 ? .up : .down
            }
        }

         func movementOffset(for direction: SwipeDirection) -> CGSize {
            switch direction {
                case .up: return CGSize(width: 0, height: -100)
                case .down: return CGSize(width: 0, height: 100)
                case .left: return CGSize(width: -100, height: 0)
                case .right: return CGSize(width: 100, height: 0)
                case .none: return CGSize()
            }
        }
    
    func addArrow(direction: SwipeDirection) {
            let arrow = Arrow(direction: direction)
            arrows.append(arrow)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let index = self.arrows.firstIndex(where: { $0.direction == direction && $0.offset == .zero }) {
                    self.arrows.remove(at: index)
                }
            }
        }
    
    #endif
    
    #if os(iOS)
    // Assuming `gameCenterManager` is already initialized and available
    func updateHighScore() {
        gameCenterManager.fetchHighScore(leaderboardId: leaderboardId) { [weak self] fetchedHighScore in
            DispatchQueue.main.async {
                if fetchedHighScore > self?.highScore ?? 0 {
                    self?.highScore = fetchedHighScore
                }
            }
        }
    }
    #endif
    
    func startGame() {
        
        currentRound = 1
        stratagemsPerRound = 6
        loadStratagems(forRound: currentRound)
        
        withAnimation {
            gameState = .roundStarting
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

            self.nextStratagem()
            self.startTimer()
            withAnimation {
                self.gameState = .started
            }
            self.playBackgroundSound()
        }
       
       
        }
    
    func stopGame() {
        totalScore = 0 // clear total score
        withAnimation {
            gameState = .notStarted
        }
        
        // to count every 3 games to give 50% chance of showing tips sheet
        gameEndCount += 1
        
    }
    
    enum GameState {
        
        case started
        case notStarted
        case roundEnded
        case roundStarting
        case gameOver
        
    }
    
    func playSound(soundName: String, volume: Float = 1.0) {
        if enableSound {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = volume
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            // Add the player to the array to keep it alive
            audioPlayers.append(audioPlayer)
            
            // Clean up audio players that have finished playing
            audioPlayers = audioPlayers.filter { $0.isPlaying }
        } catch {
            print("Could not load or play the sound file.")
        }
    }
       }
    
    func buttonInput(input: StratagemInput) {
        
     //   SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Input Sound", volume: 0.5)
        
        // the watch cant handle these sounds
        
        #if os(iOS)
        playSound(soundName: "Stratagem Hero Input Sound", volume: 0.3)
        #endif
        
        if gameState == .roundStarting {
            // do nothing
        } else if gameState == .gameOver {
            stopGame()
        }
        else if gameState == .notStarted {
            // show the game sheet if on watch
            #if os(watchOS)
            if gameState == .notStarted {
                showGameSheet = true
            } else {
                // show round start with instructions to swipe the directions of arrows
                withAnimation {
                    gameState = .roundStarting
                }
            }
            #endif
            
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
        
        stopBackgroundSound()
        
        playSound(soundName: "Stratagem Hero Round End Sound")
        
        self.timer?.invalidate()
        self.timer = nil
      
        #if os(iOS)

        Task {
            recordHighScore()
            self.topScores = await gameCenterManager.loadTopScores(leaderboardID: leaderboardId, count: 3)
            withAnimation {
                gameState = .gameOver
            }
        }
        #else
        withAnimation {
            recordHighScore()
            gameState = .gameOver
        }
        #endif
        
       

    }
    
    func recordHighScore() {
        if totalScore > highScore {
            highScore = totalScore
        }
        #if os(iOS)
        // report high score to game center leaderboard
        gameCenterManager.reportScore(score: highScore, leaderboardID: leaderboardId)
        #endif
        if WCSession.isSupported() {
            watchConnectivity.sendHighScore(highScore: highScore)
        }
    }
    
    func endRound() {
        
        stopBackgroundSound()
        
        audioPlayers = audioPlayers.filter { $0.isPlaying }
        
        playSound(soundName: "Stratagem Hero Round End Sound")
        
        withAnimation {
            gameState = .roundEnded
        }
        
        totalScore += roundScore + roundBonus + timeBonus + perfectBonus

        
        self.timer?.invalidate()
        self.timer = nil
        
        recordHighScore()
        
    }
    
    func startNextRound() {
        currentRound += 1
        stratagemsPerRound += 1
        loadStratagems(forRound: currentRound)
        nextStratagem()
        
        
        withAnimation {
            gameState = .roundStarting
        }
        
        playSound(soundName: "Stratagem Hero Round Start Sound")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // reset scores
            self.roundScore = 0
            self.roundBonus = 0
            self.timeBonus = 0
            self.perfectBonus = 0
            self.startTimer()
            withAnimation {
                self.gameState = .started
            }
            
            self.playBackgroundSound()
            
        }
    }

    func nextStratagem() {
        
        
        if let stratagem = stratagems.first {
            withAnimation(.bouncy) {
            currentStratagem = stratagem
                stratagems.removeFirst()
            }
            
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
            if timeRemaining + 2 > 10 {
                timeRemaining = 10
            } else {
                timeRemaining += 2
            }
                   let stratagemScore = currentStratagem.sequence.count * 10
                   roundScore += stratagemScore

                   // Update total score live
                   totalScore += stratagemScore
                   if inputSequence.count == currentStratagem.sequence.count {
                      
                       perfectBonus += perfectBonusPoints
                       totalScore += perfectBonusPoints
                   }

            
            playSound(soundName: "Stratagem Hero Success Sound")
            
            // game score added per correct stratagem
            nextStratagem()
        } else if !currentStratagem.sequence.starts(with: inputSequence) {
            // wrong sequence
            inputSequence = []
            showError = true //
            
            playSound(soundName: "Stratagem Hero Error Sound")
            
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
    Stratagem(name: "Autocannon", sequence: [.down, .left, .down, .up, .up, .right]),
    Stratagem(name: "Railgun", sequence: [.down, .right, .down, .up, .left, .right]),
    Stratagem(name: "Spear", sequence: [.down, .down, .up, .down, .down]),
    Stratagem(name: "Orbital Gatling Barrage", sequence: [.right, .down, .left, .up, .up]),
    Stratagem(name: "Orbital Airburst Strike", sequence: [.right, .right, .right]),
    Stratagem(name: "Orbital 120MM HE Barrage", sequence: [.right, .right, .down, .left, .right, .down]),
    Stratagem(name: "Orbital 380MM HE Barrage", sequence: [.right, .down, .up, .up, .left, .down, .down]),
    Stratagem(name: "Orbital Walking Barrage", sequence: [.right, .down, .right, .down, .right, .down]),
    Stratagem(name: "Orbital Laser Strike", sequence: [.right, .down, .up, .right, .down]),
    Stratagem(name: "Orbital Railcannon Strike", sequence: [.right, .up, .down, .down, .right]),
    Stratagem(name: "Eagle Strafing Run", sequence: [.up, .right, .right]),
    Stratagem(name: "Eagle Airstrike", sequence: [.up, .right, .down, .right]),
    Stratagem(name: "Eagle Cluster Bomb", sequence: [.up, .right, .down, .down, .right]),
    Stratagem(name: "Eagle Napalm Airstrike", sequence: [.up, .right, .down, .up]),
    Stratagem(name: "Jump Pack", sequence: [.down, .up, .up, .down, .up]),
    Stratagem(name: "Eagle Smoke Strike", sequence: [.up, .right, .up, .down]),
    Stratagem(name: "Eagle 110MM Rocket Pods", sequence: [.up, .right, .up, .left]),
    Stratagem(name: "Eagle 500KG Bomb", sequence: [.up, .right, .down, .down, .down]),
    Stratagem(name: "Orbital Precision Strike", sequence: [.right, .right, .up]),
    Stratagem(name: "Orbital Gas Strike", sequence: [.right, .right, .down, .right]),
    Stratagem(name: "Orbital EMS Strike", sequence: [.right, .right, .left, .down]),
    Stratagem(name: "Orbital Smoke Strike", sequence: [.right, .right, .down, .up]),
    Stratagem(name: "HMG Emplacement", sequence: [.down, .up, .left, .right, .right, .left]),
    Stratagem(name: "Shield Generator Relay", sequence: [.down, .down, .left, .right, .left, .right]),
    Stratagem(name: "Tesla Tower", sequence: [.down, .up, .right, .up, .left, .right]),
    Stratagem(name: "Anti-Personnel Minefield", sequence: [.down, .left, .up, .right]),
    Stratagem(name: "Supply Pack", sequence: [.down, .left, .down, .up, .up, .down]),
    Stratagem(name: "Grenade Launcher", sequence: [.down, .left, .up, .left, .down]),
    Stratagem(name: "Laser Cannon", sequence: [.down, .left, .down, .up, .left]),
    Stratagem(name: "Incendiary Mines", sequence: [.down, .left, .left, .down]),
    Stratagem(name: "Guard Dog Rover", sequence: [.down, .up, .left, .up, .right, .right]),
    Stratagem(name: "Ballistic Shield Backpack", sequence: [.down, .left, .down, .down, .up, .left]),
    Stratagem(name: "Arc Thrower", sequence: [.down, .right, .down, .up, .left, .left]),
    Stratagem(name: "Shield Generator Pack", sequence: [.down, .up, .left, .right, .left, .right]),
    Stratagem(name: "Machine Gun Sentry", sequence: [.down, .up, .right, .right, .up]),
    Stratagem(name: "Gatling Sentry", sequence: [.down, .up, .right, .left]),
    Stratagem(name: "Mortar Sentry", sequence: [.down, .up, .right, .right, .down]),
    Stratagem(name: "Guard Dog", sequence: [.down, .up, .left, .up, .right, .down]),
    Stratagem(name: "Autocannon Sentry", sequence: [.down, .up, .right, .up, .left, .up]),
    Stratagem(name: "Rocket Sentry", sequence: [.down, .up, .right, .right, .left]),
    Stratagem(name: "EMS Mortar Sentry", sequence: [.down, .up, .right, .down, .right]),
    Stratagem(name: "Reinforce", sequence: [.up, .down, .right, .left, .up]),
    Stratagem(name: "SOS Beacon", sequence: [.up, .down, .right, .up]),
    Stratagem(name: "Super Earth Flag", sequence: [.down, .up, .down, .up]),
    Stratagem(name: "Upload Data", sequence: [.left, .right, .up, .up, .up]),
    Stratagem(name: "Hellbomb", sequence: [.down, .up, .left, .down, .up, .right, .down, .up]),
    Stratagem(name: "Patriot Exosuit", sequence: [.left, .down, .right, .up, .left, .down, .down]),
    Stratagem(name: "Quasar Cannon", sequence: [.down, .down, .up, .left, .right]),
    Stratagem(name: "Heavy Machine Gun", sequence: [.down, .left, .up, .down, .down])
]
