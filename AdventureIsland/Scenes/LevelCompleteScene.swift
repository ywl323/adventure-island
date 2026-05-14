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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.2, blue: 0.05, alpha: 1.0)

        // 背景装饰星星
        for _ in 0..<40 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...4))
            star.fillColor = SKColor(white: CGFloat.random(in: 0.3...0.9), alpha: 1.0)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.2...0.9)
            addChild(star)
        }

        setupTitle()
        setupLevelInfo()
        setupScore()
        setupTimeBonus()
        setupButtons()
    }

    private func setupTitle() {
        let titleLabel = SKLabelNode(text: "LEVEL COMPLETE!")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 50
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        addChild(titleLabel)

        let starLabel = SKLabelNode(text: "★ ★ ★")
        starLabel.fontName = "Helvetica-Bold"
        starLabel.fontSize = 40
        starLabel.fontColor = .yellow
        starLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(starLabel)
    }

    private func setupLevelInfo() {
        let levelLabel = SKLabelNode(text: "Level \(levelNumber): \(levelName)")
        levelLabel.fontName = "Helvetica-Bold"
        levelLabel.fontSize = 30
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        addChild(levelLabel)
    }

    private func setupScore() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 35
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(scoreLabel)
    }

    private func setupTimeBonus() {
        let timeBonus = timeRemaining * 10
        let bonusLabel = SKLabelNode(text: "Time Bonus: +\(timeBonus)")
        bonusLabel.fontName = "Helvetica-Bold"
        bonusLabel.fontSize = 28
        bonusLabel.fontColor = .green
        bonusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.37)
        addChild(bonusLabel)
    }

    private func setupButtons() {
        let nextButton = SKLabelNode(text: "NEXT LEVEL →")
        nextButton.fontName = "Helvetica-Bold"
        nextButton.fontSize = 36
        nextButton.fontColor = .white
        nextButton.name = "nextButton"
        nextButton.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        addChild(nextButton)

        let retryButton = SKLabelNode(text: "↺ RETRY")
        retryButton.fontName = "Helvetica-Bold"
        retryButton.fontSize = 28
        retryButton.fontColor = .gray
        retryButton.name = "retryButton"
        retryButton.position = CGPoint(x: size.width * 0.25, y: size.height * 0.22)
        addChild(retryButton)

        let menuButton = SKLabelNode(text: "☰ MENU")
        menuButton.fontName = "Helvetica-Bold"
        menuButton.fontSize = 28
        menuButton.fontColor = .gray
        menuButton.name = "menuButton"
        menuButton.position = CGPoint(x: size.width * 0.75, y: size.height * 0.22)
        addChild(menuButton)
    }

    private func presentGameScene(levelNum: Int) {
        let levelData = LevelManager.shared.generateLevelData(levelNum)
        let gameScene = GameScene(size: size, levelData: levelData)
        gameScene.scaleMode = .aspectFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    private func presentMenuScene() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill
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
                    bossScene.scaleMode = .aspectFill
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