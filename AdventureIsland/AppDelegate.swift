import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 创建窗口
        window = UIWindow(frame: UIScreen.main.bounds)

        // 配置 GameViewController
        let gameViewController = GameViewController()
        window?.rootViewController = gameViewController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // 暂停游戏
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // 恢复游戏
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 保存游戏状态
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // 从后台恢复
    }
}
