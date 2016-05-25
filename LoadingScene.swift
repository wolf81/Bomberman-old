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

class LoadingScene: SKScene, AssetManagerDelegate {
    let assetManager = AssetManager()
    let titleNode = SKLabelNode()
    let messageNode = SKLabelNode()
    let percentageNode = SKLabelNode()
    
    var remoteEtag: String?
    
    // Work around to set the subclass delegate.
    var loadingSceneDelegate: LoadingSceneDelegate? {
        get { return self.delegate as? LoadingSceneDelegate }
        set { self.delegate = newValue }
    }
    
    init(size: CGSize, loadingSceneDelegate: LoadingSceneDelegate?) {
        super.init(size: size)
        
        self.loadingSceneDelegate = loadingSceneDelegate
        
        self.assetManager.delegate = self
        
        let yOffset = (size.height / 4)
        
        self.titleNode.text = "Loading"
        self.titleNode.position = CGPoint(x: size.width / 2, y: yOffset * 3)
        addChild(self.titleNode)
        
        self.messageNode.text = "-"
        self.messageNode.position = CGPoint(x: size.width / 2, y: yOffset * 2)
        addChild(self.messageNode)
        
        self.percentageNode.position = CGPoint(x: size.width / 2, y: yOffset * 1)
        addChild(self.percentageNode)
        
        updateProgress(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func didMoveToView(view: SKView) {
        self.loadingSceneDelegate?.loadingSceneDidMoveToView(self, view: view)
    }
    
    func updateAssetsIfNeeded() throws {
        let url = NSURL(string: "https://dl.dropboxusercontent.com/s/s1mere2vjgcbu0t/assets.zip")!
        
        self.messageNode.text = "Checking for updated assets ..."
        
        self.remoteEtag = try assetManager.etagForRemoteAssetsArchive(url)
        let localEtag = assetManager.etagForLocalAssetsArchive()
        
        if self.remoteEtag != localEtag {
            self.messageNode.text = "Loading updated assets ..."
            
            self.assetManager.loadAssets(url)
        } else {
            self.loadingSceneDelegate?.loadingSceneDidFinishLoading()
        }
    }
    
    func assetManagerLoadAssetsProgress(assetManager: AssetManager, progress: Float) {
        updateProgress(progress)
    }
    
    func assetManagerLoadAssetsFailure(assetManager: AssetManager, error: ErrorType) {
        self.loadingSceneDelegate?.loadingSceneDidFinishLoading()
    }

    func assetManagerLoadAssetsSuccess(assetManager: AssetManager) {
        updateProgress(1.0)

        if let remoteEtag = self.remoteEtag {
            self.assetManager.storeEtagForLocalAssetsArchive(remoteEtag)
        }

        delay(0.5) {
            self.loadingSceneDelegate?.loadingSceneDidFinishLoading()
        }
    }
    
    // MARK: - Private
    
    func updateProgress(progress: Float) {
        let percentageString = String(format: "%.0f", progress * 100)
        self.percentageNode.text = String("\(percentageString) %")
    }
}