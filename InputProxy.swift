//
//  InputProxy.swift
//  Bomberman
//
//  Created by Wolfgang Schreurs on 08/08/16.
//
//

/*
 * Used to route all controller input to the current visible scene. We keep a weak reference to the
 * current scene, which needs to be updated each time the scene changes. Controller input is 
 * forwarded to the referenced scene. 
 *
 * Some properties of input handling can be modified here. In particular we can configure the proxy
 * class to automatically release a direction button after each press. By setting this property to 
 * true way we can navigate we can navigate through the menus of the game by a single directional 
 * press at a time.
 */

// NOTE: If we encounter performance issues, perhaps we can use the @inline(__always) attribute on
//  some functions. These functions will likely be called many times per second. Reducing function
//  calls might improve performance.@inline(__always)

import SpriteKit
import GameController

class InputProxy {
    static let sharedInstance = InputProxy()

    weak var scene: BaseScene?
    
    private var directionPressed = false
    
    var autoDirectionPressRelease = false
    
    // MARK: - GameController suppport    
    
    #if os(tvOS)
    
    func configureController(controller: GCController, forPlayer player: GCControllerPlayerIndex) {
        controller.playerIndex = player
        
        controller.controllerPausedHandler = { [unowned self] _ in
            self.handlePausePress()
        }
        
        let playerIndex: PlayerIndex = player == .Index1 ? .Player1 : .Player2
        if let profile = controller.microGamepad {
            profile.allowsRotation = true
            profile.reportsAbsoluteDpadValues = true
            profile.buttonX.pressedChangedHandler = { _, value, pressed in
                if let scene = self.scene {
                    self.handleActionPressReleaseForPlayer(playerIndex, scene: scene, pressed: pressed)
                }
            }
            
            profile.dpad.valueChangedHandler = { _, xValue, yValue in
                if let scene = self.scene {
                    self.handleDpadValueChangedForPlayer(.Player1, scene: scene, xValue: xValue, yValue: yValue, centerOffset: 0.25)
                }
            }
        } else if let profile = controller.gamepad {
            profile.dpad.valueChangedHandler = { _, xValue, yValue in
                if let scene = self.scene {
                    self.handleDpadValueChangedForPlayer(.Player1, scene: scene, xValue: xValue, yValue: yValue, centerOffset: 0.10)
                }
            }
            
            profile.buttonA.pressedChangedHandler = { _, value, pressed in
                if let scene = self.scene {
                    self.handleActionPressReleaseForPlayer(playerIndex, scene: scene, pressed: pressed)
                }
            }
        }
    }
    
    #else
    
    func configureController(controller: GCController, forPlayer player: GCControllerPlayerIndex) {
        controller.playerIndex = player
        
        controller.controllerPausedHandler = { [unowned self] _ in
            self.handlePausePress()
        }
        
        if let dpad = controller.gamepad?.dpad {
            dpad.valueChangedHandler = { _, xValue, yValue in
                if let scene = self.scene {
                    self.handleDpadValueChangedForPlayer(.Player1, scene: scene, xValue: xValue, yValue: yValue, centerOffset: 0.10)
                }
            }
        }
        
        if let buttonA = controller.gamepad?.buttonA {
            buttonA.pressedChangedHandler = { _, value, pressed in
                if let scene = self.scene {
                    self.handleActionPressReleaseForPlayer(.Player1, scene: scene, pressed: pressed)
                }
            }
        }
        
        if let buttonX = controller.gamepad?.buttonX {
            buttonX.pressedChangedHandler = { _, value, pressed in
                if let scene = self.scene {
                    self.handleActionPressReleaseForPlayer(.Player1, scene: scene, pressed: pressed)
                }
            }
        }
    }
    
    #endif
    
    // MARK: - Private
    
    private func handleDpadValueChangedForPlayer(player: PlayerIndex, scene: BaseScene, xValue: Float, yValue: Float, centerOffset: Float) {
        if self.autoDirectionPressRelease {
            if fabs(xValue) < centerOffset && fabs(yValue) < centerOffset {
                self.directionPressed = false
            } else if !self.directionPressed {
                self.directionPressed = true
                
                handleDirectionalButtonPressForPlayer(player, scene: scene, xValue: xValue, yValue: yValue)
            }
        } else {
            if fabs(xValue) < centerOffset && fabs(yValue) < centerOffset {
                releaseDirectionalButtonsForPlayer(player, scene: scene)
            } else if !self.directionPressed {
                handleDirectionalButtonPressForPlayer(player, scene: scene, xValue: xValue, yValue: yValue)
            }
        }
    }
    
    private func handleDirectionalButtonPressForPlayer(player: PlayerIndex, scene: BaseScene, xValue: Float, yValue: Float) {
        if fabs(xValue) > fabs(yValue) {
            if xValue > 0 {
                scene.handleRightPress(forPlayer: player)
            } else {
                scene.handleLeftPress(forPlayer: player)
            }
        } else {
            if yValue > 0 {
                scene.handleUpPress(forPlayer: player)
            } else {
                scene.handleDownPress(forPlayer: player)
            }
        }
    }
    
    private func handleActionPressReleaseForPlayer(player: PlayerIndex, scene: BaseScene, pressed: Bool) {
        if pressed {
            scene.handleActionPress(forPlayer: .Player1)
        }
    }
    
    private func releaseDirectionalButtonsForPlayer(player: PlayerIndex, scene: BaseScene) {
        scene.handleRightRelease(forPlayer: player)
        scene.handleLeftRelease(forPlayer: player)
        scene.handleUpRelease(forPlayer: player)
        scene.handleDownRelease(forPlayer: player)
    }
    
    private func handlePausePress() {
        self.scene?.handlePausePress(forPlayer: .Player1)
    }
}