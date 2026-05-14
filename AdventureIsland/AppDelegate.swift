import UIKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // iOS 13+ 使用 SceneDelegate 管理窗口，AppDelegate 不需要创建 window
        return true
    }

    // MARK: - UISceneSession lifecycle (required for iOS 13+)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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