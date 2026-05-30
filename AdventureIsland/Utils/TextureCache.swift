import SpriteKit

/// 纹理缓存管理器
/// 在游戏启动时预加载所有纹理，后续获取直接命中缓存，避免每帧磁盘 IO
final class TextureCache {

    // MARK: - 单例
    static let shared = TextureCache()
    private init() {}

    // MARK: - 缓存
    private var cache: [String: SKTexture] = [:]

    // MARK: - 预加载（游戏启动时调用一次）
    func preload(named names: [String]) {
        for name in names {
            if cache[name] == nil {
                let texture = SKTexture(imageNamed: name)
                if texture.size().width > 0 {
                    cache[name] = texture
                    print("✅ TextureCache: loaded '\(name)' (\(texture.size()))")
                } else {
                    print("⚠️ TextureCache: '\(name)' not found in asset catalog")
                }
            }
        }
    }

    // MARK: - 获取纹理（优先缓存，否则加载后缓存）
    func texture(for name: String) -> SKTexture {
        if let cached = cache[name] {
            return cached
        }
        let texture = SKTexture(imageNamed: name)
        cache[name] = texture
        return texture
    }

    // MARK: - 查询缓存是否已加载（用于降级处理）
    func isLoaded(_ name: String) -> Bool {
        return cache[name] != nil
    }

    // MARK: - 清理（游戏退出时调用）
    func clear() {
        cache.removeAll()
    }
}
