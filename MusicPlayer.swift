//
//  MusicPlayer.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 20/07/16.
//
//

/*
 * TODO: Improvements for the MusicPlayer class.
 *  - Loading files and playing music should be seperated into 2 functions.
 *  - After stop() is called, resume() should actually have the same result as play()
 *  - After pause() is called, resume() should continue from the last paused moment in the song.
 *  - Consider removing resume() and let play() automatically do the right thing.
 */

import AVFoundation

class MusicPlayer {
    static let sharedInstance = MusicPlayer()
    
    fileprivate var audioPlayer: AVAudioPlayer?
    fileprivate var fileManager: FileManager
    
    var isPlaying: Bool {
        var isPlaying = false
        
        if let audioPlayer = self.audioPlayer {
            isPlaying = audioPlayer.isPlaying
        }
        
        return isPlaying
    }
    
    // MARK: Private
    
    fileprivate init() {
        fileManager = FileManager.default
    }
    
    // MARK: - Public
    
    func playMusic(_ file: String) throws {
        stop()
        
        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: "Music") {
            let url = URL(fileURLWithPath: path)
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } else {
            // TODO: throw error - file not exists.
            print("failed to load file: \(file)")
        }
    }
    
    func fadeOut(_ duration: Double) {
        print("fadeOut start")
        
        if let audioPlayer = self.audioPlayer {
            let steps = Int(duration * 100.0)
            let volume = audioPlayer.volume
            
            for step in 0 ..< steps {
                let delay = Double(step) * (duration / Double(steps))
                
                let delta = delay * Double(NSEC_PER_SEC)
                let popTime = DispatchTime.now() + Double(Int64(delta)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
                    let fraction = Float(step) / Float(steps)
                    
                    audioPlayer.volume = volume + (0 - volume) * Float(fraction)
                    
                    print("fade ...")
                })
            }
        }
    }
    
    func resume() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.play()
        }
    }
    
    func pause() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.pause()
        }
    }
    
    func stop() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
    }
}
