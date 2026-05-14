import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSKView()
    }

    private func setupSKView() {
        // 使用屏幕 bounds 作为逻辑像素尺寸
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.preferredFramesPerSecond = 60
        skView.backgroundColor = .clear  // 透明背景，让view Controller的黑色透出来

        view.backgroundColor = .black
        view.addSubview(skView)

        print("📱 GameViewController: screen=\(UIScreen.main.bounds), scale=\(UIScreen.main.scale)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if skView.scene == nil {
            loadMenuScene()
        }
    }

    private func loadMenuScene() {
        let sceneSize = skView.bounds.size
        print("🔧 GameViewController: sceneSize=\(sceneSize)")

        let menuScene = MenuScene(size: sceneSize)
        menuScene.scaleMode = .aspectFit  // 完整显示，不裁剪，两侧可能有黑边
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