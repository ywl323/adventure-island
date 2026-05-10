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

        view.addSubview(skView)

        // 加载主菜单场景
        let menuScene = MenuScene(size: skView.bounds.size)
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
