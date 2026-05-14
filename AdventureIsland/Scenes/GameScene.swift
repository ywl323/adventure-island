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
    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    private var jumpButton: SKShapeNode!
    private var attackButton: SKShapeNode!

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
        // Y 固定在 size.height/2，使屏幕底部对准 scene y = 90
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupBackground() {
        backgroundLayer = SKNode()
        addChild(backgroundLayer)

        // 根据地形类型设置背景
        let bgColor: SKColor
        switch levelData.terrainType {
        case "grass":
            bgColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0) // 蓝天
        case "water":
            bgColor = SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0) // 水蓝
        case "underground":
            bgColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0) // 地下深色
        case "volcano":
            bgColor = SKColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0) // 火山红
        case "sky":
            bgColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0) // 天空蓝
        case "cliff":
            bgColor = SKColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0) // 悬崖灰
        case "ruins":
            bgColor = SKColor(red: 0.3, green: 0.35, blue: 0.3, alpha: 1.0) // 遗迹绿
        case "boss":
            bgColor = SKColor(red: 0.4, green: 0.2, blue: 0.3, alpha: 1.0) // BOSS房
        default:
            bgColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0)
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

        // 添加装饰元素
        addBackgroundDecorations()
    }

    private func getGroundColor() -> SKColor {
        switch levelData.terrainType {
        case "grass":
            return SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        case "water":
            return SKColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        case "underground", "ruins":
            return SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
        case "volcano":
            return SKColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0)
        case "sky":
            return SKColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0)
        case "cliff":
            return SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 1.0)
        default:
            return SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0)
        }
    }

    private func addBackgroundDecorations() {
        // 根据地形类型添加不同装饰
        switch levelData.terrainType {
        case "grass":
            // 添加云朵
            for i in 0..<10 {
                let cloud = SKShapeNode(circleOfRadius: CGFloat.random(in: 30...60))
                cloud.fillColor = SKColor(white: 1.0, alpha: 0.7)
                cloud.position = CGPoint(
                    x: CGFloat(i) * (levelData.width / 10) + CGFloat.random(in: -50...50),
                    y: size.height - CGFloat.random(in: 80...150)
                )
                cloud.zPosition = -80
                backgroundLayer.addChild(cloud)
            }
            // 添加树
            for i in 0..<Int(levelData.width / 300) {
                let tree = createTree()
                tree.position = CGPoint(x: CGFloat(i) * 300 + 100, y: 50)
                backgroundLayer.addChild(tree)
            }

        case "underground", "ruins":
            // 添加火把
            for i in 0..<Int(levelData.width / 400) {
                let torch = createTorch()
                torch.position = CGPoint(x: CGFloat(i) * 400 + 200, y: 150)
                backgroundLayer.addChild(torch)
            }

        case "volcano":
            // 添加岩浆池
            for i in 0..<Int(levelData.width / 500) {
                let lava = SKShapeNode(ellipseOf: CGSize(width: 200, height: 30))
                lava.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.8)
                lava.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 0.0, alpha: 1.0)
                lava.position = CGPoint(x: CGFloat(i) * 500 + 250, y: 25)
                backgroundLayer.addChild(lava)
            }

        default:
            break
        }
    }

    private func createTree() -> SKNode {
        let tree = SKNode()

        // 树干
        let trunk = SKShapeNode(rect: CGRect(x: -10, y: 0, width: 20, height: 60))
        trunk.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        // 树冠
        let foliage = SKShapeNode(circleOfRadius: 40)
        foliage.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        foliage.strokeColor = .clear
        foliage.position = CGPoint(x: 0, y: 80)
        tree.addChild(foliage)

        return tree
    }

    private func createTorch() -> SKNode {
        let torch = SKNode()

        // 支架
        let holder = SKShapeNode(rect: CGRect(x: -5, y: 0, width: 10, height: 40))
        holder.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        holder.strokeColor = .clear
        torch.addChild(holder)

        // 火焰
        let flame = SKShapeNode(circleOfRadius: 12)
        flame.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        flame.strokeColor = .clear
        flame.position = CGPoint(x: 0, y: 50)
        torch.addChild(flame)

        return torch
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
        // 关卡信息
        levelLabel = SKLabelNode(text: "Level \(levelData.levelNumber): \(levelData.name)")
        levelLabel.fontName = "Helvetica-Bold"
        levelLabel.fontSize = 22
        levelLabel.fontColor = .yellow
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height - 30)
        levelLabel.horizontalAlignmentMode = .center
        cameraNode.addChild(levelLabel)

        // 分数
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 60)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        // 生命
        healthLabel = SKLabelNode(text: "Health: 3")
        healthLabel.fontName = "Helvetica-Bold"
        healthLabel.fontSize = 24
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: 80, y: size.height - 90)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        // 时间
        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "Helvetica-Bold"
        timeLabel.fontSize = 24
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 80, y: size.height - 120)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)

        // 难度星星显示
        var stars = ""
        for i in 1...5 {
            stars += i <= levelData.difficulty ? "★" : "☆"
        }
        let difficultyLabel = SKLabelNode(text: stars)
        difficultyLabel.fontName = "Helvetica-Bold"
        difficultyLabel.fontSize = 18
        difficultyLabel.fontColor = .orange
        difficultyLabel.position = CGPoint(x: size.width - 120, y: size.height - 60)
        difficultyLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(difficultyLabel)
    }

    private func setupControlArea() {
        // 按钮大小和位置（camera-relative 坐标，对应屏幕左下/右下角）
        let buttonRadius: CGFloat = 50
        // 屏幕底部 y = 90 → camera-relative y = -size.height/2 + 90
        let buttonY: CGFloat = -size.height / 2 + 90
        let buttonSpacing: CGFloat = 110  // 按钮间距

        // ===== 左下角：方向键 ◀ ▶ =====
        // 屏幕左边缘 x = 90 → camera-relative x = -size.width/2 + 90
        let leftBaseX: CGFloat = -size.width / 2 + 90  // ◀ 按钮中心 X

        // ◀ 左方向按钮
        leftButton = SKShapeNode(circleOfRadius: buttonRadius)
        leftButton.fillColor = SKColor(white: 0.2, alpha: 0.85)
        leftButton.strokeColor = SKColor(white: 1.0, alpha: 0.9)
        leftButton.lineWidth = 3
        leftButton.position = CGPoint(x: leftBaseX, y: buttonY)
        leftButton.name = "leftButton"
        cameraNode.addChild(leftButton)

        let leftArrow = SKLabelNode(text: "◀")
        leftArrow.fontName = "Helvetica-Bold"
        leftArrow.fontSize = 36
        leftArrow.fontColor = .white
        leftArrow.position = CGPoint(x: 0, y: -10)
        leftButton.addChild(leftArrow)

        // ▶ 右方向按钮（紧贴 ◀ 右边）
        rightButton = SKShapeNode(circleOfRadius: buttonRadius)
        rightButton.fillColor = SKColor(white: 0.2, alpha: 0.85)
        rightButton.strokeColor = SKColor(white: 1.0, alpha: 0.9)
        rightButton.lineWidth = 3
        rightButton.position = CGPoint(x: leftBaseX + buttonSpacing, y: buttonY)
        rightButton.name = "rightButton"
        cameraNode.addChild(rightButton)

        let rightArrow = SKLabelNode(text: "▶")
        rightArrow.fontName = "Helvetica-Bold"
        rightArrow.fontSize = 36
        rightArrow.fontColor = .white
        rightArrow.position = CGPoint(x: 0, y: -10)
        rightButton.addChild(rightArrow)

        // ===== 右下角：跳跃 ▲ + 攻击 ATK =====
        // 屏幕右边缘 x = size.width - 90 → camera-relative x = size.width/2 - 90
        let rightBaseX: CGFloat = size.width / 2 - 90  // ATK 按钮中心 X

        // ▲ 跳跃按钮（靠内侧，靠近中心）
        jumpButton = SKShapeNode(circleOfRadius: buttonRadius)
        jumpButton.fillColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.85)
        jumpButton.strokeColor = SKColor(white: 1.0, alpha: 0.9)
        jumpButton.lineWidth = 3
        jumpButton.position = CGPoint(x: rightBaseX - buttonSpacing, y: buttonY)
        jumpButton.name = "jumpButton"
        cameraNode.addChild(jumpButton)

        let jumpLabel = SKLabelNode(text: "▲")
        jumpLabel.fontName = "Helvetica-Bold"
        jumpLabel.fontSize = 32
        jumpLabel.fontColor = .white
        jumpLabel.position = CGPoint(x: 0, y: -8)
        jumpButton.addChild(jumpLabel)

        // ATK 攻击按钮（靠外侧）
        attackButton = SKShapeNode(circleOfRadius: buttonRadius)
        attackButton.fillColor = SKColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 0.85)
        attackButton.strokeColor = SKColor(white: 1.0, alpha: 0.9)
        attackButton.lineWidth = 3
        attackButton.position = CGPoint(x: rightBaseX, y: buttonY)
        attackButton.name = "attackButton"
        cameraNode.addChild(attackButton)

        let attackLabel = SKLabelNode(text: "ATK")
        attackLabel.fontName = "Helvetica-Bold"
        attackLabel.fontSize = 22
        attackLabel.fontColor = .white
        attackLabel.position = CGPoint(x: 0, y: -6)
        attackButton.addChild(attackLabel)
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
        guard let touch = touches.first, !isGameOver else { return }
        let location = touch.location(in: cameraNode)
        let node = self.cameraNode.atPoint(location)

        switch node.name {
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isLeftPressed = false
        isRightPressed = false
        isJumpPressed = false
        isAttackPressed = false
    }

    // MARK: - 更新逻辑

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // 玩家移动
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

        // 摄像机跟随玩家
        let targetX = max(min(player.position.x, levelData.width - size.width / 2), size.width / 2)
        cameraNode.position.x = targetX

        // 更新玩家状态
        player.update()

        // 检查关卡完成（到达终点）
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
        healthLabel.text = "Health: \(health)"
        if health <= 0 {
            gameOver()
        }
    }

    private func gameOver() {
        isGameOver = true
        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = scaleMode
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
        levelCompleteScene.scaleMode = scaleMode
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(levelCompleteScene, transition: transition)
    }

    // MARK: - 碰撞检测

    func didCollideWithEnemy() {
        takeDamage()
    }
}