//
//  Indicator.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 14/08/16.
//
//

import SpriteKit

enum IndicatorDirection {
    case Left
    case Right
}

class Indicator : SKShapeNode {
    private(set) var direction: IndicatorDirection = .Left
    
    private var size: CGSize = CGSize()
    
    convenience init(direction: IndicatorDirection) {
        self.init(size: CGSize(width: 15, height: 20), direction: direction)
    }
    
    init(size: CGSize, direction: IndicatorDirection) {
        self.direction = direction
        self.size = size
        
        super.init()
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: - Private
    
    private func commonInit() {
        strokeColor = SKColor.whiteColor()
        fillColor = SKColor.whiteColor()
        
        var points: [(x: CGFloat, y: CGFloat)]
        
        switch direction {
        case .Left:
            points = [(size.width, size.height), (0, size.height / 2), (size.width, 0)]
        case .Right:
            points = [(0, size.height), (0, 0), (size.width, size.height / 2)]
        }
        
        self.path = pathForPoints(points)
    }
    
    private func pathForPoints(points: [(x: CGFloat, y: CGFloat)]) -> CGPath {
        let path = CGPathCreateMutable()
        
        for point in points {
            if point == points.first! {
                CGPathMoveToPoint(path, nil, point.x, point.y)
            } else {
                CGPathAddLineToPoint(path, nil, point.x, point.y)
            }
        }
        CGPathCloseSubpath(path)

        return path
    }
    
    // MARK: - Public
    
    func runScaleAnimation(fromValue: CGFloat, toValue: CGFloat) {
        assert(fromValue < toValue, "fromValue should be smaller than toValue")
        
        let scaleUp = SKAction.scaleTo(toValue, duration: 1.0)
        let scaleDown = SKAction.scaleTo(fromValue, duration: 1.0)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let scaleRepeat = SKAction.repeatActionForever(sequence)
        runAction(scaleRepeat)
    }
}