//
//  LoadingScene.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 09/05/16.
//
//

import SpriteKit

@objc protocol LoadingSceneDelegate: SKSceneDelegate {
    func loadingSceneDidMoveToView(_ scene: LoadingScene, view: SKView)
    func loadingSceneDidFinishLoading(_ scene: LoadingScene)
}

class LoadingScene: SKScene {
    let assetManager = AssetManager()
    let titleLabel = SKLabelNode()
    let messageLabel = SKLabelNode()
    let percentageLabel = SKLabelNode()
    
    var remoteEtag: String?
    
    // Work-around to set the subclass delegate.
    var loadingSceneDelegate: LoadingSceneDelegate? {
        get { return delegate as? LoadingSceneDelegate }
        set { delegate = newValue }
    }
    
    init(size: CGSize, loadingSceneDelegate: LoadingSceneDelegate?) {
        super.init(size: size)
        
        self.loadingSceneDelegate = loadingSceneDelegate
        
        assetManager.delegate = self
        
        let y = size.height / 2

        titleLabel.text = "LOADING"
        titleLabel.position = CGPoint(x: size.width / 2, y: y + 100)
        addChild(titleLabel)
        
        messageLabel.text = "-"
        messageLabel.position = CGPoint(x: size.width / 2, y: y)
        addChild(messageLabel)
        
        percentageLabel.position = CGPoint(x: size.width / 2, y: y - 100)
        addChild(percentageLabel)
        
        updateProgress(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        loadingSceneDelegate?.loadingSceneDidMoveToView(self, view: view)
    }
    
    // MARK: - Public
    
    func updateAssetsIfNeeded() throws {
        if Settings.assetsCheckEnabled() {
            let url = URL(string: "https://dl.dropboxusercontent.com/s/i4en1xtkrxg8ccm/assets.zip")!
            
            messageLabel.text = "CHECKING FOR UPDATED ASSETS ..."
            
            remoteEtag = try assetManager.etagForRemoteAssetsArchive(url)
            let localEtag = assetManager.etagForLocalAssetsArchive()
            
            if remoteEtag != localEtag {
                messageLabel.text = "UPDATING ASSETS ..."
                
                assetManager.loadAssets(url)
            } else {
                loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
            }            
        } else {
            loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
        }
    }
    
    // MARK: - Private
    
    func updateProgress(_ progress: Float) {
        let percentageString = String(format: "%.0f", progress * 100)
        percentageLabel.text = String("\(percentageString) %")
    }
}

// MARK: - AssetManagerDelegate

extension LoadingScene : AssetManagerDelegate {
    func assetManagerLoadAssetsProgress(_ assetManager: AssetManager, progress: Float) {
        updateProgress(progress)
    }
    
    func assetManagerLoadAssetsFailure(_ assetManager: AssetManager, error: Error) {
        loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
    }
    
    func assetManagerLoadAssetsSuccess(_ assetManager: AssetManager) {
        updateProgress(1.0)
        
        if let etag = remoteEtag {
            assetManager.storeEtagForLocalAssetsArchive(etag)
        }
        
        delay(0.5) {
            self.loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
        }
    }
}
