//
//  GameSceneNode.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 06/05/16.
//
//

import SpriteKit

class GameSceneNode: SKShapeNode {
    let world: SKSpriteNode
    let gameHud: GameHud

    init(withLevel level: Level) {
        let panelWidth: CGFloat = 300
        
        var size = level.size()
        size.width += panelWidth

        // Create world node.
        let tileSize = CGSize(width: unitLength, height: unitLength)
        
        // TODO: Clean-up floor tile loading - many chances for bugs when e.g. textures are missing
        let tileLoader = TileLoader(forGame: level.game)
        let floorTile = try! tileLoader.floorTextureForTheme(level.theme)
        let floorTexture = floorTile.tiledTextureWithSize(level.size(), tileSize: tileSize)

        world = SKSpriteNode(texture: floorTexture, size: level.size())
        world.position = CGPoint(x: panelWidth, y: 0)
        world.anchorPoint = CGPoint.zero
        world.blendMode = .replace
        
        // Create panel node.
        let panelSize = CGSize(width: panelWidth, height: size.height)
        gameHud = GameHud(size: panelSize)
        gameHud.position = CGPoint(x: 0, y: 0)
        gameHud.blendMode = .replace
        
        super.init()
        
        addChild(world)
        addChild(gameHud)

        // We need to use the designated initializer, therefore we have to set a frame here by
        //  setting the path (we can not use init(withFrame) or similar method.
        let rect = CGRect(origin: CGPoint.zero, size: size)
        path = CGPath(rect: rect, transform: nil)
        
        blendMode = .replace
        isAntialiased = false
        lineWidth = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func updateHudForPlayer(_ player: Player) {
        self.gameHud.updateForPlayer(player)
    }
    
    func updateTimeRemaining(_ timeRemaining: TimeInterval) {
        self.gameHud.updateTimeRemaining(timeRemaining)
    }
}
