import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSKView()
    }

    private func setupSKView() {
        // 直接使用完整屏幕 bounds，不依赖 view.bounds
        let screenBounds = UIScreen.main.bounds
        skView = SKView(frame: screenBounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.preferredFramesPerSecond = 60
        skView.backgroundColor = .black

        // 确保 view 填满屏幕（去除 navigationBar 等）
        view.addSubview(skView)

        print("📱 GameViewController: screen=\(screenBounds), scale=\(UIScreen.main.scale)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 强制 skView 填满整个 viewController 的 view
        skView.frame = view.bounds

        if skView.scene == nil {
            loadMenuScene()
        }
    }

    private func loadMenuScene() {
        // 使用 skView 的实际尺寸作为 scene size
        let sceneSize = skView.bounds.size
        print("🔧 GameViewController: sceneSize=\(sceneSize)")

        let menuScene = MenuScene(size: sceneSize)
        menuScene.scaleMode = .resizeFill
        skView.presentScene(menuScene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return true
    }
}