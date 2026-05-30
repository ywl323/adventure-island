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

        // 将时间加成加入总分
        let timeBonus = timeRemaining * 10
        self.score += timeBonus

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

    override func didMove(to view: SKView) { super.didMove(to: view); 
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
        // 使用带命中区域的父节点包裹 SKLabelNode，
        // SKShapeNode 背景作为实际命中区域（比文字更大），文字只负责显示

        let btnY = size.height * 0.22

        // NEXT LEVEL 按钮
        let nextBg = SKShapeNode(rect: CGRect(x: -90, y: -20, width: 180, height: 40), cornerRadius: 8)
        nextBg.fillColor = SKColor(white: 0.2, alpha: 0.6)
        nextBg.strokeColor = SKColor(white: 0.4, alpha: 0.5)
        nextBg.lineWidth = 1.5
        nextBg.name = "nextButton"
        nextBg.position = CGPoint(x: size.width / 2, y: btnY)
        addChild(nextBg)

        let nextLabel = SKLabelNode(text: "NEXT LEVEL →")
        nextLabel.fontName = "Helvetica-Bold"
        nextLabel.fontSize = min(size.width * 0.028, 28)
        nextLabel.fontColor = .white
        nextLabel.position = CGPoint(x: 0, y: -7)
        nextBg.addChild(nextLabel)

        // RETRY 按钮
        let retryBg = SKShapeNode(rect: CGRect(x: -65, y: -18, width: 130, height: 36), cornerRadius: 6)
        retryBg.fillColor = SKColor(white: 0.15, alpha: 0.5)
        retryBg.strokeColor = SKColor(white: 0.3, alpha: 0.4)
        retryBg.lineWidth = 1
        retryBg.name = "retryButton"
        retryBg.position = CGPoint(x: size.width * 0.2, y: btnY)
        addChild(retryBg)

        let retryLabel = SKLabelNode(text: "↺ RETRY")
        retryLabel.fontName = "Helvetica-Bold"
        retryLabel.fontSize = min(size.width * 0.022, 22)
        retryLabel.fontColor = SKColor(white: 0.5, alpha: 1.0)
        retryLabel.position = CGPoint(x: 0, y: -5)
        retryBg.addChild(retryLabel)

        // MENU 按钮
        let menuBg = SKShapeNode(rect: CGRect(x: -65, y: -18, width: 130, height: 36), cornerRadius: 6)
        menuBg.fillColor = SKColor(white: 0.15, alpha: 0.5)
        menuBg.strokeColor = SKColor(white: 0.3, alpha: 0.4)
        menuBg.lineWidth = 1
        menuBg.name = "menuButton"
        menuBg.position = CGPoint(x: size.width * 0.8, y: btnY)
        addChild(menuBg)

        let menuLabel = SKLabelNode(text: "☰ MENU")
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontSize = min(size.width * 0.022, 22)
        menuLabel.fontColor = SKColor(white: 0.5, alpha: 1.0)
        menuLabel.position = CGPoint(x: 0, y: -5)
        menuBg.addChild(menuLabel)
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