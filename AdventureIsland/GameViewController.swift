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
        // view.bounds 在 viewDidLoad 时可能还是小尺寸，等 viewDidLayoutSubviews 再正式设置
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.preferredFramesPerSecond = 60
        skView.backgroundColor = .black

        view.addSubview(skView)

        print("📱 GameViewController viewDidLoad: view.bounds=\(view.bounds)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 每次布局都确保 skView 填满整个 view
        skView.frame = view.bounds
        print("🔧 viewDidLayoutSubviews: view.bounds=\(view.bounds), skView.frame=\(skView.frame)")

        if skView.scene == nil {
            loadMenuScene()
        }
    }

    private func loadMenuScene() {
        let sceneSize = skView.bounds.size
        print("🔧 loadMenuScene: sceneSize=\(sceneSize)")

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