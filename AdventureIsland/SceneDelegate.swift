import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // 配置 GameViewController
        let gameViewController = GameViewController()
        window?.rootViewController = gameViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 场景断开
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 恢复游戏
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 暂停游戏
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 从后台恢复
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 保存游戏状态
    }
}
