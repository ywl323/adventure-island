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
    private var activeTouches: [UITouch: String] = [:]  // touch ID → button name

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

        // 添加地面
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: levelData.width, height: 50))
        ground.fillColor = getGroundColor()
        ground.strokeColor = .clear
        ground.zPosition = -50
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: levelData.width, y: 0))
        ground.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategories.player
        backgroundLayer.addChild(ground)

        addBackgroundDecorations()
    }

    private func getGroundColor() -> SKColor {
        switch levelData.terrainType {
        case "grass":
            return SKColor(red: 0.3, green: 0.55, blue: 0.25, alpha: 1.0)
        case "water":
            return SKColor(red: 0.15, green: 0.35, blue: 0.5, alpha: 1.0)
        case "underground", "ruins":
            return SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        case "volcano":
            return SKColor(red: 0.35, green: 0.15, blue: 0.08, alpha: 1.0)
        case "sky":
            return SKColor(red: 0.55, green: 0.45, blue: 0.35, alpha: 1.0)
        case "cliff":
            return SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1.0)
        default:
            return SKColor(red: 0.3, green: 0.55, blue: 0.25, alpha: 1.0)
        }
    }

    private func addBackgroundDecorations() {
        switch levelData.terrainType {
        case "grass":
            // 用棕榈树 PNG 替代圆形树
            for i in 0..<Int(levelData.width / 300) {
                let treeSprite = SKSpriteNode(imageNamed: "26_decoration_palm_tree")
                if treeSprite.texture != nil {
                    treeSprite.size = CGSize(width: 60, height: 80)
                    treeSprite.position = CGPoint(x: CGFloat(i) * 300 + 100, y: 40)
                    treeSprite.zPosition = -30
                    backgroundLayer.addChild(treeSprite)
                } else {
                    // fallback 绿树
                    let tree = createTreeNode()
                    tree.position = CGPoint(x: CGFloat(i) * 300 + 100, y: 50)
                    backgroundLayer.addChild(tree)
                }
            }

            // 云朵用 PNG 替代灰色圆圈
            for i in 0..<8 {
                let cloudSprite = SKSpriteNode(imageNamed: "22_decoration_clouds")
                if cloudSprite.texture != nil {
                    cloudSprite.size = CGSize(width: 100, height: 60)
                    cloudSprite.position = CGPoint(
                        x: CGFloat(i) * (levelData.width / 8) + CGFloat.random(in: -30...30),
                        y: size.height - CGFloat.random(in: 60...120)
                    )
                    cloudSprite.zPosition = -80
                    cloudSprite.alpha = 0.9
                    backgroundLayer.addChild(cloudSprite)
                } else {
                    // fallback 白云
                    let cloud = SKShapeNode(circleOfRadius: 40)
                    cloud.fillColor = SKColor(white: 1.0, alpha: 0.85)
                    cloud.strokeColor = .clear
                    cloud.position = CGPoint(
                        x: CGFloat(i) * (levelData.width / 8) + CGFloat.random(in: -30...30),
                        y: size.height - CGFloat.random(in: 60...120)
                    )
                    cloud.zPosition = -80
                    backgroundLayer.addChild(cloud)
                }
            }

        case "underground", "ruins":
            // 火把用 PNG
            for i in 0..<Int(levelData.width / 400) {
                let torchSprite = SKSpriteNode(imageNamed: "32_projectile_fireball")
                if torchSprite.texture != nil {
                    torchSprite.size = CGSize(width: 30, height: 40)
                    torchSprite.position = CGPoint(x: CGFloat(i) * 400 + 200, y: 180)
                    torchSprite.zPosition = -30
                    backgroundLayer.addChild(torchSprite)
                }
            }

        case "volcano":
            // 岩浆池用橙色长条
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

    private func createTreeNode() -> SKNode {
        let tree = SKNode()

        // 棕色树干
        let trunk = SKShapeNode(rect: CGRect(x: -8, y: 0, width: 16, height: 50))
        trunk.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.12, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        // 深绿色树冠（多个圆叠加）
        let foliage1 = SKShapeNode(circleOfRadius: 30)
        foliage1.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.15, alpha: 1.0)
        foliage1.strokeColor = .clear
        foliage1.position = CGPoint(x: 0, y: 60)
        tree.addChild(foliage1)

        let foliage2 = SKShapeNode(circleOfRadius: 25)
        foliage2.fillColor = SKColor(red: 0.18, green: 0.55, blue: 0.18, alpha: 1.0)
        foliage2.strokeColor = .clear
        foliage2.position = CGPoint(x: -20, y: 50)
        tree.addChild(foliage2)

        let foliage3 = SKShapeNode(circleOfRadius: 25)
        foliage3.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        foliage3.strokeColor = .clear
        foliage3.position = CGPoint(x: 20, y: 50)
        tree.addChild(foliage3)

        return tree
    }

    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 200, y: 200)
        addChild(player)
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
        levelLabel.fontSize = 22
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 80, y: size.height - 30)
        levelLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(levelLabel)

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 60)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        healthLabel = SKLabelNode(text: "❤️ 3")
        healthLabel.fontName = "Helvetica-Bold"
        healthLabel.fontSize = 22
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: 80, y: size.height - 90)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "Helvetica-Bold"
        timeLabel.fontSize = 22
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 80, y: size.height - 120)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)

        var stars = ""
        for i in 1...5 {
            stars += i <= levelData.difficulty ? "★" : "☆"
        }
        let difficultyLabel = SKLabelNode(text: stars)
        difficultyLabel.fontName = "Helvetica-Bold"
        difficultyLabel.fontSize = 18
        difficultyLabel.fontColor = .orange
        difficultyLabel.position = CGPoint(x: size.width - 80, y: size.height - 30)
        difficultyLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(difficultyLabel)
    }

    private func setupControlArea() {
        // 按钮尺寸
        let btnSize: CGFloat = 56

        // 屏幕边缘边距
        let edgePadding: CGFloat = 24

        // camera 坐标系中：屏幕左下角 = (-size.width/2 + padding, -size.height/2 + padding)
        let buttonY = -size.height / 2 + edgePadding + btnSize / 2

        // 左下角：方向按钮（2个半圆形状拼在一起）
        let leftBaseX = -size.width / 2 + edgePadding + btnSize / 2

        // 方向键底板（一个圆角矩形底座）
        let dpadBase = SKShapeNode(rect: CGRect(x: leftBaseX - btnSize / 2 - 2, y: buttonY - btnSize / 2 - 2, width: btnSize * 2 + 6, height: btnSize + 4), cornerRadius: 28)
        dpadBase.fillColor = SKColor(white: 0.1, alpha: 0.7)
        dpadBase.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        dpadBase.lineWidth = 1.5
        dpadBase.name = "dpadBase"
        cameraNode.addChild(dpadBase)

        // ◀ 左按钮
        leftButton = SKNode()
        leftButton.name = "leftButton"
        leftButton.position = CGPoint(x: leftBaseX, y: buttonY)
        let leftBg = SKShapeNode(circleOfRadius: btnSize / 2)
        leftBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        leftBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        leftBg.lineWidth = 2
        leftButton.addChild(leftBg)

        // 用三角形绘制 ◀
        let leftPath = CGMutablePath()
        leftPath.move(to: CGPoint(x: 12, y: 0))
        leftPath.addLine(to: CGPoint(x: -6, y: -12))
        leftPath.addLine(to: CGPoint(x: -6, y: 12))
        leftPath.closeSubpath()
        let leftArrow = SKShapeNode(path: leftPath)
        leftArrow.fillColor = .white
        leftArrow.strokeColor = .clear
        leftButton.addChild(leftArrow)
        cameraNode.addChild(leftButton)

        // ▶ 右按钮
        rightButton = SKNode()
        rightButton.name = "rightButton"
        rightButton.position = CGPoint(x: leftBaseX + btnSize + 4, y: buttonY)
        let rightBg = SKShapeNode(circleOfRadius: btnSize / 2)
        rightBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        rightBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        rightBg.lineWidth = 2
        rightButton.addChild(rightBg)

        let rightPath = CGMutablePath()
        rightPath.move(to: CGPoint(x: -12, y: 0))
        rightPath.addLine(to: CGPoint(x: 6, y: -12))
        rightPath.addLine(to: CGPoint(x: 6, y: 12))
        rightPath.closeSubpath()
        let rightArrow = SKShapeNode(path: rightPath)
        rightArrow.fillColor = .white
        rightArrow.strokeColor = .clear
        rightButton.addChild(rightArrow)
        cameraNode.addChild(rightButton)

        // 右下角：跳跃 + 攻击
        let rightBaseX = size.width / 2 - edgePadding - btnSize / 2

        // 跳跃按钮（蓝绿色）
        jumpButton = SKNode()
        jumpButton.name = "jumpButton"
        jumpButton.position = CGPoint(x: rightBaseX - btnSize - 6, y: buttonY)
        let jumpBg = SKShapeNode(circleOfRadius: btnSize / 2)
        jumpBg.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.6, alpha: 0.85)
        jumpBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        jumpBg.lineWidth = 2
        jumpButton.addChild(jumpBg)

        // 用三角形画 ▲
        let jumpPath = CGMutablePath()
        jumpPath.move(to: CGPoint(x: 0, y: 12))
        jumpPath.addLine(to: CGPoint(x: -12, y: -8))
        jumpPath.addLine(to: CGPoint(x: 12, y: -8))
        jumpPath.closeSubpath()
        let jumpArrow = SKShapeNode(path: jumpPath)
        jumpArrow.fillColor = .white
        jumpArrow.strokeColor = .clear
        jumpButton.addChild(jumpArrow)
        cameraNode.addChild(jumpButton)

        // 攻击按钮（红色）
        attackButton = SKNode()
        attackButton.name = "attackButton"
        attackButton.position = CGPoint(x: rightBaseX, y: buttonY)
        let attackBg = SKShapeNode(circleOfRadius: btnSize / 2)
        attackBg.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.85)
        attackBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        attackBg.lineWidth = 2
        attackButton.addChild(attackBg)

        // 用 fireball PNG 或绘制一个拳头符号
        let fireballSprite = SKSpriteNode(imageNamed: "32_projectile_fireball")
        if fireballSprite.texture != nil {
            fireballSprite.size = CGSize(width: 32, height: 32)
            fireballSprite.zPosition = 1
            attackButton.addChild(fireballSprite)
        } else {
            // fallback: 绘制一个爆炸符号
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
            let node = cameraNode.atPoint(location)

            // 检查是否点在按钮上（递归检查子节点）
            let btnName = getButtonName(from: node)
            if let name = btnName {
                activeTouches[touch] = name
                handleButtonDown(name)
                print("🟢 touchesBegan: button='\(name)' at \(location)")
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let name = activeTouches[touch] {
                handleButtonUp(name)
                activeTouches.removeValue(forKey: touch)
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

    // 递归获取按钮名称（检查自身和父节点）
    private func getButtonName(from node: SKNode) -> String? {
        var current: SKNode? = node
        while let n = current {
            if let name = n.name, name != "dpadBase" {
                return name
            }
            current = n.parent
        }
        return nil
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

        if isLeftPressed {
            player.moveLeft()
        } else if isRightPressed {
            player.moveRight()
        } else {
            player.stop()
        }

        if isJumpPressed {
            player.jump()
            isJumpPressed = false
        }

        if isAttackPressed {
            player.attack()
            isAttackPressed = false
        }

        let targetX = max(min(player.position.x, levelData.width - size.width / 2), size.width / 2)
        cameraNode.position.x = targetX

        player.update()

        if player.position.x >= levelData.width - 100 {
            levelComplete()
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