import SpriteKit

class GameOverScene: SKScene {

    private var score: Int = 0

    init(size: CGSize, score: Int) {
        super.init(size: size)
        self.score = score
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        setupTitle()
        setupScore()
        setupRetryButton()
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
        let retryButton = SKLabelNode(text: "RETRY")
        retryButton.fontName = "Helvetica-Bold"
        retryButton.fontSize = 40
        retryButton.fontColor = .white
        retryButton.name = "retryButton"
        retryButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(retryButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = self.atPoint(location)

        if node.name == "retryButton" {
            let gameScene = GameScene(size: size, levelData: LevelManager.generateLevelData(1))
            gameScene.scaleMode = scaleMode
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(gameScene, transition: transition)
        }
    }
}
