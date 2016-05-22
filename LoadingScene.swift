//
//  LoadingScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/05/16.
//
//

import SpriteKit

@objc protocol LoadingSceneDelegate: SKSceneDelegate {
    func loadingSceneDidMoveToView(scene: LoadingScene, view: SKView)
    func loadingSceneDidFinishLoading()
}

class LoadingScene: SKScene {
    let titleNode = SKLabelNode()
    let messageNode = SKLabelNode()
    let percentageNode = SKLabelNode()
    
    // Work around to set the subclass delegate.
    var loadingSceneDelegate: LoadingSceneDelegate? {
        get { return self.delegate as? LoadingSceneDelegate }
        set { self.delegate = newValue }
    }
    
    init(size: CGSize, loadingSceneDelegate: LoadingSceneDelegate?) {
        super.init(size: size)
        
        self.loadingSceneDelegate = loadingSceneDelegate
        
        let yOffset = (size.height / 4)
        
        self.titleNode.text = "Loading Assets"
        self.titleNode.position = CGPoint(x: size.width / 2, y: yOffset * 3)
        addChild(self.titleNode)
        
        self.messageNode.text = "-"
        self.messageNode.position = CGPoint(x: size.width / 2, y: yOffset * 2)
        addChild(self.messageNode)
        
        self.percentageNode.text = "0 %"
        self.percentageNode.position = CGPoint(x: size.width / 2, y: yOffset * 1)
        addChild(self.percentageNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func didMoveToView(view: SKView) {
        if let delegate = self.loadingSceneDelegate {
            delegate.loadingSceneDidMoveToView(self, view: view)
        }
    }
    
    func updateAssetsIfNeeded() throws {
        let url = NSURL(string: "https://dl.dropboxusercontent.com/s/s1mere2vjgcbu0t/assets.zip")!
        
        if let remoteEtag = try AssetManager.sharedInstance.etagForRemoteAssetsArchive(url) {
            let localEtag = AssetManager.sharedInstance.etagForLocalAssetsArchive()
            if remoteEtag != localEtag {
                try AssetManager.sharedInstance.loadAssets(url, completion: { (success, error) in
                    if success {
                        AssetManager.sharedInstance.storeEtagForLocalAssetsArchive(remoteEtag)
                    } else {
                        print("error: \(error)")
                    }
                    
                    if let delegate = self.loadingSceneDelegate {
                        delegate.loadingSceneDidFinishLoading()
                    }
                })
            } else {
                if let delegate = self.loadingSceneDelegate {
                    delegate.loadingSceneDidFinishLoading()
                }            
            }
        }
    }
}