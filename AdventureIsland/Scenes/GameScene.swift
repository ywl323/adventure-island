import SpriteKit

class GameScene: SKScene {

    // MARK: - 节点属性
    private var player: Player!
    private var cameraNode: SKCameraNode!

    // MARK: - HUD
    private var scoreLabel: SKLabelNode!
    private var healthLabel: SKLabelNode!
    private var timeLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!

    // MARK: - 控制区域
    private var leftButton: SKNode!
    private var rightButton: SKNode!
    private var jumpButton: SKNode!
    private var attackButton: SKNode!

    // MARK: - 游戏状态
    private var score: Int = 0
    private var health: Int = 3
    private var gameTime: Int = 60
    private var isGameOver: Bool = false
    private var levelData: LevelData

    // 触摸状态
    private var isLeftPressed: Bool = false
    private var isRightPressed: Bool = false
    private var isJumpPressed: Bool = false
    private var isAttackPressed: Bool = false

    // MARK: - 背景滚动层
    private var backgroundLayer: SKNode!
    private var foregroundLayer: SKNode!

    // MARK: - 敌人和物品
    private var enemies: [Enemy] = []
    private var items: [Item] = []

    // MARK: - 世界边界
    private var worldBounds: CGRect!

    // 触摸 tracking
    private var activeTouches: [UITouch: String] = [:]

    // 玩家初始Y
    private let playerStartY: CGFloat = 150

    // MARK: - 初始化

    init(size: CGSize, levelData: LevelData) {
        self.levelData = levelData
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        gameTime = levelData.timeLimit
        setupPhysics()
        setupCamera()
        setupBackground()
        setupPlayer()
        setupEnemies()
        setupItems()
        setupHUD()
        setupControlArea()
        startGameTimer()
    }

    // MARK: - 设置

    private func setupPhysics() {
        worldBounds = CGRect(x: 0, y: 0, width: levelData.width, height: size.height)
        physicsWorld.gravity = CGVector(dx: 0, dy: -Constants.gravity)
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupBackground() {
        backgroundLayer = SKNode()
        addChild(backgroundLayer)

        let bgColor: SKColor
        switch levelData.terrainType {
        case "grass":
            bgColor = SKColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)
        case "water":
            bgColor = SKColor(red: 0.25, green: 0.55, blue: 0.85, alpha: 1.0)
        case "underground":
            bgColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
        case "volcano":
            bgColor = SKColor(red: 0.5, green: 0.15, blue: 0.08, alpha: 1.0)
        case "sky":
            bgColor = SKColor(red: 0.4, green: 0.55, blue: 0.85, alpha: 1.0)
        case "cliff":
            bgColor = SKColor(red: 0.55, green: 0.65, blue: 0.75, alpha: 1.0)
        case "ruins":
            bgColor = SKColor(red: 0.25, green: 0.3, blue: 0.25, alpha: 1.0)
        case "boss":
            bgColor = SKColor(red: 0.3, green: 0.15, blue: 0.25, alpha: 1.0)
        default:
            bgColor = SKColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)
        }

        let background = SKSpriteNode(color: bgColor, size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -100
        backgroundLayer.addChild(background)

        addBackgroundDecorations()
    }

