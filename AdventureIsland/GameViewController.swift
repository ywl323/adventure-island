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
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.preferredFramesPerSecond = 60
        skView.backgroundColor = .black
        view.addSubview(skView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 强制 skView 填满整个父 view
        skView.frame = view.bounds

        if skView.scene == nil {
            loadMenuScene()
        }
    }

    private func loadMenuScene() {
        let sceneSize = skView.bounds.size
        print("📱 MenuScene size: \(sceneSize)")

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