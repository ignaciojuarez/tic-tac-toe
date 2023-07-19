//  GameScene.swift
//
//  Created by Ignacio Juarez on 07/18/2023.
//
//  Usage: just works, no loading, startscreen or menuscreen and resets itself
//
//  Desc: simple tic-tac-toe
//
//  Func:
//  `sceneDidLoad` setup of game UI
//  `touchesEnded`& 'handleTouchOnCell' handle user touch and check for nodes (boardcells or reset button)
//  `showAlert` end-game user abstract (general purpose) alert -> either draw or win
//  `generateHapticFeedback` cool trick
//  ' extension UIColor ' cool trick to use your own hex UIcolors
//
//  --> I decided not to use GameStates and instead use Board.swift (GameStatus) enum  <--


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private enum CurrentPlayer { case X, O }
    private var gameBoard = Board()
    private var currentPlayer: CurrentPlayer = .X
    
    override func sceneDidLoad() {
        backgroundColor = UIColor(hex: "282C34") // cool
        setupGameTitle()
        setupGameBoard()
        setupResetButton()
        byIgnacio()
    }
    
    // MARK: - Setup UI -
    
    private func setupGameTitle() {
         let titleNode = SKLabelNode(text: "tic-tac-toe")
         titleNode.position = CGPoint(x: size.width / 2, y: size.height - 120)
         titleNode.fontName = "Gill Sans"
         titleNode.fontSize = 36
         titleNode.fontColor = .white
         addChild(titleNode)
     }
     
    private func setupGameBoard() {
        let boardSize = min(size.width, size.height) * 0.8
        let cellSize = boardSize * 1/3
        let offsetX = (size.width - boardSize) / 2
        let offsetY = (size.height - boardSize) / 2
        
        for row in 0..<3 {
            for col in 0..<3 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                cellNode.position = CGPoint(x: offsetX + CGFloat(col) * cellSize + cellSize / 2,
                                            y: offsetY + CGFloat(row) * cellSize + cellSize / 2)
                cellNode.fillColor = UIColor(hex: "2F3D4F")
                cellNode.strokeColor = .white
                cellNode.lineWidth = 3
                cellNode.name = "cell_\(row)_\(col)"
                addChild(cellNode)
            }
        }
    }
    
    private func setupResetButton() {
        let resetButton = SKLabelNode(text: "reset")
        resetButton.position = CGPoint(x: size.width / 2, y: 140)
        resetButton.fontSize = 28
        resetButton.fontColor = .white
        resetButton.name = "resetButton"
        resetButton.fontName = "Gill Sans"
        addChild(resetButton)
    }
    
    private func byIgnacio() {
        let resetButton = SKLabelNode(text: "by ignacio")
        resetButton.position = CGPoint(x: size.width / 2, y: 30)
        resetButton.fontSize = 24
        resetButton.fontColor = .white
        resetButton.name = "resetButton"
        resetButton.fontName = "Gill Sans"
        addChild(resetButton)
    }
    
    // MARK: - TouchSystems & GameManager -
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)

        for node in nodesAtLocation {
            if let cellNode = node as? SKShapeNode, cellNode.name?.contains("cell") ?? false {
                handleTouchOnCell(cellNode)
            } else if node.name == "resetButton" {
                resetGame()
            }
        }
    }
    
    private func handleTouchOnCell(_ node: SKShapeNode) {
        let parts = node.name!.components(separatedBy: "_")
        if parts.count == 3, let row = Int(parts[1]), let col = Int(parts[2]) {
            let index = row * 3 + col
            if gameBoard.isCellEmpty(index) {
                gameBoard.setCell(index, with: (currentPlayer == .X) ? .X : .O)
                let symbolNode = createSymbolNode()
                node.addChild(symbolNode)
                generateHapticFeedback(style: .medium)
                checkGameStatus()
            }
        }
    }
    
    private func createSymbolNode() -> SKSpriteNode {
        let symbolImageName = (currentPlayer == .X) ? "x-mark" : "o-mark"
        guard let symbolImage = UIImage(named: symbolImageName) else {
            fatalError("Could not find image \(symbolImageName) in assets")
        }
        let symbolTexture = SKTexture(image: symbolImage)
        let symbolNode = SKSpriteNode(texture: symbolTexture)
        symbolNode.size = CGSize(width: 30, height: 30)
        symbolNode.color = .white
        symbolNode.colorBlendFactor = 1.0
        return symbolNode
    }
    
    // MARK: - GameStatus & EndGame Alerts -
    
    private func checkGameStatus() {
        let gameStatus = gameBoard.checkGameStatus()
        
        switch gameStatus {
        case .playerXWin:
            showWinAlert(for: .X)
            resetGame()
        case .playerOWin:
            showWinAlert(for: .O)
            resetGame()
        case .draw:
            showDrawAlert()
            resetGame()
        default:
            currentPlayer = (currentPlayer == .X) ? .O : .X
        }
    }
    
    private func showWinAlert(for player: CurrentPlayer) {
        showAlert(title: "Congratulations!", message: "Player \(player == .X ? "X" : "O") wins!")
    }
    
    private func showDrawAlert() {
        showAlert(title: "It's a Draw!", message: "The game ended in a draw!")
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Reset Game -
    private func resetGame() {
        gameBoard.reset()
        currentPlayer = .X
        
        for row in 0..<3 {
            for col in 0..<3 {
                guard let cellNode = childNode(withName: "cell_\(row)_\(col)") as? SKShapeNode else { continue }
                cellNode.removeAllChildren()
            }
        }
    }
    
    // MARK: - Cool HapticFeedback -
    private func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
    }
}

// MARK: - Cool UIColor extension to use your own HEX color -
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let r = CGFloat((color & 0xff0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00ff00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000ff) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

