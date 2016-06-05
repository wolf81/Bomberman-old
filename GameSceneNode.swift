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

        self.world = SKSpriteNode(texture: floorTexture, size: level.size())
        self.world.position = CGPoint(x: panelWidth, y: 0)
        self.world.anchorPoint = CGPointZero
        self.world.blendMode = .Replace
        
        // Create panel node.
        let panelSize = CGSizeMake(panelWidth, size.height)
        self.gameHud = GameHud(size: panelSize)
        self.gameHud.position = CGPoint(x: 0, y: 0)
        
        super.init()
        
        // We need to use the designated initializer, therefore we have to set a frame here by
        //  setting the path (we can not use init(withFrame) or similar method.
        let rect = CGRect(origin: CGPointZero, size: size)
        self.path = CGPathCreateWithRect(rect, nil)
        
        self.addChild(self.world)
        self.addChild(self.gameHud)
        
        self.blendMode = .Replace
        self.antialiased = false
        self.lineWidth = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func updateHudForPlayer(player: Player) {
        self.gameHud.updateForPlayer(player)
    }
    
    func updateTimeRemaining(timeRemaining: NSTimeInterval) {
        self.gameHud.updateTimeRemaining(timeRemaining)
    }
}