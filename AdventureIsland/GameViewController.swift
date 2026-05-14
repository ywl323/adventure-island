import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSKView()
    }

    private func setupSKView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        // 设置目标帧率 60 FPS
        skView.preferredFramesPerSecond = 60

        // 关键修复：设置 SKView 的 backgroundColor 为黑色
        skView.backgroundColor = .black

        view.addSubview(skView)

        // 延迟加载场景到 viewDidLayoutSubviews，确保 bounds 正确
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 只在首次布局时加载场景
        if skView.scene == nil {
            loadMenuScene()
        }
    }

    private func loadMenuScene() {
        // 使用 skView 的实际 bounds 大小创建场景
        let sceneSize = skView.bounds.size
        print("🔧 GameViewController: loading MenuScene with size \(sceneSize)")

        let menuScene = MenuScene(size: sceneSize)
        menuScene.scaleMode = .aspectFill
        skView.presentScene(menuScene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // 横屏模式
        return .landscape
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return []
    }

    override var shouldAutorotate: Bool {
        return false
    }
}