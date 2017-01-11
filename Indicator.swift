//
//  Indicator.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 14/08/16.
//
//

import SpriteKit

enum IndicatorDirection {
    case left
    case right
}

class Indicator : SKShapeNode {
    fileprivate(set) var direction: IndicatorDirection = .left
    
    fileprivate(set) var size: CGSize = CGSize()
    
    convenience init(direction: IndicatorDirection) {
        self.init(size: CGSize(width: 10, height: 15), direction: direction)
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
    
    fileprivate func commonInit() {
        strokeColor = SKColor.white
        fillColor = SKColor.white
        
        var points: [(x: CGFloat, y: CGFloat)]
        
        switch direction {
        case .left:
            points = [(size.width, size.height), (0, size.height / 2), (size.width, 0)]
        case .right:
            points = [(0, size.height), (0, 0), (size.width, size.height / 2)]
        }
        
        self.path = pathForPoints(points)
    }
    
    fileprivate func pathForPoints(_ points: [(x: CGFloat, y: CGFloat)]) -> CGPath {
        let path = CGMutablePath()
        
        for point in points {
            if point == points.first! {
                path.move(to: CGPoint(x: point.x, y: point.y))
            } else {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }
        }
        path.closeSubpath()

        return path
    }
    
    // MARK: - Public
    
    func runScaleAnimation(_ fromValue: CGFloat, toValue: CGFloat) {
        assert(fromValue != toValue, "fromValue should be different from toValue")
        
        let scaleTo = SKAction.scale(to: toValue, duration: 1.0)
        let scaleFrom = SKAction.scale(to: fromValue, duration: 1.0)
        let sequence = SKAction.sequence([scaleTo, scaleFrom])
        let scaleRepeat = SKAction.repeatForever(sequence)
        run(scaleRepeat)
    }
}
