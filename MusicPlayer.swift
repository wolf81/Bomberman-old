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
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
        
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
}
