import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSKView()
    }

    private func setupSKView() {
        // 使用屏幕准确像素尺寸
        let screenBounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale

        // 横屏时 screenBounds.width > height
        // 使用原始bounds作为逻辑像素尺寸（避免乘以scale导致过大）
        skView = SKView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height))
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.preferredFramesPerSecond = 60
        skView.backgroundColor = .black

        view.addSubview(skView)

        print("📱 GameViewController: screenBounds=\(screenBounds), scale=\(scale)")
        print("📱 GameViewController: skView frame=\(skView.frame)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if skView.scene == nil {
            loadMenuScene()
        }
    }

    private func loadMenuScene() {
        // 使用 skView 的实际 frame 作为 scene size（逻辑像素）
        let sceneSize = skView.bounds.size
        print("🔧 GameViewController: loading MenuScene with sceneSize=\(sceneSize)")
        print("🔧 GameViewController: skView bounds=\(skView.bounds), frame=\(skView.frame)")

        let menuScene = MenuScene(size: sceneSize)
        menuScene.scaleMode = .resizeFill  // scene 完全填充屏幕
        skView.presentScene(menuScene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return []
    }

    override var shouldAutorotate: Bool {
        return true
    }
}