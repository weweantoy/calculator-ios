import WidgetKit
import SwiftUI

// MARK: - Entry

struct CalculatorEntry: TimelineEntry {
    let date: Date
    let latest: CalcPayload?
    let history: [CalcPayload]
}

// MARK: - Provider

struct CalculatorProvider: TimelineProvider {

    func placeholder(in context: Context) -> CalculatorEntry {
        CalculatorEntry(
            date: Date(),
            latest: nil,
            history: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CalculatorEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalculatorEntry>) -> Void) {
        let entry = loadEntry()
        // 每 5 分钟刷新一次
        let next = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> CalculatorEntry {
        CalculatorEntry(
            date: Date(),
            latest: AppGroupBridge.shared.readLatestResult(),
            history: Array(AppGroupBridge.shared.readHistory().prefix(20))
        )
    }
}

// MARK: - Deep Link

enum CalculatorDeepLink {
    static let openApp = URL(string: "calc://open")!
    static let openHistory = URL(string: "calc://history")!
}
