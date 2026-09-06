import Foundation

/// App Group 桥接：用于在 iOS 主 App、Apple Watch、Widget Extension
/// 之间共享最近一次计算结果和历史记录。
///
/// 使用 `UserDefaults(suiteName:)` 做持久化（无需 CloudKit，App Store 审核友好）。
/// 所有写入/读取均为 main actor 安全的（NSUserDefaults 内部序列化）。
public final class AppGroupBridge {

    public static let shared = AppGroupBridge()

    /// App Group Identifier —— 必须与三个 Target 的 entitlements 完全一致
    public static let appGroupID = "group.com.workbuddy.calc"

    // MARK: - 键名

    public enum Key {
        /// 最近一次计算：JSON 字符串
        public static let latestResult = "calc.latestResult"
        /// 历史记录列表：JSON 字符串数组
        public static let history = "calc.history"
        /// Widget 主动刷新时间戳
        public static let widgetRefreshAt = "calc.widgetRefreshAt"
    }

    private let defaults: UserDefaults

    private init() {
        // 默认使用标准 UserDefaults（开发/测试阶段）
        // 在真机上如果 App Group 已配置，会自动回退到 suite 存储
        if let suite = UserDefaults(suiteName: Self.appGroupID) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
    }

    // MARK: - 最新结果

    /// 写入最新计算结果
    public func writeLatestResult(expression: String, result: Decimal) {
        let payload = CalcPayload(
            expression: expression,
            result: NumberFormatter.format(result),
            timestamp: Date()
        )
        if let data = try? JSONEncoder().encode(payload),
           let json = String(data: data, encoding: .utf8) {
            defaults.set(json, forKey: Key.latestResult)
            defaults.set(Date().timeIntervalSince1970, forKey: Key.widgetRefreshAt)
        }
    }

    /// 读取最新计算结果
    public func readLatestResult() -> CalcPayload? {
        guard let json = defaults.string(forKey: Key.latestResult),
              let data = json.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(CalcPayload.self, from: data)
    }

    // MARK: - 历史记录

    /// 追加一条历史（最多保留 100 条，倒序）
    public func appendHistory(expression: String, result: Decimal) {
        var history = readHistory()
        history.insert(
            CalcPayload(
                expression: expression,
                result: NumberFormatter.format(result),
                timestamp: Date()
            ),
            at: 0
        )
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        if let data = try? JSONEncoder().encode(history),
           let json = String(data: data, encoding: .utf8) {
            defaults.set(json, forKey: Key.history)
        }
    }

    /// 读取历史
    public func readHistory() -> [CalcPayload] {
        guard let json = defaults.string(forKey: Key.history),
              let data = json.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([CalcPayload].self, from: data)) ?? []
    }

    /// 清空历史
    public func clearHistory() {
        defaults.removeObject(forKey: Key.history)
    }

    /// 触发 Widget 刷新（iOS 17+ API）
    public func requestWidgetRefresh() {
        // 标记刷新时间，WidgetTimelineProvider 会读取这个值决定 reload
        defaults.set(Date().timeIntervalSince1970, forKey: Key.widgetRefreshAt)
    }
}

/// 计算结果（轻量、跨 Target 安全）
public struct CalcPayload: Codable, Identifiable, Equatable, Hashable {
    public var id: UUID
    public var expression: String
    public var result: String
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        expression: String,
        result: String,
        timestamp: Date
    ) {
        self.id = id
        self.expression = expression
        self.result = result
        self.timestamp = timestamp
    }
}
