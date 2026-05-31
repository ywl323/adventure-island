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
    private var isJumpConsumed: Bool = false  // 本次按键周期是否已消耗跳跃（防止按住一直跳）
    private var isAttackPressed: Bool = false
    private var isAttackConsumed: Bool = false  // 本次按键周期是否已消耗攻击

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


    // 玩家初始Y
    private let playerStartY: CGFloat = Constants.playerStartY

    // MARK: - 初始化

    init(size: CGSize, levelData: LevelData) {
        self.levelData = levelData
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) { super.didMove(to: view); 
        print("🔥 GameScene.didMove called! size=\(size), level=\(levelData.levelNumber), terrain=\(levelData.terrainType)")
        gameTime = levelData.timeLimit
        print("   levelData.width=\(levelData.width), levelData.timeLimit=\(gameTime)")
        preloadTexturesOnce()
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
        print("🎨 GameScene setup complete. frame=\(frame), children=\(children.count)")
    }


    // MARK: - 设置

    // 游戏全程只预加载一次纹理（通过 flag 保证）
    private static var texturesPreloaded: Bool = false

    private func preloadTexturesOnce() {
        guard !GameScene.texturesPreloaded else { return }
        GameScene.texturesPreloaded = true

        let allTextureNames = Set(
            Array(EntityTypeMapping.enemy.values) +
            Array(EntityTypeMapping.item.values) +
            Array(EntityTypeMapping.boss.values) +
            [
                "01_player_master_higgins",
                "bg_world1", "bg_world2", "bg_world3", "bg_world4",
                "26_decoration_palm_tree", "22_decoration_clouds",
                "32_projectile_fireball",
                "adventure_island_logo1", "adventure_island_logo2", "adventure_island_logo3"
            ]
        )
        TextureCache.shared.preload(named: Array(allTextureNames))
    }

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

        // 设置场景背景色为蓝色天空（与 bg_world1 天空匹配），避免初始黑屏
        self.backgroundColor = SKColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)  // 初始纯色天空

        // 背景放在 cameraNode 子节点（跟随相机，永远填满屏幕）
        let bgImageName = getBackgroundImageName()
        if UIImage(named: bgImageName) != nil {
            let bgNode = SKSpriteNode(imageNamed: bgImageName)
            bgNode.size = CGSize(width: 1280, height: 720)  // 原始像素分辨率
            bgNode.position = CGPoint(x: 0, y: 0)  // 相对相机居中
            bgNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bgNode.zPosition = -100
            cameraNode.addChild(bgNode)  // 跟随相机，永远在屏幕中央
        } else {
            // 无背景图时用纯色（放在 backgroundLayer，跟随世界坐标）
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
            let bg = SKSpriteNode(color: bgColor, size: CGSize(width: levelData.width, height: size.height))
            bg.position = CGPoint(x: levelData.width / 2, y: size.height / 2)
            bg.zPosition = -100
            backgroundLayer.addChild(bg)
        }
        backgroundLayer.position.x = 0

        // 添加地面（物理边界）
        let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: levelData.width, height: 50))
        ground.fillColor = getGroundColor()
        ground.strokeColor = .clear
        ground.zPosition = -50
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: levelData.width, y: 0))
        ground.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategories.player
        backgroundLayer.addChild(ground)
        // 终点线：交替方块条纹 + 垂直光晕，更有视觉吸引力
        let goalX = levelData.width - 200
        let goalNode = SKNode()
        goalNode.position = CGPoint(x: goalX, y: 0)
        goalNode.zPosition = -40

        // 交替方块条纹（黑白相间）
        let stripeCount = Int(size.height / 20)
        let stripeW: CGFloat = 12
        let stripeH: CGFloat = 20
        for i in 0..<stripeCount {
            let stripe = SKShapeNode(rect: CGRect(x: -stripeW/2, y: CGFloat(i)*stripeH, width: stripeW, height: stripeH))
            stripe.fillColor = i % 2 == 0 ? SKColor(white: 1.0, alpha: 0.5) : SKColor(white: 0.0, alpha: 0.6)
            stripe.strokeColor = .clear
            goalNode.addChild(stripe)
        }
        // 外框光晕（垂直金色光效）
        let glowLeft = SKShapeNode(rect: CGRect(x: -stripeW/2-6, y: 0, width: 3, height: size.height))
        glowLeft.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 0.4)
        glowLeft.strokeColor = .clear
        goalNode.addChild(glowLeft)
        let glowRight = SKShapeNode(rect: CGRect(x: stripeW/2+3, y: 0, width: 3, height: size.height))
        glowRight.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 0.4)
        glowRight.strokeColor = .clear
        goalNode.addChild(glowRight)
        backgroundLayer.addChild(goalNode)

        // 终点的物理体（传感器，仅触发碰撞回调）
        let goalSensor = SKPhysicsBody(rectangleOf: CGSize(width: stripeW, height: size.height))
        goalSensor.isDynamic = false
        goalSensor.categoryBitMask = PhysicsCategories.goal
        goalSensor.contactTestBitMask = PhysicsCategories.player
        goalNode.physicsBody = goalSensor

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
            // 棕榈树跟随世界坐标放置
            for i in 0..<Int(levelData.width / 300) {
                let treeSprite = SKSpriteNode(imageNamed: "26_decoration_palm_tree")
                if treeSprite.texture != nil {
                    let targetHeight = size.height * 0.35
                    let scale = targetHeight / treeSprite.texture!.size().height
                    treeSprite.setScale(scale)
                    treeSprite.position = CGPoint(x: CGFloat(i) * 300 + 80, y: targetHeight / 2)
                    treeSprite.zPosition = -30
                    backgroundLayer.addChild(treeSprite)
                } else {
                    let tree = createTreeNode()
                    tree.position = CGPoint(x: CGFloat(i) * 300 + 80, y: 80)
                    backgroundLayer.addChild(tree)
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
        print("🎨 setupPlayer called, playerStartY=\(playerStartY)")
        player = Player()
        player.position = CGPoint(x: Constants.playerStartX, y: playerStartY)
        player.zPosition = 10
        addChild(player)
        print("   Player added at (\(player.position.x), \(player.position.y))")

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
            // 边界设置完毕后再启动巡逻，避免敌人一开始就在边界外乱走
            enemy.startPatrolling()
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
        levelLabel.fontName = "System"
        levelLabel.fontSize = min(size.width * 0.028, 22)
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 30)
        levelLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(levelLabel)

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "System"
        scoreLabel.fontSize = min(size.width * 0.025, 18)
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 60)
        scoreLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(scoreLabel)

        healthLabel = SKLabelNode(text: "❤️ 3")
        healthLabel.fontName = "System"
        healthLabel.fontSize = min(size.width * 0.025, 18)
        healthLabel.fontColor = .white
        healthLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 90)
        healthLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(healthLabel)

        timeLabel = SKLabelNode(text: "Time: \(gameTime)")
        timeLabel.fontName = "System"
        timeLabel.fontSize = min(size.width * 0.025, 18)
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: -size.width / 2 + 80, y: size.height / 2 - 120)
        timeLabel.horizontalAlignmentMode = .left
        cameraNode.addChild(timeLabel)

        // 暂停按钮（右上角，嵌入式圆角矩形，与控制器风格统一）
        let pauseBtn = SKNode()
        pauseBtn.name = "pauseButton"
        pauseBtn.position = CGPoint(x: size.width / 2 - 45, y: size.height / 2 - 45)
        cameraNode.addChild(pauseBtn)

        let pauseBg = SKShapeNode(rect: CGRect(x: -18, y: -18, width: 36, height: 36), cornerRadius: 8)
        pauseBg.fillColor = SKColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.85)
        pauseBg.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        pauseBg.lineWidth = 2
        pauseBtn.addChild(pauseBg)

        // 两根竖线表示暂停
        let bar1 = SKShapeNode(rect: CGRect(x: -7, y: -8, width: 5, height: 16))
        bar1.fillColor = .white
        bar1.strokeColor = .clear
        pauseBtn.addChild(bar1)

        let bar2 = SKShapeNode(rect: CGRect(x: 2, y: -8, width: 5, height: 16))
        bar2.fillColor = .white
        bar2.strokeColor = .clear
        pauseBtn.addChild(bar2)
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
        scene?.addChild(pauseNode)
        // 暂停菜单固定在屏幕中心（scene 坐标系的屏幕中央）
        pauseNode.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y)

        // 半透明背景
        let overlay = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        overlay.fillColor = SKColor(white: 0, alpha: 0.6)
        overlay.strokeColor = .clear
        overlay.position = .zero
        pauseNode.addChild(overlay)

        // 标题
        let title = SKLabelNode(text: "PAUSED")
        title.fontName = "Helvetica-Bold"
        title.fontSize = 48
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 60)
        pauseNode.addChild(title)

        // 继续按钮：父节点定位置，子节点居中
        let resumeWrap = SKNode()
        resumeWrap.name = "resumeButton"
        resumeWrap.position = CGPoint(x: 0, y: 10)
        pauseNode.addChild(resumeWrap)

        let resumeBg = SKShapeNode(rect: CGRect(x: -100, y: -25, width: 200, height: 50), cornerRadius: 10)
        resumeBg.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.9)
        resumeBg.strokeColor = .white
        resumeBg.lineWidth = 2
        resumeBg.name = "resumeButton"
        resumeBg.position = .zero
        resumeWrap.addChild(resumeBg)

        let resumeLabel = SKLabelNode(text: "► RESUME")
        resumeLabel.fontName = "Helvetica-Bold"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = .white
        resumeLabel.name = "resumeButton"
        resumeLabel.horizontalAlignmentMode = .center
        resumeLabel.verticalAlignmentMode = .center
        resumeLabel.position = CGPoint(x: 0, y: 2)
        resumeWrap.addChild(resumeLabel)

        // 返回菜单按钮
        let menuWrap = SKNode()
        menuWrap.name = "menuButton"
        menuWrap.position = CGPoint(x: 0, y: -60)
        pauseNode.addChild(menuWrap)

        let menuBg = SKShapeNode(rect: CGRect(x: -100, y: -25, width: 200, height: 50), cornerRadius: 10)
        menuBg.fillColor = SKColor(white: 0.2, alpha: 0.8)
        menuBg.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        menuBg.lineWidth = 1.5
        menuBg.name = "menuButton"
        menuBg.position = .zero
        menuWrap.addChild(menuBg)

        let menuLabel = SKLabelNode(text: "MENU")
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontSize = 22
        menuLabel.fontColor = .white
        menuLabel.name = "menuButton"
        menuLabel.horizontalAlignmentMode = .center
        menuLabel.verticalAlignmentMode = .center
        menuLabel.position = CGPoint(x: 0, y: 2)
        menuWrap.addChild(menuLabel)
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
        // D-pad uses buttonRadius=50 in GameUIBuilder, so buttonY = -size.height/2 + 70
        // Match that here so jump/attack align with D-pad
        let buttonY = -size.height / 2 + edgePadding + btnSize
        let rightBaseX = size.width / 2 - edgePadding - btnSize / 2

        // 左右 D-pad 按钮
        let (left, right) = GameUIBuilder.buildControlDpad(
            into: cameraNode,
            size: size,
            buttonRadius: btnSize,
            edgePadding: edgePadding
        )
        leftButton = left
        rightButton = right

        // 跳跃按钮
        jumpButton = GameUIBuilder.buildJumpButton(
            into: cameraNode,
            at: CGPoint(x: rightBaseX - 132, y: buttonY),
            buttonRadius: btnSize
        )

        // 攻击按钮
        attackButton = GameUIBuilder.buildAttackButton(
            into: cameraNode,
            at: CGPoint(x: rightBaseX, y: buttonY),
            buttonRadius: btnSize
        )
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
        for touch in touches {
            let locInScene = touch.location(in: self)
            let locInCamera = touch.location(in: cameraNode)
            print("📍 touchesBegan: scene=\(locInScene), camera=\(locInCamera)")
        }

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

            let jumpBtnFrame = CGRect(
                x: jumpButton.position.x - 30,
                y: jumpButton.position.y - 30,
                width: 60,
                height: 60
            )
            let attackBtnFrame = CGRect(
                x: attackButton.position.x - 30,
                y: attackButton.position.y - 30,
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
            } else if jumpBtnFrame.contains(location) {
                activeTouches[touch] = "jumpButton"
                handleButtonDown("jumpButton")
                print("🟢 touchesBegan: JUMP button at \(location)")
            } else if attackBtnFrame.contains(location) {
                activeTouches[touch] = "attackButton"
                handleButtonDown("attackButton")
                print("🟢 touchesBegan: ATTACK button at \(location)")
            } else {
                print("❓ touchesBegan: no button hit at \(location)")
                print("   jumpBtn at \(jumpButton.position) frame=\(jumpBtnFrame)")
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
            isJumpConsumed = false
            print("🟢 handleButtonDown: JUMP pressed — player.isGrounded=\(player?.isGrounded ?? false)")
            player?.jump()
            isJumpConsumed = true
        case "attackButton":
            isAttackPressed = true
            print("🟢 handleButtonDown: ATTACK")
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
            isJumpConsumed = false  // 松开手指后重置，下次按下可以再跳
        case "attackButton":
            isAttackPressed = false
            isAttackConsumed = false
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

        // 跳跃完全由 handleButtonDown 处理，update() 不再参与

        if isAttackPressed && !isAttackConsumed {
            print("⚔️ update: calling player.attack()")
            player.attack()
            checkAttackHits()  // 修复：攻击后立即检测是否命中敌人
            isAttackConsumed = true
        }

        // 摄像机跟随（水平）
        let minX = size.width / 2
        let maxX = levelData.width - size.width / 2
        let clampedX = max(minX, min(player.position.x, maxX))
        cameraNode.position.x = clampedX

        // 背景层固定在世界坐标，不跟随相机移动
        // 这样当玩家向右移动时，背景保持不动，相机跟随玩家产生滚动感
        backgroundLayer.position.x = 0

        player.update()

        // 检查玩家是否到达终点（坐标检测，兜底方案）
        if player.position.x >= levelData.width - 150 {
            levelComplete()
        }

        // 防止玩家掉落出屏幕
        if player.position.y < 50 {
            player.position.y = playerStartY
            player.stop()
        }

        // 清理已死亡敌人（从数组移除，避免无效遍历）
        enemies.removeAll { $0.parent == nil }
        // 清理已收集的物品（同理）
        items.removeAll { $0.parent == nil }
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
        } else if maskA == PhysicsCategories.player && maskB == PhysicsCategories.goal {
            // 玩家到达终点
            levelComplete()
        } else if maskB == PhysicsCategories.player && maskA == PhysicsCategories.goal {
            // 玩家到达终点
            levelComplete()
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
        // 受伤冷却期内不能再受伤
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.damageCooldown) { [weak self] in
            self?.damageCooldown = false
        }
    }

    private func collectItem(_ item: Item) {
        guard item.parent != nil else { return }  // 防止重复收集
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
        let attackRange: CGFloat = Constants.attackRange
        let playerX = player.position.x
        let playerY = player.position.y
        let attackDirection: CGFloat = player.getFacingDirection()

        /* hitEnemy tracked for potential future use */

        for enemy in enemies {
            let dx = enemy.position.x - playerX
            let dy = enemy.position.y - playerY
            let distance = sqrt(dx * dx + dy * dy)

            // 在攻击范围内且方向正确（同侧）
            if distance <= attackRange && sign(dx) == attackDirection {
                enemy.takeDamage(1)
                // hitEnemy = true (potential future use)
                addScore(enemy.getScoreValue())
            }
        }

        // 攻击命中后设置冷却，防止一次攻击重复判定
        attackHitCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.attackCooldown) { [weak self] in
            self?.attackHitCooldown = false
        }
    }

    private func sign(_ x: CGFloat) -> CGFloat {
        return x >= 0 ? 1 : -1
    }
}