    private func addBackgroundDecorations() {
        switch levelData.terrainType {
        case "grass":
            // 棕榈树（使用大尺寸 PNG）
            for i in 0..<Int(levelData.width / 250) {
                let treeSprite = SKSpriteNode(imageNamed: "26_decoration_palm_tree")
                if treeSprite.texture != nil {
                    treeSprite.size = CGSize(width: 120, height: 160)
                    treeSprite.position = CGPoint(x: CGFloat(i) * 250 + 80, y: 60)
                    treeSprite.zPosition = -30
                    backgroundLayer.addChild(treeSprite)
                    print("🌴 Tree PNG: size=\(treeSprite.size)")
                } else {
                    let tree = createTreeNode()
                    tree.position = CGPoint(x: CGFloat(i) * 250 + 80, y: 80)
                    backgroundLayer.addChild(tree)
                }
            }

            // 云朵（大尺寸 PNG）
            for i in 0..<6 {
                let cloudSprite = SKSpriteNode(imageNamed: "22_decoration_clouds")
                if cloudSprite.texture != nil {
                    cloudSprite.size = CGSize(width: 300, height: 150)
                    cloudSprite.position = CGPoint(
                        x: CGFloat(i) * (levelData.width / 6) + CGFloat.random(in: -50...50),
                        y: size.height - CGFloat.random(in: 100...180)
                    )
                    cloudSprite.zPosition = -80
                    cloudSprite.alpha = 0.95
                    backgroundLayer.addChild(cloudSprite)
                    print("☁️ Cloud PNG: size=\(cloudSprite.size)")
                } else {
                    let cloud = createCloudNode()
                    cloud.position = CGPoint(
                        x: CGFloat(i) * (levelData.width / 6) + CGFloat.random(in: -50...50),
                        y: size.height - CGFloat.random(in: 100...180)
                    )
                    backgroundLayer.addChild(cloud)
                }
            }

        case "underground", "ruins":
            for i in 0..<Int(levelData.width / 400) {
                let torchSprite = SKSpriteNode(imageNamed: "32_projectile_fireball")
                if torchSprite.texture != nil {
                    torchSprite.size = CGSize(width: 40, height: 60)
                    torchSprite.position = CGPoint(x: CGFloat(i) * 400 + 200, y: 200)
                    torchSprite.zPosition = -30
                    backgroundLayer.addChild(torchSprite)
                }
            }

        case "volcano":
            for i in 0..<Int(levelData.width / 500) {
                let lava = SKShapeNode(ellipseOf: CGSize(width: 200, height: 25))
                lava.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.9)
                lava.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 0.0, alpha: 1.0)
                lava.position = CGPoint(x: CGFloat(i) * 500 + 250, y: 20)
                lava.zPosition = -40
                backgroundLayer.addChild(lava)
            }

