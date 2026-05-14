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
        // 相机固定在屏幕中心
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
            bgColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0)
        case "water":
            bgColor = SKColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0)
        case "underground":
            bgColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        case "volcano":
            bgColor = SKColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1.0)
        case "sky":
            bgColor = SKColor(red: 0.4, green: 0.5, blue: 0.8, alpha: 1.0)
        case "cliff":
            bgColor = SKColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0)
        case "ruins":
            bgColor = SKColor(red: 0.3, green: 0.35, blue: 0.3, alpha: 1.0)
        case "boss":
            bgColor = SKColor(red: 0.4, green: 0.2, blue: 0.3, alpha: 1.0)
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
        switch levelData.terrainType {
        case "grass":
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
            for i in 0..<Int(levelData.width / 300) {
                let tree = createTree()
                tree.position = CGPoint(x: CGFloat(i) * 300 + 100, y: 50)
                backgroundLayer.addChild(tree)
            }

        case "underground", "ruins":
            for i in 0..<Int(levelData.width / 400) {
                let torch = createTorch()
                torch.position = CGPoint(x: CGFloat(i) * 400 + 200, y: 150)
                backgroundLayer.addChild(torch)
            }

        case "volcano":
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
        let trunk = SKShapeNode(rect: CGRect(x: -10, y: 0, width: 20, height: 60))
        trunk.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)
        let foliage = SKShapeNode(circleOfRadius: 40)
        foliage.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        foliage.strokeColor = .clear
        foliage.position = CGPoint(x: 0, y: 80)
        tree.addChild(foliage)
        return tree
    }

    private func createTorch() -> SKNode {
        let torch = SKNode()
        let holder = SKShapeNode(rect: CGRect(x: -5, y: 0, width: 10, height: 40))
        holder.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        holder.strokeColor = .clear
        torch.addChild(holder)
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
        // 按钮半径改为 28（之前是50），缩小60%
        let buttonRadius: CGFloat = 28

        // 屏幕内边距
        let edgePadding: CGFloat = 30

        // 相机中心在 (size.width/2, size.height/2)
        // 屏幕左下角camera坐标: (-size.width/2 + edgePadding, -size.height/2 + edgePadding)
        // 屏幕右下角camera坐标: (size.width/2 - edgePadding, -size.height/2 + edgePadding)
        let buttonY = -size.height / 2 + edgePadding + buttonRadius
        let leftCenterX = -size.width / 2 + edgePadding + buttonRadius
        let rightCenterX = size.width / 2 - edgePadding - buttonRadius

        // ===== 左下角：◀ ▶ =====
        // ◀ 左方向按钮
        leftButton = SKShapeNode(circleOfRadius: buttonRadius)
        leftButton.fillColor = SKColor(white: 0.15, alpha: 0.8)
        leftButton.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        leftButton.lineWidth = 2
        leftButton.position = CGPoint(x: leftCenterX, y: buttonY)
        leftButton.name = "leftButton"
        cameraNode.addChild(leftButton)

        let leftArrow = SKLabelNode(text: "◀")
        leftArrow.fontName = "Helvetica-Bold"
        leftArrow.fontSize = 26
        leftArrow.fontColor = .white
        leftArrow.position = CGPoint(x: 0, y: -7)
        leftButton.addChild(leftArrow)

        // ▶ 右方向按钮（紧贴 ◀ 右边）
        rightButton = SKShapeNode(circleOfRadius: buttonRadius)
        rightButton.fillColor = SKColor(white: 0.15, alpha: 0.8)
        rightButton.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        rightButton.lineWidth = 2
        rightButton.position = CGPoint(x: leftCenterX + buttonRadius * 2 + 8, y: buttonY)
        rightButton.name = "rightButton"
        cameraNode.addChild(rightButton)

        let rightArrow = SKLabelNode(text: "▶")
        rightArrow.fontName = "Helvetica-Bold"
        rightArrow.fontSize = 26
        rightArrow.fontColor = .white
        rightArrow.position = CGPoint(x: 0, y: -7)
        rightButton.addChild(rightArrow)

        // ===== 右下角：▲ + ATK =====
        // ▲ 跳跃按钮（靠内侧）
        jumpButton = SKShapeNode(circleOfRadius: buttonRadius)
        jumpButton.fillColor = SKColor(red: 0.25, green: 0.5, blue: 1.0, alpha: 0.8)
        jumpButton.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        jumpButton.lineWidth = 2
        jumpButton.position = CGPoint(x: rightCenterX - buttonRadius * 2 - 8, y: buttonY)
        jumpButton.name = "jumpButton"
        cameraNode.addChild(jumpButton)

        let jumpLabel = SKLabelNode(text: "▲")
        jumpLabel.fontName = "Helvetica-Bold"
        jumpLabel.fontSize = 24
        jumpLabel.fontColor = .white
        jumpLabel.position = CGPoint(x: 0, y: -6)
        jumpButton.addChild(jumpLabel)

        // ATK 攻击按钮（靠外侧）
        attackButton = SKShapeNode(circleOfRadius: buttonRadius)
        attackButton.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.8)
        attackButton.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        attackButton.lineWidth = 2
        attackButton.position = CGPoint(x: rightCenterX, y: buttonY)
        attackButton.name = "attackButton"
        cameraNode.addChild(attackButton)

        let attackLabel = SKLabelNode(text: "ATK")
        attackLabel.fontName = "Helvetica-Bold"
        attackLabel.fontSize = 16
        attackLabel.fontColor = .white
        attackLabel.position = CGPoint(x: 0, y: -4)
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

        // 摄像机跟随玩家（水平滚动）
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