//
//  StratagemHeroModel.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import Foundation
import SwiftUI
import WatchConnectivity
import WidgetKit
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
    
    @Published var showGlossary = false
    
    @Published var selectedStratagems: [Stratagem] = globalStratagems {
        didSet {
            saveStratagems() // to persist across launches
        }
    }
    
    var dashPatterns: [UUID: [CGFloat]] = [:]  // dict to store dash patterns indexed by stratagem.id for the row backgrounds
    
    // mutes sounds
    @AppStorage("enableGameSound") var enableSound = true
    
    // for watch os to determine if game sound loaded yet
    @Published var isPreLoadingDone = false
    
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
    
    // to determine if custom stratagems are selected
     var isCustomGame: Bool {
        
        selectedStratagems.count != globalStratagems.count
        
    }
    
    @Published var roundScore: Int = 0
        @Published var roundBonus: Int = 0
        @Published var timeBonus: Int = 0
        @Published var perfectBonus: Int = 0
        @Published var totalScore: Int = 0
    
    @AppStorage("highScore") var highScore = 0 {
        didSet {
            if #available(watchOS 9.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                // Fallback on earlier versions
            }
        }
    }// store high score
    
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
        

            
        self.updateStratagemsIfNeeded { 
                
            self.loadAndInitializeStratagems {
                    
                self.loadSelectedStratagems()
                    
                }
            }
        
      //  loadStratagems(forRound: currentRound)
        // might be redundant now that we prep it in the sound manager
        prepareAudioPlayer()
    }
    
    // to load remotely saved new stratagems
    func loadAndInitializeStratagems(completion: @escaping () -> Void) {
        let savedStratagems = loadStratagemsFromUserDefaults()
        for stratagem in savedStratagems {
            if !globalStratagems.contains(where: { $0.name == stratagem.name }) {
                globalStratagems.append(stratagem)
            }
        }
        completion()
    }


    
    // to persist what stratagems are selected across launch
    
    func saveStratagems() {
            if let encoded = try? JSONEncoder().encode(selectedStratagems) {
                UserDefaults.standard.set(encoded, forKey: "SelectedStratagems")
            }
        }
    
    func loadSelectedStratagems() {
            if let stratagemsData = UserDefaults.standard.data(forKey: "SelectedStratagems"),
               let stratagems = try? JSONDecoder().decode([Stratagem].self, from: stratagemsData) {
                selectedStratagems = stratagems
            }
        }
    
    
    // for watchos to load assets before gameplay
    func preloadAssets() {
            SoundPoolManager.shared.preloadAllSounds {
                self.isPreLoadingDone = true
            }
        }
    
    private func prepareAudioPlayer() {
            // Set the audio session category
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        #else
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        #endif
        
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
    
    func dashPattern(for stratagem: Stratagem) -> [CGFloat] {
            if let pattern = dashPatterns[stratagem.id] {
                return pattern
            } else {
                // Create a new pattern if not exists
                let newPattern = [CGFloat.random(in: 50...70), CGFloat.random(in: 5...20)]
                dashPatterns[stratagem.id] = newPattern
                return newPattern
            }
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
        
        if #available(watchOS 10.0, *) {
            switch direction {
            case .up: return "arrowshape.up.fill"
            case .down: return "arrowshape.down.fill"
            case .left: return "arrowshape.left.fill"
            case .right: return "arrowshape.right.fill"
            case .none: return ""
            }
        } else {
            switch direction {
            case .up: return "arrowtriangle.up.fill"
            case .down: return "arrowtriangle.down.fill"
            case .left: return "arrowtriangle.left.fill"
            case .right: return "arrowtriangle.right.fill"
            case .none: return ""
            }
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
        
        #if os(watchOS)
        SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Input Sound", volume: 0.3)
        #endif
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
        
        let totalStratagems = stratagemsPerRound
        
        var loadedStratagems: [Stratagem] = []
            while loadedStratagems.count < totalStratagems {
                // shuffle and add to loaded list, repeat if needed to meet the stratagems per round number
                loadedStratagems += selectedStratagems.shuffled()
            }
        
        stratagems = Array(loadedStratagems.prefix(totalStratagems))
        }
    
    func gameOver() {
        
        stopBackgroundSound()
        
        #if os(iOS)
        playSound(soundName: "Stratagem Hero Round End Sound")
        #else
        SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Round End Sound Apple Watch")
        #endif
        
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
        
        if !isCustomGame { // dont set high score if its a custom game
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
    }
    
    func endRound() {
        
        stopBackgroundSound()
        
        audioPlayers = audioPlayers.filter { $0.isPlaying }
        
        #if os(iOS)
        playSound(soundName: "Stratagem Hero Round End Sound")
        #else
        SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Round End Sound Apple Watch")
        #endif
        
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
        
        #if os(iOS)
        playSound(soundName: "Stratagem Hero Round Start Sound")
        #else
        SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Round Start Sound Apple Watch")
        #endif
        
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

            #if os(iOS)
            playSound(soundName: "Stratagem Hero Success Sound")
            #else
            
            SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Success Sound Apple Watch")
            #endif
            // game score added per correct stratagem
            nextStratagem()
        } else if !currentStratagem.sequence.starts(with: inputSequence) {
            // wrong sequence
            inputSequence = []
            showError = true //
            
            #if os(iOS)
            playSound(soundName: "Stratagem Hero Error Sound")
            #else
            SoundPoolManager.shared.playSound(soundName: "Stratagem Hero Error Sound Apple Watch")
            #endif
            
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // flash red for 0.3 seconds when wrongly entered
                            self.showError = false
                        }
            
            withAnimation(.linear(duration: 0.3)) {
                arrowShakeTimes += 1 //  shake when entered wrong
            }
            
        }
    }
    
    // for adding additional stratagems remotely
    
    func fetchStratagems(completion: @escaping ([Stratagem]) -> Void) {
      
                
                guard let url = URL(string: "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/stratagems/newStratagems.json") else {
                        print("Invalid URL for image")
                    completion([])
                        return
                    }
                
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching stratagems: \(error!)")
                completion([])
                return
            }
            
            do {
                let stratagems = try JSONDecoder().decode([Stratagem].self, from: data)
                completion(stratagems)
            } catch {
                print("Error decoding stratagems: \(error)")
                completion([])
            }
        }
        task.resume()
    }

    func updateStratagemsIfNeeded(completion: @escaping () -> Void ) {
        fetchStratagems { [self] fetchedStratagems in
            var currentStratagems = loadStratagemsFromUserDefaults()
            
            print("updating stratagems")
            
            var isNewDataAvailable = false
            for stratagem in fetchedStratagems {
                if !currentStratagems.contains(where: { $0.name == stratagem.name }) {
                    print("adding stratagem: \(stratagem.name)")
                    downloadAndCacheImage(for: stratagem)
                    currentStratagems.append(stratagem)
                    isNewDataAvailable = true
                }
            }
            
            if isNewDataAvailable {
                saveStratagemsToUserDefaults(stratagems: currentStratagems)
            }
            
            completion()
            
        }
    }

    
    func downloadAndCacheImage(for stratagem: Stratagem) {
        guard let url = stratagem.imageUrl, let imageUrl = URL(string: url) else {
            print("Invalid URL for image")
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            guard let image = UIImage(data: data) else {
                print("Error decoding image data")
                return
            }
            CacheManager.cache(image: image, for: stratagem.name)
        }
        task.resume()
    }

    func saveStratagemsToUserDefaults(stratagems: [Stratagem]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(stratagems) {
            UserDefaults.standard.set(encoded, forKey: "stratagems")
        }
    }

    func loadStratagemsFromUserDefaults() -> [Stratagem] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "stratagems"),
           let stratagems = try? decoder.decode([Stratagem].self, from: data) {
            return stratagems
        }
        return []
    }

    
    
    
    
}