        default:
            break
        }
    }

    private func createCloudNode() -> SKNode {
        let cloud = SKNode()

        // 三个白色椭圆组成云朵形状
        let white = SKColor(white: 1.0, alpha: 0.9)
        let mainBall = SKShapeNode(ellipseOf: CGSize(width: 160, height: 80))
        mainBall.fillColor = white
        mainBall.strokeColor = .clear
        cloud.addChild(mainBall)

        let leftBall = SKShapeNode(ellipseOf: CGSize(width: 100, height: 60))
        leftBall.fillColor = white
        leftBall.strokeColor = .clear
        leftBall.position = CGPoint(x: -70, y: 10)
        cloud.addChild(leftBall)

        let rightBall = SKShapeNode(ellipseOf: CGSize(width: 100, height: 60))
        rightBall.fillColor = white
        rightBall.strokeColor = .clear
        rightBall.position = CGPoint(x: 70, y: 10)
        cloud.addChild(rightBall)

        return cloud
    }

    private func createTreeNode() -> SKNode {
        let tree = SKNode()

        let trunkPath = CGMutablePath()
        trunkPath.move(to: CGPoint(x: -8, y: 0))
        trunkPath.addLine(to: CGPoint(x: 8, y: 0))
        trunkPath.addLine(to: CGPoint(x: 5, y: 70))
        trunkPath.addLine(to: CGPoint(x: -5, y: 70))
        trunkPath.closeSubpath()
        let trunk = SKShapeNode(path: trunkPath)
        trunk.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.12, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        let foliage1 = SKShapeNode(circleOfRadius: 35)
        foliage1.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.15, alpha: 1.0)
        foliage1.strokeColor = .clear
        foliage1.position = CGPoint(x: 0, y: 80)
        tree.addChild(foliage1)

        let foliage2 = SKShapeNode(circleOfRadius: 28)
        foliage2.fillColor = SKColor(red: 0.18, green: 0.6, blue: 0.18, alpha: 1.0)
        foliage2.strokeColor = .clear
        foliage2.position = CGPoint(x: -25, y: 65)
        tree.addChild(foliage2)

        let foliage3 = SKShapeNode(circleOfRadius: 28)
        foliage3.fillColor = SKColor(red: 0.2, green: 0.65, blue: 0.2, alpha: 1.0)
        foliage3.strokeColor = .clear
        foliage3.position = CGPoint(x: 25, y: 65)
        tree.addChild(foliage3)

        return tree
    }

    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 200, y: playerStartY)
        addChild(player)

        print("✅ Player spawned at world=(\(player.position.x), \(player.position.y))")
        print("   camera position=\(cameraNode.position)")
        print("   scene size=\(size)")
    }

    private func setupEnemies() {
        for enemyData in levelData.enemies {
            let enemy = Enemy(type: enemyData.type)
            enemy.position = CGPoint(x: enemyData.x, y: enemyData.y)
            addChild(enemy)
            enemies.append(enemy)
        }
    }

    private func setupItems() {
        for itemData in levelData.items {
            let item = Item(type: itemData.type)
            item.position = CGPoint(x: itemData.x, y: itemData.y)
            addChild(item)
            items.append(item)
        }
    }

    private func setupHUD() {
        levelLabel = SKLabelNode(text: "Level \(levelData.levelNumber): \(levelData.name)")
        levelLabel.fontName = "Helvetica-Bold"
        levelLabel.fontSize = min(size.width * 0.03, 22)
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 30)
        levelLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(levelLabel)

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = min(size.width * 0.028, 20)
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 60)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        healthLabel = SKLabelNode(text: "❤️ 3")
        healthLabel.fontName = "Helvetica-Bold"
        healthLabel.fontSize = min(size.width * 0.028, 20)
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 90)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "Helvetica-Bold"
        timeLabel.fontSize = min(size.width * 0.028, 20)
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 120)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)
    }

    private func setupControlArea() {
        let btnSize: CGFloat = 60
        let edgePadding: CGFloat = 20

        // 左下角按钮组：y 在屏幕底部 1/4 位置
        let buttonY = -size.height / 2 + edgePadding + btnSize / 2

        // 左按钮（屏幕左侧）
        leftButton = SKNode()
        leftButton.name = "leftButton"
        leftButton.position = CGPoint(x: -size.width / 2 + edgePadding + btnSize / 2, y: buttonY)
        let leftBg = SKShapeNode(circleOfRadius: btnSize / 2)
        leftBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        leftBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        leftBg.lineWidth = 2.5
        leftButton.addChild(leftBg)

        // ◀ 箭头（向左的三角形）
        let leftPath = CGMutablePath()
        leftPath.move(to: CGPoint(x: 10, y: 0))
        leftPath.addLine(to: CGPoint(x: -8, y: -12))
        leftPath.addLine(to: CGPoint(x: -8, y: 12))
        leftPath.closeSubpath()
        let leftArrow = SKShapeNode(path: leftPath)
        leftArrow.fillColor = .white
        leftArrow.strokeColor = .clear
        leftButton.addChild(leftArrow)
        cameraNode.addChild(leftButton)

        // 右按钮（中间偏左）
        rightButton = SKNode()
        rightButton.name = "rightButton"
        rightButton.position = CGPoint(x: -size.width / 2 + edgePadding + btnSize * 1.6, y: buttonY)
        let rightBg = SKShapeNode(circleOfRadius: btnSize / 2)
        rightBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        rightBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        rightBg.lineWidth = 2.5
        rightButton.addChild(rightBg)

        // ▶ 箭头（向右的三角形）
        let rightPath = CGMutablePath()
        rightPath.move(to: CGPoint(x: -10, y: 0))
        rightPath.addLine(to: CGPoint(x: 8, y: -12))
        rightPath.addLine(to: CGPoint(x: 8, y: 12))
        rightPath.closeSubpath()
        let rightArrow = SKShapeNode(path: rightPath)
        rightArrow.fillColor = .white
        rightArrow.strokeColor = .clear
        rightButton.addChild(rightArrow)
        cameraNode.addChild(rightButton)

        // 右下角：跳跃 + 攻击
        let rightBaseX = size.width / 2 - edgePadding - btnSize / 2

        // 跳跃按钮
        jumpButton = SKNode()
        jumpButton.name = "jumpButton"
        jumpButton.position = CGPoint(x: rightBaseX - btnSize - 10, y: buttonY)
        let jumpBg = SKShapeNode(circleOfRadius: btnSize / 2)
        jumpBg.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.5, alpha: 0.85)
        jumpBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        jumpBg.lineWidth = 2.5
        jumpButton.addChild(jumpBg)

        let jumpPath = CGMutablePath()
        jumpPath.move(to: CGPoint(x: 0, y: 14))
        jumpPath.addLine(to: CGPoint(x: -14, y: -8))
        jumpPath.addLine(to: CGPoint(x: 14, y: -8))
        jumpPath.closeSubpath()
        let jumpArrow = SKShapeNode(path: jumpPath)
        jumpArrow.fillColor = .white
        jumpArrow.strokeColor = .clear
        jumpButton.addChild(jumpArrow)
        cameraNode.addChild(jumpButton)

        // 攻击按钮
        attackButton = SKNode()
        attackButton.name = "attackButton"
        attackButton.position = CGPoint(x: rightBaseX, y: buttonY)
        let attackBg = SKShapeNode(circleOfRadius: btnSize / 2)
        attackBg.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.85)
        attackBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        attackBg.lineWidth = 2.5
        attackButton.addChild(attackBg)

        let fireballSprite = SKSpriteNode(imageNamed: "32_projectile_fireball")
        if fireballSprite.texture != nil {
            fireballSprite.size = CGSize(width: 36, height: 36)
            fireballSprite.zPosition = 1
            attackButton.addChild(fireballSprite)
        } else {
            let atkPath = CGMutablePath()
            atkPath.move(to: CGPoint(x: 0, y: 14))
            atkPath.addLine(to: CGPoint(x: -14, y: -10))
            atkPath.addLine(to: CGPoint(x: 0, y: -2))
            atkPath.addLine(to: CGPoint(x: 14, y: -10))
            atkPath.closeSubpath()
            let atkSymbol = SKShapeNode(path: atkPath)
            atkSymbol.fillColor = .white
            atkSymbol.strokeColor = .clear
            attackButton.addChild(atkSymbol)
        }
        cameraNode.addChild(attackButton)

        print("🎮 Control buttons setup:")
        print("   leftButton pos: \(leftButton.position)")
        print("   rightButton pos: \(rightButton.position)")
        print("   jumpButton pos: \(jumpButton.position)")
        print("   attackButton pos: \(attackButton.position)")
    }

    private func startGameTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let update = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.gameTime -= 1
            self.timeLabel.text = "Time: \(self.gameTime)"
            if self.gameTime <= 0 {
                self.gameOver()
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, update])))
    }

    // MARK: - 触摸处理

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }

        for touch in touches {
            let location = touch.location(in: cameraNode)

            // 直接遍历按钮节点做精确命中测试
            let buttonNodes: [(String, SKNode)] = [
                ("leftButton", leftButton),
                ("rightButton", rightButton),
                ("jumpButton", jumpButton),
                ("attackButton", attackButton)
            ]

            for (name, buttonNode) in buttonNodes {
                // 计算按钮的全球坐标范围（相对于 cameraNode）
                let btnFrame = CGRect(
                    x: buttonNode.position.x - 30,
                    y: buttonNode.position.y - 30,
                    width: 60,
                    height: 60
                )
                if btnFrame.contains(location) {
                    activeTouches[touch] = name
                    handleButtonDown(name)
                    print("🟢 touchesBegan: button='\(name)' at \(location)")
                    break
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let name = activeTouches[touch] {
                handleButtonUp(name)
                activeTouches.removeValue(forKey: touch)
                print("🔴 touchesEnded: button='\(name)'")
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let name = activeTouches[touch] {
                handleButtonUp(name)
                activeTouches.removeValue(forKey: touch)
            }
        }
    }

    private func handleButtonDown(_ name: String) {
        switch name {
        case "leftButton":
            isLeftPressed = true
        case "rightButton":
            isRightPressed = true
        case "jumpButton":
            isJumpPressed = true
        case "attackButton":
            isAttackPressed = true
        default:
            break
        }
    }

    private func handleButtonUp(_ name: String) {
        switch name {
        case "leftButton":
            isLeftPressed = false
        case "rightButton":
            isRightPressed = false
        case "jumpButton":
            isJumpPressed = false
        case "attackButton":
            isAttackPressed = false
        default:
            break
        }
    }

    // MARK: - 更新逻辑

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // 水平移动
        if isLeftPressed {
            player.moveLeft()
        } else if isRightPressed {
            player.moveRight()
        } else {
            player.stop()
        }

        // 跳跃
        if isJumpPressed {
            player.jump()
            isJumpPressed = false
        }

        // 攻击
        if isAttackPressed {
            player.attack()
            isAttackPressed = false
        }

        // 摄像机跟随（水平）
        let minX = size.width / 2
        let maxX = levelData.width - size.width / 2
        let clampedX = max(minX, min(player.position.x, maxX))
        cameraNode.position.x = clampedX

        // 玩家更新
        player.update()

        // 防止玩家掉落出屏幕
        if player.position.y < 50 {
            player.position.y = playerStartY
            player.stop()
        }
    }

    // MARK: - 游戏逻辑

    func addScore(_ points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }

    func takeDamage() {
        health -= 1
        healthLabel.text = "❤️ \(health)"
        if health <= 0 {
            gameOver()
        }
    }

    private func gameOver() {
        isGameOver = true
        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: transition)
    }

    private func levelComplete() {
        isGameOver = true
        let levelCompleteScene = LevelCompleteScene(
            size: size,
            levelNumber: levelData.levelNumber,
            levelName: levelData.name,
            score: score,
            timeRemaining: gameTime
        )
        levelCompleteScene.scaleMode = .resizeFill
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(levelCompleteScene, transition: transition)
    }

    func didCollideWithEnemy() {
        takeDamage()
    }
}