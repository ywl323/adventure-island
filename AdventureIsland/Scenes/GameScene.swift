import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {

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

    // 受伤冷却（防止一帧内多次受伤）
    private var damageCooldown: Bool = false

    // 攻击冷却（防止一秒内多次攻击判定）
    private var attackHitCooldown: Bool = false

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

    // MARK: - 暂停
    private var isPausedGame: Bool = false
    private var pauseNode: SKNode!

    // 已计分的敌人（防止重复加分）
    private var scoredEnemies: Set<ObjectIdentifier> = []

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
        setupAudio()
    }

    // MARK: - 设置

    private func setupPhysics() {
        worldBounds = CGRect(x: 0, y: 0, width: levelData.width, height: size.height)
        physicsWorld.gravity = CGVector(dx: 0, dy: -Constants.gravity)
        physicsWorld.contactDelegate = self
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        // 初始位置在玩家附近，这样玩家一进入就能看到
        cameraNode.position = CGPoint(x: 200, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupBackground() {
        backgroundLayer = SKNode()
        addChild(backgroundLayer)

        // Try to load background image first, fall back to solid color
        let bgImageName = getBackgroundImageName()
        let background: SKSpriteNode
        if let _ = UIImage(named: bgImageName) {
            background = SKSpriteNode(imageNamed: bgImageName)
            background.size = size
        } else {
            // Fall back to solid color background
            let bgColor: SKColor
            switch levelData.terrainType {
            case "grass":    bgColor = SKColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)
            case "water":    bgColor = SKColor(red: 0.25, green: 0.55, blue: 0.85, alpha: 1.0)
            case "underground": bgColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
            case "volcano":  bgColor = SKColor(red: 0.5, green: 0.15, blue: 0.08, alpha: 1.0)
            case "sky":      bgColor = SKColor(red: 0.4, green: 0.55, blue: 0.85, alpha: 1.0)
            case "cliff":    bgColor = SKColor(red: 0.55, green: 0.65, blue: 0.75, alpha: 1.0)
            case "ruins":    bgColor = SKColor(red: 0.25, green: 0.3, blue: 0.25, alpha: 1.0)
            case "boss":     bgColor = SKColor(red: 0.3, green: 0.15, blue: 0.25, alpha: 1.0)
            default:        bgColor = SKColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)
            }
            background = SKSpriteNode(color: bgColor, size: size)
        }
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -100
        backgroundLayer.addChild(background)

        // 添加地面（物理边界）
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

    private func getBackgroundImageName() -> String {
        let world = (levelData.levelNumber - 1) / 4 + 1
        return "bg_world\(world)"
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
            // 棕榈树（使用中等尺寸 PNG）
            for i in 0..<Int(levelData.width / 300) {
                let treeSprite = SKSpriteNode(imageNamed: "26_decoration_palm_tree")
                if treeSprite.texture != nil {
                    // 根据屏幕尺寸计算大小，保持比例
                    let targetHeight = size.height * 0.35
                    let scale = targetHeight / treeSprite.texture!.size().height
                    treeSprite.setScale(scale)
                    treeSprite.position = CGPoint(x: CGFloat(i) * 300 + 80, y: targetHeight / 2)
                    treeSprite.zPosition = -30
                    backgroundLayer.addChild(treeSprite)
                    print("🌴 Tree PNG: scaled to \(treeSprite.frame.size)")
                } else {
                    let tree = createTreeNode()
                    tree.position = CGPoint(x: CGFloat(i) * 300 + 80, y: 80)
                    backgroundLayer.addChild(tree)
                }
            }

            // 云朵（中等尺寸 PNG，根据屏幕比例）
            for i in 0..<6 {
                let cloudSprite = SKSpriteNode(imageNamed: "22_decoration_clouds")
                if cloudSprite.texture != nil {
                    let targetWidth = size.width * 0.25  // 屏幕宽度的25%作为云宽度
                    let scale = targetWidth / cloudSprite.texture!.size().width
                    cloudSprite.setScale(scale)
                    cloudSprite.position = CGPoint(
                        x: CGFloat(i) * (levelData.width / 6) + CGFloat.random(in: -50...50),
                        y: size.height - size.height * 0.12
                    )
                    cloudSprite.zPosition = -80
                    cloudSprite.alpha = 0.9
                    backgroundLayer.addChild(cloudSprite)
                    print("☁️ Cloud PNG: scaled to \(cloudSprite.frame.size)")
                } else {
                    let cloud = createCloudNode()
                    cloud.setScale(size.width / 800)  // 随屏幕调整
                    cloud.position = CGPoint(
                        x: CGFloat(i) * (levelData.width / 6) + CGFloat.random(in: -50...50),
                        y: size.height - size.height * 0.12
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
        let mainBall = SKShapeNode(ellipseOf: CGSize(width: 120, height: 60))
        mainBall.fillColor = white
        mainBall.strokeColor = .clear
        cloud.addChild(mainBall)

        let leftBall = SKShapeNode(ellipseOf: CGSize(width: 80, height: 50))
        leftBall.fillColor = white
        leftBall.strokeColor = .clear
        leftBall.position = CGPoint(x: -55, y: 8)
        cloud.addChild(leftBall)

        let rightBall = SKShapeNode(ellipseOf: CGSize(width: 80, height: 50))
        rightBall.fillColor = white
        rightBall.strokeColor = .clear
        rightBall.position = CGPoint(x: 55, y: 8)
        cloud.addChild(rightBall)

        return cloud
    }

    private func createTreeNode() -> SKNode {
        let tree = SKNode()

        let trunkPath = CGMutablePath()
        trunkPath.move(to: CGPoint(x: -6, y: 0))
        trunkPath.addLine(to: CGPoint(x: 6, y: 0))
        trunkPath.addLine(to: CGPoint(x: 4, y: 55))
        trunkPath.addLine(to: CGPoint(x: -4, y: 55))
        trunkPath.closeSubpath()
        let trunk = SKShapeNode(path: trunkPath)
        trunk.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.12, alpha: 1.0)
        trunk.strokeColor = .clear
        tree.addChild(trunk)

        let foliage1 = SKShapeNode(circleOfRadius: 28)
        foliage1.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.15, alpha: 1.0)
        foliage1.strokeColor = .clear
        foliage1.position = CGPoint(x: 0, y: 65)
        tree.addChild(foliage1)

        let foliage2 = SKShapeNode(circleOfRadius: 22)
        foliage2.fillColor = SKColor(red: 0.18, green: 0.6, blue: 0.18, alpha: 1.0)
        foliage2.strokeColor = .clear
        foliage2.position = CGPoint(x: -20, y: 52)
        tree.addChild(foliage2)

        let foliage3 = SKShapeNode(circleOfRadius: 22)
        foliage3.fillColor = SKColor(red: 0.2, green: 0.65, blue: 0.2, alpha: 1.0)
        foliage3.strokeColor = .clear
        foliage3.position = CGPoint(x: 20, y: 52)
        tree.addChild(foliage3)

        return tree
    }

    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 200, y: playerStartY)
        addChild(player)

        // 打印调试信息
        if let sprite = player.children.first as? SKSpriteNode {
            print("✅ Player spawned at world=(\(player.position.x), \(player.position.y))")
            print("   player frame: \(player.frame)")
            print("   sprite size: \(sprite.size), scale: \(sprite.yScale)")
            print("   scene size: \(size)")
        }
    }

    private func setupEnemies() {
        for enemyData in levelData.enemies {
            let enemy = Enemy(type: enemyData.type)
            enemy.position = CGPoint(x: enemyData.x, y: enemyData.y)
            // 设置巡逻边界：前后各 200 像素范围
            enemy.setPatrolBounds(
                minX: max(0, enemyData.x - 200),
                maxX: min(levelData.width, enemyData.x + 200)
            )
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
        levelLabel.fontSize = min(size.width * 0.028, 22)
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 30)
        levelLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(levelLabel)

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = min(size.width * 0.025, 18)
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 60)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        healthLabel = SKLabelNode(text: "❤️ 3")
        healthLabel.fontName = "Helvetica-Bold"
        healthLabel.fontSize = min(size.width * 0.025, 18)
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 90)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "Helvetica-Bold"
        timeLabel.fontSize = min(size.width * 0.025, 18)
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 120)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)

        // 暂停按钮（右上角）
        let pauseBtn = SKShapeNode(circleOfRadius: 22)
        pauseBtn.fillColor = SKColor(white: 0.1, alpha: 0.7)
        pauseBtn.strokeColor = SKColor(white: 0.8, alpha: 0.8)
        pauseBtn.lineWidth = 2
        pauseBtn.name = "pauseButton"
        pauseBtn.position = CGPoint(x: size.width / 2 - 45, y: size.height / 2 - 45)
        cameraNode.addChild(pauseBtn)

        let pauseIcon = SKLabelNode(text: "⏸")
        pauseIcon.fontSize = 20
        pauseIcon.fontColor = .white
        pauseIcon.name = "pauseButton"
        pauseIcon.position = CGPoint(x: 0, y: -7)
        pauseBtn.addChild(pauseIcon)
    }

    private func setupAudio() {
        // 背景音乐
        AudioManager.shared.loadBGM("bgm_adventure")
        AudioManager.shared.playBGM()

        // 预加载音效
        AudioManager.shared.preloadSounds(["se_jump", "se_attack", "se_coin", "se_hurt", "se_death"])
    }

    // MARK: - 暂停功能

    private func showPauseMenu() {
        isPausedGame = true

        pauseNode = SKNode()
        pauseNode.name = "pauseOverlay"
        pauseNode.position = .zero
        addChild(pauseNode)

        // 半透明背景
        let overlay = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        overlay.fillColor = SKColor(white: 0, alpha: 0.6)
        overlay.strokeColor = .clear
        pauseNode.addChild(overlay)

        // 标题
        let title = SKLabelNode(text: "⏸ PAUSED")
        title.fontName = "Helvetica-Bold"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 60)
        pauseNode.addChild(title)

        // 继续按钮
        let resumeBg = SKShapeNode(rect: CGRect(x: -100, y: -10, width: 200, height: 50), cornerRadius: 10)
        resumeBg.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.9)
        resumeBg.strokeColor = .white
        resumeBg.lineWidth = 2
        resumeBg.name = "resumeButton"
        pauseNode.addChild(resumeBg)

        let resumeLabel = SKLabelNode(text: "▶ RESUME")
        resumeLabel.fontName = "Helvetica-Bold"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = .white
        resumeLabel.name = "resumeButton"
        resumeLabel.position = CGPoint(x: 0, y: 5)
        pauseNode.addChild(resumeLabel)

        // 返回菜单按钮
        let menuBg = SKShapeNode(rect: CGRect(x: -100, y: -70, width: 200, height: 45), cornerRadius: 8)
        menuBg.fillColor = SKColor(white: 0.2, alpha: 0.8)
        menuBg.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        menuBg.lineWidth = 1.5
        menuBg.name = "menuButton"
        pauseNode.addChild(menuBg)

        let menuLabel = SKLabelNode(text: "☰ MENU")
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontSize = 22
        menuLabel.fontColor = .white
        menuLabel.name = "menuButton"
        menuLabel.position = CGPoint(x: 0, y: -5)
        pauseNode.addChild(menuLabel)

        isPausedGame = false
    }

    private func resumeGame() {
        pauseNode?.removeFromParent()
        pauseNode = nil
    }

    private func returnToMenu() {
        AudioManager.shared.stopBGM()
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .resizeFill
        view?.presentScene(menuScene, transition: SKTransition.flipHorizontal(withDuration: 0.5))
    }

    private func togglePause() {
        if pauseNode != nil {
            resumeGame()
        } else {
            showPauseMenu()
        }
    }

    private func setupControlArea() {
        let btnSize: CGFloat = 60
        let edgePadding: CGFloat = 20

        // 按钮 Y 位置：屏幕底部上方
        let buttonY = -size.height / 2 + edgePadding + btnSize / 2

        // === 左按钮（屏幕左下角，◀ 箭头）===
        leftButton = SKNode()
        leftButton.name = "leftButton"
        leftButton.position = CGPoint(x: -size.width / 2 + edgePadding + btnSize / 2, y: buttonY)
        let leftBg = SKShapeNode(circleOfRadius: btnSize / 2)
        leftBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        leftBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        leftBg.lineWidth = 2.5
        leftButton.addChild(leftBg)

        // ◀ 箭头（指向左）
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

        // === 右按钮（◀ 右边的按钮，▶ 箭头）===
        rightButton = SKNode()
        rightButton.name = "rightButton"
        rightButton.position = CGPoint(x: -size.width / 2 + edgePadding + btnSize * 1.6, y: buttonY)
        let rightBg = SKShapeNode(circleOfRadius: btnSize / 2)
        rightBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        rightBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        rightBg.lineWidth = 2.5
        rightButton.addChild(rightBg)

        // ▶ 箭头（指向右）
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

        // === 右下角：跳跃 + 攻击 ===
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
        print("   leftButton ◀  at x=\(leftButton.position.x) (should move LEFT)")
        print("   rightButton ▶ at x=\(rightButton.position.x) (should move RIGHT)")
        print("   jumpButton ▲  at \(jumpButton.position)")
        print("   attackButton at \(attackButton.position)")
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
        // 暂停菜单激活时，触摸只用于菜单按钮
        if pauseNode != nil {
            for touch in touches {
                let location = touch.location(in: pauseNode!)
                let node = pauseNode!.atPoint(location)
                switch node.name {
                case "resumeButton":
                    resumeGame()
                case "menuButton":
                    returnToMenu()
                default:
                    break
                }
            }
            return
        }

        guard !isGameOver else { return }

        for touch in touches {
            let location = touch.location(in: cameraNode)

            // 暂停按钮
            let pauseBtnFrame = CGRect(x: size.width/2 - 45 - 22, y: size.height/2 - 45 - 22, width: 44, height: 44)
            if pauseBtnFrame.contains(location) {
                togglePause()
                return
            }

            // 左按钮命中区域（cameraNode 坐标系）
            let leftBtnFrame = CGRect(
                x: leftButton.position.x - 30,
                y: leftButton.position.y - 30,
                width: 60,
                height: 60
            )
            // 右按钮命中区域
            let rightBtnFrame = CGRect(
                x: rightButton.position.x - 30,
                y: rightButton.position.y - 30,
                width: 60,
                height: 60
            )

            if leftBtnFrame.contains(location) {
                activeTouches[touch] = "leftButton"
                handleButtonDown("leftButton")
                print("🟢 touchesBegan: LEFT button at \(location) → move LEFT")
            } else if rightBtnFrame.contains(location) {
                activeTouches[touch] = "rightButton"
                handleButtonDown("rightButton")
                print("🟢 touchesBegan: RIGHT button at \(location) → move RIGHT")
            } else if jumpButton.frame.contains(location) {
                activeTouches[touch] = "jumpButton"
                handleButtonDown("jumpButton")
                print("🟢 touchesBegan: JUMP button")
            } else if attackButton.frame.contains(location) {
                activeTouches[touch] = "attackButton"
                handleButtonDown("attackButton")
                print("🟢 touchesBegan: ATTACK button")
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let name = activeTouches[touch] {
                handleButtonUp(name)
                activeTouches.removeValue(forKey: touch)
                print("🔴 touchesEnded: \(name)")
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
        // 暂停时停止更新
        if pauseNode != nil { return }
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

        if isAttackPressed && !attackHitCooldown {
            player.attack()
            // 触发攻击判定（延迟一小段时间让动画开始）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.checkAttackHits()
            }
            isAttackPressed = false
        }

        // 摄像机跟随（水平）
        let minX = size.width / 2
        let maxX = levelData.width - size.width / 2
        let clampedX = max(minX, min(player.position.x, maxX))
        cameraNode.position.x = clampedX

        player.update()

        // 防止玩家掉落出屏幕
        if player.position.y < 50 {
            player.position.y = playerStartY
            player.stop()
        }
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        if maskA == PhysicsCategories.player && maskB == PhysicsCategories.ground {
            player?.didContact(with: PhysicsCategories.ground)
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.ground {
            player?.didContact(with: PhysicsCategories.ground)
        } else if maskA == PhysicsCategories.player && maskB == PhysicsCategories.enemy {
            // Player touches enemy — trigger damage
            if let enemyNode = contact.bodyB.node, enemyNode is Enemy {
                didCollideWithEnemy()
            }
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.enemy {
            if let enemyNode = contact.bodyA.node, enemyNode is Enemy {
                didCollideWithEnemy()
            }
        } else if maskA == PhysicsCategories.player && maskB == PhysicsCategories.item {
            if let itemNode = contact.bodyB.node as? Item {
                collectItem(itemNode)
            }
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.item {
            if let itemNode = contact.bodyA.node as? Item {
                collectItem(itemNode)
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        if maskA == PhysicsCategories.player && maskB == PhysicsCategories.ground {
            player?.didEndContact(with: PhysicsCategories.ground)
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.ground {
            player?.didEndContact(with: PhysicsCategories.ground)
        }
    }

    // MARK: - 游戏逻辑

    func addScore(_ points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
        GameData.shared.updateHighScore(score)
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
        guard !damageCooldown && !isGameOver else { return }
        damageCooldown = true
        takeDamage()
        player.takeDamage()
        // 1.5秒冷却期内不能再受伤
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.damageCooldown = false
        }
    }

    private func collectItem(_ item: Item) {
        // 心脏道具恢复生命
        if item.isHealthItem() {
            health = min(health + 1, 3)
            healthLabel.text = "❤️ \(health)"
        } else {
            addScore(item.getValue())
            AudioManager.shared.playSE("se_coin")
        }
        item.collect()
    }

    // MARK: - 攻击判定（每帧检查玩家攻击是否命中敌人）

    private func checkAttackHits() {
        guard attackHitCooldown == false else { return }
        attackHitCooldown = true

        let attackRange: CGFloat = 60
        let playerX = player.position.x
        let playerY = player.position.y
        let attackDirection: CGFloat = player.xScale > 0 ? 1 : -1

        var hitEnemy = false

        for enemy in enemies {
            let dx = enemy.position.x - playerX
            let dy = enemy.position.y - playerY
            let distance = sqrt(dx * dx + dy * dy)

            // 在攻击范围内且方向正确（同侧）
            if distance <= attackRange && sign(dx) == attackDirection {
                enemy.takeDamage(1)
                hitEnemy = true
                addScore(enemy.getScoreValue())
            }
        }

        // 攻击冷却防止连续判定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.attackHitCooldown = false
        }
    }

    private func sign(_ x: CGFloat) -> CGFloat {
        return x >= 0 ? 1 : -1
    }
}