import SpriteKit

class GameOverScene: SKScene {

    private var score: Int = 0
    private var retryButton: SKLabelNode!

    init(size: CGSize, score: Int) {
        super.init(size: size)
        self.score = score
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)

        // 添加背景装饰
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...4))
            star.fillColor = SKColor(white: CGFloat.random(in: 0.3...0.8), alpha: 1.0)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.2...0.8)
            addChild(star)
        }

        setupTitle()
        setupScore()
        setupRetryButton()
        setupMenuButton()
    }

    private func setupTitle() {
        let titleLabel = SKLabelNode(text: "GAME OVER")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
    }

    private func setupScore() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        addChild(scoreLabel)
    }

    private func setupRetryButton() {
        retryButton = SKLabelNode(text: "↺ RETRY")
        retryButton.fontName = "Helvetica-Bold"
        retryButton.fontSize = 40
        retryButton.fontColor = .white
        retryButton.name = "retryButton"
        retryButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(retryButton)
    }

    private func setupMenuButton() {
        let menuButton = SKLabelNode(text: "☰ MENU")
        menuButton.fontName = "Helvetica-Bold"
        menuButton.fontSize = 30
        menuButton.fontColor = .gray
        menuButton.name = "menuButton"
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        addChild(menuButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = self.atPoint(location)

        if node.name == "retryButton" || node.name == nil && touches.count > 0 {
            // 从第一关重新开始
            let levelData = LevelManager.shared.generateLevelData(1)
            let gameScene = GameScene(size: size, levelData: levelData)
            gameScene.scaleMode = .resizeFill
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameScene, transition: transition)
        }

        if node.name == "menuButton" {
            let menuScene = MenuScene(size: size)
            menuScene.scaleMode = .resizeFill
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(menuScene, transition: transition)
        }
    }
}