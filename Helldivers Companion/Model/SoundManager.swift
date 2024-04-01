//
//  SoundPoolManager.swift
//  Helldivers Companion
//
//  Created by James Poole on 01/04/2024.
//

import Foundation
import AVFoundation

class SoundPoolManager {
    static let shared = SoundPoolManager()
    
    private var soundPools: [String: [AVAudioPlayer]] = [:]
    private let maxPlayersPerSound = 8  // Adjust based on the maximum expected simultaneous sounds
    
    private var backgroundAudioPlayer: AVAudioPlayer?
    
    func preloadSound(soundName: String, withExtension ext: String = "m4a", isBackgroundMusic: Bool = false) {
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
        guard let players = soundPools[soundName] else {
            preloadSound(soundName: soundName)
            playSound(soundName: soundName, volume: volume)
            return
        }
        
        if let player = players.first(where: { !$0.isPlaying }) {
            player.volume = volume
            player.play()
        } else {
            // Optionally handle case when all players are busy (like stopping the earliest one)
        }
    }
    
    func playBackgroundSound() {

        backgroundAudioPlayer?.play()
       }

       func stopBackgroundSound() {
           backgroundAudioPlayer?.stop()
       }
    
    
}

