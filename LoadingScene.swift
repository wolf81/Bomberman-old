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
    func loadingSceneDidFinishLoading(scene: LoadingScene)
}

class LoadingScene: SKScene, AssetManagerDelegate {
    let assetManager = AssetManager()
    let titleNode = SKLabelNode()
    let messageNode = SKLabelNode()
    let percentageNode = SKLabelNode()
    
    var remoteEtag: String?
    
    // Work around to set the subclass delegate.
    var loadingSceneDelegate: LoadingSceneDelegate? {
        get { return delegate as? LoadingSceneDelegate }
        set { delegate = newValue }
    }
    
    init(size: CGSize, loadingSceneDelegate: LoadingSceneDelegate?) {
        super.init(size: size)
        
        self.loadingSceneDelegate = loadingSceneDelegate
        
        assetManager.delegate = self
        
        let y = size.height / 2

        titleNode.text = "LOADING"
        titleNode.position = CGPoint(x: size.width / 2, y: y + 100)
        addChild(titleNode)
        
        messageNode.text = "-"
        messageNode.position = CGPoint(x: size.width / 2, y: y)
        addChild(messageNode)
        
        percentageNode.position = CGPoint(x: size.width / 2, y: y - 100)
        addChild(percentageNode)
        
        updateProgress(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        loadingSceneDelegate?.loadingSceneDidMoveToView(self, view: view)
    }
    
    func updateAssetsIfNeeded() throws {
        if Settings.assetsCheckEnabled() {
            let url = NSURL(string: "https://dl.dropboxusercontent.com/s/i4en1xtkrxg8ccm/assets.zip")!
            
            messageNode.text = "CHECKING FOR UPDATED ASSETS ..."
            
            remoteEtag = try assetManager.etagForRemoteAssetsArchive(url)
            let localEtag = assetManager.etagForLocalAssetsArchive()
            
            if remoteEtag != localEtag {
                messageNode.text = "UPDATING ASSETS ..."
                
                assetManager.loadAssets(url)
            } else {
                loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
            }            
        } else {
            loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
        }
    }
    
    func assetManagerLoadAssetsProgress(assetManager: AssetManager, progress: Float) {
        updateProgress(progress)
    }
    
    func assetManagerLoadAssetsFailure(assetManager: AssetManager, error: ErrorType) {
        loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
    }

    func assetManagerLoadAssetsSuccess(assetManager: AssetManager) {
        updateProgress(1.0)

        if let etag = remoteEtag {
            assetManager.storeEtagForLocalAssetsArchive(etag)
        }

        delay(0.5) {
            self.loadingSceneDelegate?.loadingSceneDidFinishLoading(self)
        }
    }
    
    // MARK: - Private
    
    func updateProgress(progress: Float) {
        let percentageString = String(format: "%.0f", progress * 100)
        percentageNode.text = String("\(percentageString) %")
    }
}