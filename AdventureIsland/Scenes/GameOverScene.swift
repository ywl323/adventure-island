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
        backgroundColor = SKColor(red: 0.15, green: 0.1, blue: 0.1, alpha: 1.0)

        setupBackground()
        setupTitle()
        setupScore()
        setupRetryButton()
    }

    private func setupBackground() {
        // 暗红色背景
        let bg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        bg.fillColor = SKColor(red: 0.1, green: 0.05, blue: 0.05, alpha: 1.0)
        bg.strokeColor = .clear
        bg.zPosition = -100
        addChild(bg)

        // 地面
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: 100))
        ground.fillColor = SKColor(red: 0.25, green: 0.15, blue: 0.1, alpha: 1.0)
        ground.strokeColor = .clear
        ground.zPosition = -50
        addChild(ground)

        // 一些装饰树
        for i in 0..<Int(size.width / 200) {
            let tree = createTree()
            tree.position = CGPoint(x: CGFloat(i) * 200 + 80, y: 80)
            tree.zPosition = -30
            addChild(tree)
        }
    }

    private func createTree() -> SKNode {
        let tree = SKNode()

        // 树干
        let trunkPath = CGMutablePath()
        trunkPath.move(to: CGPoint(x: -6, y: 0))
        trunkPath.addLine(to: CGPoint(x: 6, y: 0))
        trunkPath.addLine(to: CGPoint(x: 4, y: 55))
        trunkPath.addLine(to: CGPoint(x: -4, y: 55))
        trunkPath.closeSubpath()
        let trunk = SKShapeNode(path: trunkPath)
        trunk.fillColor = SKColor(red: 0.4, green: 0.25, blue: 0.08, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        // 树冠（多个椭圆叶片）
        for i in 0..<7 {
            let angle = CGFloat(i) / 7.0 * .pi * 2
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 10, height: 32))
            leaf.fillColor = SKColor(red: 0.12, green: 0.45, blue: 0.12, alpha: 1.0)
            leaf.strokeColor = .clear
            leaf.zRotation = angle
            leaf.position = CGPoint(x: 0, y: 60)
            tree.addChild(leaf)
        }

        return tree
    }

    private func setupTitle() {
        let titleLabel = SKLabelNode(text: "GAME OVER")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = min(size.width * 0.07, 72)
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)
    }

    private func setupScore() {
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = min(size.width * 0.035, 36)
        scoreLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
    }

    private func setupRetryButton() {
        // RETRY 按钮
        let retryBg = SKShapeNode(rect: CGRect(x: size.width / 2 - 100, y: size.height * 0.33 - 25, width: 200, height: 50), cornerRadius: 10)
        retryBg.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.9)
        retryBg.strokeColor = SKColor(white: 0.4, alpha: 0.8)
        retryBg.lineWidth = 2
        retryBg.name = "retryButton"
        addChild(retryBg)

        let retryLabel = SKLabelNode(text: "↺ RETRY")
        retryLabel.fontName = "Helvetica-Bold"
        retryLabel.fontSize = min(size.width * 0.028, 28)
        retryLabel.fontColor = .white
        retryLabel.name = "retryButton"
        retryLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.33)
        retryLabel.horizontalAlignmentMode = .center
        addChild(retryLabel)

        // MENU 按钮
        let menuBg = SKShapeNode(rect: CGRect(x: size.width / 2 - 75, y: size.height * 0.2 - 22, width: 150, height: 44), cornerRadius: 8)
        menuBg.fillColor = SKColor(white: 0.2, alpha: 0.8)
        menuBg.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        menuBg.lineWidth = 1.5
        menuBg.name = "menuButton"
        addChild(menuBg)

        let menuLabel = SKLabelNode(text: "☰ MENU")
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontSize = min(size.width * 0.022, 22)
        menuLabel.fontColor = .white
        menuLabel.name = "menuButton"
        menuLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        menuLabel.horizontalAlignmentMode = .center
        addChild(menuLabel)
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
        case "retryButton":
            presentGameScene(levelNum: 1)
        case "menuButton":
            presentMenuScene()
        default:
            break
        }
    }
}