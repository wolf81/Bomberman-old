//
//  MusicPlayer.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 20/07/16.
//
//

import AVFoundation

class MusicPlayer {
    static let sharedInstance = MusicPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    private var fileManager: NSFileManager
        
    var isPlaying: Bool {
        var isPlaying = false
        
        if let audioPlayer = self.audioPlayer {
            isPlaying = audioPlayer.playing
        }
        
        return isPlaying
    }
    
    init() {
        fileManager = NSFileManager.defaultManager()
    }
    
    func playMusic(file: String) throws {
        stop()
        
        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: "Music") {
            let url = NSURL(fileURLWithPath: path)
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } else {
            // TODO: throw error - file not exists.
            print("failed to load file: \(file)")
        }
    }
    
    func fadeOut(duration: Double) {
        print("fadeOut start")
        
        if let audioPlayer = self.audioPlayer {
            let steps = Int(duration * 100.0)
            let volume = audioPlayer.volume
            
            for step in 0 ..< steps {
                let delay = Double(step) * (duration / Double(steps))
                
                let delta = delay * Double(NSEC_PER_SEC)
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delta))
                dispatch_after(popTime, dispatch_get_main_queue(), {
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
