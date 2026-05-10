import Foundation

class GameManager {

    // MARK: - 单例
    static let shared = GameManager()
    private init() {}

    // MARK: - 游戏状态
    enum GameState {
        case menu
        case playing
        case paused
        case gameOver
    }

    private(set) var currentState: GameState = .menu

    // MARK: - 游戏数据
    private(set) var currentLevel: Int = 1
    private(set) var score: Int = 0
    private(set) var lives: Int = 3

    // MARK: - 关卡配置
    private let maxLevel: Int = 10

    // MARK: - 状态切换

    func startGame() {
        currentState = .playing
        score = 0
        lives = 3
        currentLevel = 1
        print("GameManager: 游戏开始")
    }

    func pauseGame() {
        if currentState == .playing {
            currentState = .paused
            print("GameManager: 游戏暂停")
        }
    }

    func resumeGame() {
        if currentState == .paused {
            currentState = .playing
            print("GameManager: 游戏恢复")
        }
    }

    func endGame() {
        currentState = .gameOver
        saveHighScore()
        print("GameManager: 游戏结束 - 最终分数: \(score)")
    }

    func backToMenu() {
        currentState = .menu
        print("GameManager: 返回主菜单")
    }

    // MARK: - 分数管理

    func addScore(_ points: Int) {
        score += points
        NotificationCenter.default.post(name: .scoreDidChange, object: nil, userInfo: ["score": score])
    }

    func resetScore() {
        score = 0
    }

    // MARK: - 生命管理

    func loseLife() -> Bool {
        lives -= 1
        NotificationCenter.default.post(name: .livesDidChange, object: nil, userInfo: ["lives": lives])
        if lives <= 0 {
            endGame()
            return false
        }
        return true
    }

    func addLife() {
        lives += 1
        NotificationCenter.default.post(name: .livesDidChange, object: nil, userInfo: ["lives": lives])
    }

    // MARK: - 关卡管理

    func nextLevel() {
        if currentLevel < maxLevel {
            currentLevel += 1
            print("GameManager: 进入关卡 \(currentLevel)")
            NotificationCenter.default.post(name: .levelDidChange, object: nil, userInfo: ["level": currentLevel])
        } else {
            print("GameManager: 已通过所有关卡!")
            endGame()
        }
    }

    func getCurrentLevel() -> Int {
        return currentLevel
    }

    // MARK: - 存档

    private func saveHighScore() {
        let defaults = UserDefaults.standard
        let highScore = defaults.integer(forKey: "highScore")
        if score > highScore {
            defaults.set(score, forKey: "highScore")
            print("GameManager: 新纪录! 分数: \(score)")
        }
    }

    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: "highScore")
    }
}

// MARK: - 通知扩展

extension Notification.Name {
    static let scoreDidChange = Notification.Name("scoreDidChange")
    static let livesDidChange = Notification.Name("livesDidChange")
    static let levelDidChange = Notification.Name("levelDidChange")
}
