import SpriteKit

class MenuScene: SKScene {

    private var titleLabel: SKLabelNode!
    private var startButton: SKLabelNode!
    private var levelSelectLabel: SKLabelNode!
    private var worldLabel: SKLabelNode!
    private var currentWorldIndex: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.25, blue: 0.45, alpha: 1.0)
        setupTitle()
        setupWorldSelector()
        setupStartButton()
        setupBackground()
    }

    private func setupTitle() {
        titleLabel = SKLabelNode(text: "Adventure Island")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 55
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        addChild(titleLabel)

        // Subtitle
        let subtitleLabel = SKLabelNode(text: "16 Epic Levels")
        subtitleLabel.fontName = "Helvetica"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = SKColor(white: 0.8, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.70)
        addChild(subtitleLabel)
    }

    private func setupWorldSelector() {
        // World label
        updateWorldLabel()
        worldLabel = SKLabelNode(text: getCurrentWorldText())
        worldLabel.fontName = "Helvetica-Bold"
        worldLabel.fontSize = 30
        worldLabel.fontColor = .yellow
        worldLabel.name = "worldLabel"
        worldLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        addChild(worldLabel)

        // Left arrow
        let leftArrow = SKLabelNode(text: "◀")
        leftArrow.fontName = "Helvetica-Bold"
        leftArrow.fontSize = 36
        leftArrow.name = "leftArrow"
        leftArrow.color = .white
        leftArrow.position = CGPoint(x: size.width * 0.25, y: size.height * 0.55)
        addChild(leftArrow)

        // Right arrow
        let rightArrow = SKLabelNode(text: "▶")
        rightArrow.fontName = "Helvetica-Bold"
        rightArrow.fontSize = 36
        rightArrow.name = "rightArrow"
        rightArrow.color = .white
        rightArrow.position = CGPoint(x: size.width * 0.75, y: size.height * 0.55)
        addChild(rightArrow)

        // Level indicators (1-4 dots for current world)
        updateLevelIndicators()
    }

    private func updateWorldLabel() {
        let world = LevelManager.shared.worlds[currentWorldIndex]
        worldLabel?.text = "World \(world.worldNumber): \(world.name)"

        // Color based on world
        switch world.worldNumber {
        case 1:
            worldLabel?.color = SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0) // Green
        case 2:
            worldLabel?.color = SKColor(red: 0.3, green: 0.7, blue: 0.4, alpha: 1.0) // Jungle
        case 3:
            worldLabel?.color = SKColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 1.0) // Volcano
        case 4:
            worldLabel?.color = SKColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0) // Final
        default:
            worldLabel?.color = .yellow
        }
    }

    private func updateLevelIndicators() {
        // Remove old indicators
        children.filter { $0.name?.starts(with: "levelDot") == true }.forEach { $0.removeFromParent() }

        let world = LevelManager.shared.worlds[currentWorldIndex]
        let startLevel = world.startLevel

        for i in 0..<4 {
            let dot = SKShapeNode(circleOfRadius: 12)
            dot.fillColor = i == 0 ? .yellow : .gray
            dot.strokeColor = .white
            dot.name = "levelDot\(i)"
            dot.position = CGPoint(
                x: size.width / 2 - 54 + CGFloat(i) * 36,
                y: size.height * 0.45
            )
            addChild(dot)

            // Level number inside dot
            let numLabel = SKLabelNode(text: "\(startLevel + i)")
            numLabel.fontName = "Helvetica-Bold"
            numLabel.fontSize = 14
            numLabel.name = "levelNum\(i)"
            numLabel.position = CGPoint(x: size.width / 2 - 54 + CGFloat(i) * 36, y: size.height * 0.45 - 5)
            numLabel.verticalAlignmentMode = .center
            addChild(numLabel)
        }
    }

    private func getCurrentWorldText() -> String {
        let world = LevelManager.shared.worlds[currentWorldIndex]
        return "World \(world.worldNumber): \(world.name)"
    }

    private func setupStartButton() {
        startButton = SKLabelNode(text: "▶ START")
        startButton.fontName = "Helvetica-Bold"
        startButton.fontSize = 38
        startButton.fontColor = .white
        startButton.name = "startButton"
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
        addChild(startButton)

        // Add glow effect
        startButton.alpha = 0.9
    }

    private func setupBackground() {
        // 添加星星背景效果
        for _ in 0..<80 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = SKColor(white: Double.random(in: 0.5...1.0), alpha: 1.0)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            addChild(star)
        }

        // Ground decoration
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: 60))
        ground.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0)
        ground.strokeColor = .clear
        addChild(ground)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = self.atPoint(location)

        switch node.name {
        case "startButton":
            startGame()

        case "leftArrow":
            currentWorldIndex = (currentWorldIndex - 1 + LevelManager.shared.worlds.count) % LevelManager.shared.worlds.count
            updateWorldLabel()
            updateLevelIndicators()

        case "rightArrow":
            currentWorldIndex = (currentWorldIndex + 1) % LevelManager.shared.worlds.count
            updateWorldLabel()
            updateLevelIndicators()

        default:
            break
        }
    }

    private func startGame() {
        let world = LevelManager.shared.worlds[currentWorldIndex]
        let firstLevel = world.startLevel
        let levelData = LevelManager.shared.generateLevelData(firstLevel)

        let gameScene: SKScene
        if levelData.terrainType == "boss" {
            gameScene = BossScene(size: size, levelData: levelData)
        } else {
            gameScene = GameScene(size: size, levelData: levelData)
        }

        gameScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset any highlights if needed
    }
}