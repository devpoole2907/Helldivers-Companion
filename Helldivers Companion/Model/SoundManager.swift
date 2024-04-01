//
//  SoundPoolManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 01/04/2024.
//

import Foundation
import AVFoundation
import SwiftUI

class SoundPoolManager {
    static let shared = SoundPoolManager()
    
    private var soundPools: [String: [AVAudioPlayer]] = [:]
    private let maxPlayersPerSound = 8  // Adjust based on the maximum expected simultaneous sounds
    
    private var backgroundAudioPlayer: AVAudioPlayer?
    
    @AppStorage("enableGameSound") var enableSound = true
    
    // preload sounds, watches really struggle with sound loading
    // has completion, so ui can update (will say loading assets...)
    
    
    
    func preloadAllSounds(completion: @escaping () -> Void) {
        
        // loaded on main thread, causes longer initial app load on the watch but worth it to "obscure" the loading of the sounds
        self.preloadSound(soundName: "Stratagem Hero Input Sound")
#if os(watchOS)
        self.preloadSound(soundName: "Stratagem Hero Error Sound Apple Watch")
        
        self.preloadSound(soundName: "Stratagem Hero Success Sound Apple Watch")
  
        #endif
        
        
        // technically the loading assets screen should never be seen now because nothing is called before the completion in the background
        DispatchQueue.main.async {
                   completion()
               }
     
        // these are loaded on background thread
        DispatchQueue.global(qos: .background).async {

          
#if os(watchOS)
            // load round end sound after completion, reduces loading assets load time and ideally the sound will have loaded by the end of the round
            // if it hasnt, slight hitch, but a small price to pay
            self.preloadSound(soundName: "Stratagem Hero Round End Sound Apple Watch")
            
            // round start sound specifically does not play on round 1 starting, this ensures this sound is not needed yet to allow quicker load times so we can do this after completion called
            self.preloadSound(soundName: "Stratagem Hero Round Start Sound Apple Watch")
#endif
        }
        
        }
    
    func preloadSound(soundName: String, withExtension ext: String = "mp3", isBackgroundMusic: Bool = false) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else { return }
        
        if isBackgroundMusic {
            
            do {
                            let player = try AVAudioPlayer(contentsOf: url)
                            player.numberOfLoops = -1 // loop indefinitely for background music
                            player.prepareToPlay()
                            backgroundAudioPlayer = player
                        } catch {
                            print("Could not load background music file: \(soundName)")
                        }
            
        }
        
        else {
        var players = [AVAudioPlayer]()
        for _ in 0..<maxPlayersPerSound {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players.append(player)
            } catch {
                print("Could not load sound file: \(soundName)")
            }
        }
        soundPools[soundName] = players
    }
    }
    
    func playSound(soundName: String, volume: Float = 1.0) {
        if enableSound {
        guard let players = soundPools[soundName] else {
            preloadSound(soundName: soundName)
            playSound(soundName: soundName, volume: volume)
            return
        }
        
        if let player = players.first(where: { !$0.isPlaying }) {
            player.volume = volume
            player.play()
        } else {
            // could handle case when all players are busy (like stopping earliest one)
        }
        
    }
    }
    
    func playBackgroundSound() {

        backgroundAudioPlayer?.play()
       }

       func stopBackgroundSound() {
           backgroundAudioPlayer?.stop()
       }
    
    
}

