import SpriteKit

class LevelCompleteScene: SKScene {

    private var levelNumber: Int = 1
    private var levelName: String = ""
    private var score: Int = 0
    private var timeRemaining: Int = 0

    init(size: CGSize, levelNumber: Int, levelName: String, score: Int, timeRemaining: Int) {
        super.init(size: size)
        self.levelNumber = levelNumber
        self.levelName = levelName
        self.score = score
        self.timeRemaining = timeRemaining

        // Save progress automatically
        saveProgress()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Save Progress

    private func saveProgress() {
        // Mark this level as completed
        GameData.shared.markLevelCompleted(levelNumber)

        // Update high score
        GameData.shared.updateHighScore(score)

        // Unlock next level
        GameData.shared.unlockNextLevel(after: levelNumber)

        print("💾 Progress saved: Level \(levelNumber), Score: \(score)")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.15, blue: 0.05, alpha: 1.0)

        setupBackground()
        setupTitle()
        setupLevelInfo()
        setupScore()
        setupTimeBonus()
        setupButtons()
    }

    private func setupBackground() {
        // 草地背景
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.35))
        ground.fillColor = SKColor(red: 0.12, green: 0.4, blue: 0.12, alpha: 1.0)
        ground.strokeColor = .clear
        addChild(ground)

        // 棕榈树装饰（用真实树形状）
        for i in 0..<Int(size.width / 200) {
            let tree = createPalmTree()
            tree.position = CGPoint(x: CGFloat(i) * 200 + 80, y: size.height * 0.18)
            tree.setScale(0.8)
            tree.zPosition = -20
            addChild(tree)
        }

        // 星星背景
        for _ in 0..<60 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...4))
            star.fillColor = SKColor(white: CGFloat.random(in: 0.3...0.9), alpha: 1.0)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.4...size.height)
            )
            star.zPosition = -10
            star.alpha = CGFloat.random(in: 0.2...0.8)
            addChild(star)
        }
    }

    private func createPalmTree() -> SKNode {
        let tree = SKNode()

        // 树干（棕色梯形）
        let trunkPath = CGMutablePath()
        trunkPath.move(to: CGPoint(x: -6, y: 0))
        trunkPath.addLine(to: CGPoint(x: 6, y: 0))
        trunkPath.addLine(to: CGPoint(x: 4, y: 60))
        trunkPath.addLine(to: CGPoint(x: -4, y: 60))
        trunkPath.closeSubpath()
        let trunk = SKShapeNode(path: trunkPath)
        trunk.fillColor = SKColor(red: 0.4, green: 0.25, blue: 0.08, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        // 树冠（多个椭圆叶片）
        let leafColor1 = SKColor(red: 0.12, green: 0.5, blue: 0.12, alpha: 1.0)
        let leafColor2 = SKColor(red: 0.18, green: 0.6, blue: 0.18, alpha: 1.0)

        for i in 0..<7 {
            let angle = CGFloat(i) / 7.0 * .pi * 2
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 10, height: 35))
            leaf.fillColor = i % 2 == 0 ? leafColor1 : leafColor2
            leaf.strokeColor = .clear
            leaf.zRotation = angle
            leaf.position = CGPoint(x: 0, y: 65)
            tree.addChild(leaf)
        }

        return tree
    }

    private func setupTitle() {
        let titleLabel = SKLabelNode(text: "LEVEL COMPLETE!")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = min(size.width * 0.055, 56)
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)

        let starLabel = SKLabelNode(text: "★ ★ ★")
        starLabel.fontName = "Helvetica-Bold"
        starLabel.fontSize = min(size.width * 0.045, 44)
        starLabel.fontColor = .yellow
        starLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        starLabel.horizontalAlignmentMode = .center
        addChild(starLabel)
    }

    private func setupLevelInfo() {
        let levelLabel = SKLabelNode(text: "Level \(levelNumber): \(levelName)")
        levelLabel.fontName = "Helvetica-Bold"
        levelLabel.fontSize = min(size.width * 0.03, 30)
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        levelLabel.horizontalAlignmentMode = .center
        addChild(levelLabel)
    }

    private func setupScore() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = min(size.width * 0.032, 34)
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.47)
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
    }

    private func setupTimeBonus() {
        let timeBonus = timeRemaining * 10
        let bonusLabel = SKLabelNode(text: "Time Bonus: +\(timeBonus)")
        bonusLabel.fontName = "Helvetica-Bold"
        bonusLabel.fontSize = min(size.width * 0.026, 26)
        bonusLabel.fontColor = .green
        bonusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.39)
        bonusLabel.horizontalAlignmentMode = .center
        addChild(bonusLabel)
    }

    private func setupButtons() {
        let nextButton = SKLabelNode(text: "NEXT LEVEL →")
        nextButton.fontName = "Helvetica-Bold"
        nextButton.fontSize = min(size.width * 0.032, 32)
        nextButton.fontColor = .white
        nextButton.name = "nextButton"
        nextButton.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        nextButton.horizontalAlignmentMode = .center
        addChild(nextButton)

        let retryButton = SKLabelNode(text: "↺ RETRY")
        retryButton.fontName = "Helvetica-Bold"
        retryButton.fontSize = min(size.width * 0.024, 24)
        retryButton.fontColor = SKColor(white: 0.5, alpha: 1.0)
        retryButton.name = "retryButton"
        retryButton.position = CGPoint(x: size.width * 0.2, y: size.height * 0.22)
        retryButton.horizontalAlignmentMode = .center
        addChild(retryButton)

        let menuButton = SKLabelNode(text: "☰ MENU")
        menuButton.fontName = "Helvetica-Bold"
        menuButton.fontSize = min(size.width * 0.024, 24)
        menuButton.fontColor = SKColor(white: 0.5, alpha: 1.0)
        menuButton.name = "menuButton"
        menuButton.position = CGPoint(x: size.width * 0.8, y: size.height * 0.22)
        menuButton.horizontalAlignmentMode = .center
        addChild(menuButton)
    }

    private func presentGameScene(levelNum: Int) {
        let levelData = LevelManager.shared.generateLevelData(levelNum)
        let gameScene = GameScene(size: size, levelData: levelData)
        gameScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    private func presentMenuScene() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(menuScene, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = self.atPoint(location)

        switch node.name {
        case "nextButton":
            let nextLevel = levelNumber + 1
            if nextLevel <= LevelManager.shared.getTotalLevels() {
                let levelData = LevelManager.shared.generateLevelData(nextLevel)
                if levelData.terrainType == "boss" {
                    let bossScene = BossScene(size: size, levelData: levelData)
                    bossScene.scaleMode = .resizeFill
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    view?.presentScene(bossScene, transition: transition)
                } else {
                    presentGameScene(levelNum: nextLevel)
                }
            } else {
                presentMenuScene()
            }

        case "retryButton":
            presentGameScene(levelNum: levelNumber)

        case "menuButton":
            presentMenuScene()

        default:
            break
        }
    }
}