var globalStratagems: [Stratagem] = [
    Stratagem(name: "Machine Gun", sequence: [.down, .left, .down, .up, .right], type: .admin),
    Stratagem(name: "Airburst Rocket Launcher", sequence: [.down, .up, .up, .left, .right], type: .admin),
    Stratagem(name: "Anti-Materiel Rifle", sequence: [.down, .left, .right, .up, .down], type: .admin),
    Stratagem(name: "Stalwart", sequence: [.down, .left, .down, .up, .up, .left], type: .admin),
    Stratagem(name: "Expendable Anti-Tank", sequence: [.down, .down, .left, .up, .right], type: .admin),
    Stratagem(name: "Recoilless Rifle", sequence: [.down, .left, .right, .right, .left], type: .admin),
    Stratagem(name: "Flamethrower", sequence: [.down, .left, .up, .down, .up], type: .admin),
    Stratagem(name: "Autocannon", sequence: [.down, .left, .down, .up, .up, .right], type: .admin),
    Stratagem(name: "Railgun", sequence: [.down, .right, .down, .up, .left, .right], type: .admin),
    Stratagem(name: "Spear", sequence: [.down, .down, .up, .down, .down], type: .admin),
    Stratagem(name: "Orbital Gatling Barrage", sequence: [.right, .down, .left, .up, .up], type: .orbital),
    Stratagem(name: "Orbital Airburst Strike", sequence: [.right, .right, .right], type: .orbital),
    Stratagem(name: "Orbital 120MM HE Barrage", sequence: [.right, .right, .down, .left, .right, .down], type: .orbital),
    Stratagem(name: "Orbital 380MM HE Barrage", sequence: [.right, .down, .up, .up, .left, .down, .down], type: .orbital),
    Stratagem(name: "Orbital Walking Barrage", sequence: [.right, .down, .right, .down, .right, .down], type: .orbital),
    Stratagem(name: "Orbital Laser", sequence: [.right, .down, .up, .right, .down], type: .orbital),
    Stratagem(name: "Orbital Railcannon Strike", sequence: [.right, .up, .down, .down, .right], type: .orbital),
    Stratagem(name: "Eagle Strafing Run", sequence: [.up, .right, .right], type: .hangar),
    Stratagem(name: "Eagle Airstrike", sequence: [.up, .right, .down, .right], type: .hangar),
    Stratagem(name: "Eagle Cluster Bomb", sequence: [.up, .right, .down, .down, .right], type: .hangar),
    Stratagem(name: "Eagle Napalm Airstrike", sequence: [.up, .right, .down, .up], type: .hangar),
    Stratagem(name: "Jump Pack", sequence: [.down, .up, .up, .down, .up], type: .hangar),
    Stratagem(name: "Eagle Smoke Strike", sequence: [.up, .right, .up, .down], type: .hangar),
    Stratagem(name: "Eagle 110MM Rocket Pods", sequence: [.up, .right, .up, .left], type: .hangar),
    Stratagem(name: "Eagle 500KG Bomb", sequence: [.up, .right, .down, .down, .down], type: .hangar),
    Stratagem(name: "Orbital Precision Strike", sequence: [.right, .right, .up], type: .bridge),
    Stratagem(name: "Orbital Gas Strike", sequence: [.right, .right, .down, .right], type: .bridge),
    Stratagem(name: "Orbital EMS Strike", sequence: [.right, .right, .left, .down], type: .bridge),
    Stratagem(name: "Orbital Smoke Strike", sequence: [.right, .right, .down, .up], type: .bridge),
    Stratagem(name: "HMG Emplacement", sequence: [.down, .up, .left, .right, .right, .left], type: .bridge),
    Stratagem(name: "Shield Generator Relay", sequence: [.down, .down, .left, .right, .left, .right], type: .bridge),
    Stratagem(name: "Tesla Tower", sequence: [.down, .up, .right, .up, .left, .right], type: .bridge),
    Stratagem(name: "Anti-Personnel Minefield", sequence: [.down, .left, .up, .right], type: .engineering),
    Stratagem(name: "Supply Pack", sequence: [.down, .left, .down, .up, .up, .down], type: .engineering),
    Stratagem(name: "Grenade Launcher", sequence: [.down, .left, .up, .left, .down], type: .engineering),
    Stratagem(name: "Laser Cannon", sequence: [.down, .left, .down, .up, .left], type: .engineering),
    Stratagem(name: "Incendiary Mines", sequence: [.down, .left, .left, .down], type: .engineering),
    Stratagem(name: "Guard Dog Rover", sequence: [.down, .up, .left, .up, .right, .right], type: .engineering),
    Stratagem(name: "Ballistic Shield Backpack", sequence: [.down, .left, .down, .down, .up, .left], type: .engineering),
    Stratagem(name: "Arc Thrower", sequence: [.down, .right, .down, .up, .left, .left], type: .engineering),
    Stratagem(name: "Shield Generator Pack", sequence: [.down, .up, .left, .right, .left, .right], type: .engineering),
    Stratagem(name: "Machine Gun Sentry", sequence: [.down, .up, .right, .right, .up], type: .workshop),
    Stratagem(name: "Gatling Sentry", sequence: [.down, .up, .right, .left], type: .workshop),
    Stratagem(name: "Mortar Sentry", sequence: [.down, .up, .right, .right, .down], type: .workshop),
    Stratagem(name: "Guard Dog", sequence: [.down, .up, .left, .up, .right, .down], type: .workshop),
    Stratagem(name: "Autocannon Sentry", sequence: [.down, .up, .right, .up, .left, .up], type: .workshop),
    Stratagem(name: "Rocket Sentry", sequence: [.down, .up, .right, .right, .left], type: .workshop),
    Stratagem(name: "EMS Mortar Sentry", sequence: [.down, .up, .right, .down, .right], type: .workshop),
    Stratagem(name: "Reinforce", sequence: [.up, .down, .right, .left, .up], type: .mission),
    Stratagem(name: "SOS Beacon", sequence: [.up, .down, .right, .up], type: .mission),
    Stratagem(name: "Super Earth Flag", sequence: [.down, .up, .down, .up], type: .mission),
    Stratagem(name: "Upload Data", sequence: [.left, .right, .up, .up, .up], type: .mission),
    Stratagem(name: "Hellbomb", sequence: [.down, .up, .left, .down, .up, .right, .down, .up], type: .mission),
    Stratagem(name: "Patriot Exosuit", sequence: [.left, .down, .right, .up, .left, .down, .down], type: .workshop),
    Stratagem(name: "Quasar Cannon", sequence: [.down, .down, .up, .left, .right], type: .engineering),
    Stratagem(name: "Heavy Machine Gun", sequence: [.down, .left, .up, .down, .down], type: .admin),
    Stratagem(name: "Resupply", sequence: [.down, .down, .up, .right], type: .mission),
    Stratagem(name: "Prospecting Drill", sequence: [.down, .down, .left, .right, .down, .down], type: .mission),
    Stratagem(name: "Seismic Probe", sequence: [.up, .up, .left, .right, .down, .down], type: .mission),
    Stratagem(name: "SEAF Artillery", sequence: [.right, .up, .up, .down], type: .mission),
    Stratagem(name: "Orbital Illumination Flare", sequence: [.right, .right, .left, .left], type: .mission)
]



