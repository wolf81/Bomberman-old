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
    
    init() {
        self.fileManager = NSFileManager.defaultManager()
    }
    
    func playMusic(file: String) throws {
        stop()
        
        if let path = try fileManager.pathForFile(file, inBundleSupportSubDirectory: "Music") {
            let url = NSURL(fileURLWithPath: path)
            try self.audioPlayer = AVAudioPlayer(contentsOfURL: url)
            self.audioPlayer?.numberOfLoops = -1
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        } else {
            // TODO: throw error - file not exists.
        }
    }
    
    func fadeOut(duration: Double) {
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
                })
            }
        }
    }
    
    func stop() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
    }
}
