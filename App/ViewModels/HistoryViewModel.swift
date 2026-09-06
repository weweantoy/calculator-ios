//
//  HistoryViewModel.swift
//  App
//
//  历史记录 ViewModel：查询、删除、清空。
//  通过 AppGroupBridge 与 Apple Watch / Widget Extension 共享数据。
//

import Foundation
import SwiftData
import Combine
import WidgetKit
import CalculatorCore

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published private(set) var records: [HistoryRecord] = []

    private var context: ModelContext?

    init(context: ModelContext? = nil) {
        self.context = context
        fetch()
    }

    func attach(_ context: ModelContext) {
        self.context = context
        fetch()
    }

    /// 加载历史记录（按时间倒序）。若 App Group 中已有数据，优先合并。
    func fetch() {
        guard let ctx = context else { return }
        let descriptor = FetchDescriptor<HistoryRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            records = try ctx.fetch(descriptor)
        } catch {
            records = []
        }
    }

    /// 同步本地历史到 App Group（供 Watch / Widget 读取）
    /// 策略：本地 records 已按时间倒序（最新在 [0]），appendHistory 是 LIFO 头插，
    /// 故按顺序遍历原数组即可在 App Group 中保持"最新在前"的顺序。
    func syncToAppGroup() {
        AppGroupBridge.shared.clearHistory()
        for record in records {
            guard let exprValue = Decimal(string: record.expression),
                  let resultValue = Decimal(string: record.result) else { continue }
            AppGroupBridge.shared.appendHistory(
                expression: record.expression,
                result: exprValue
            )
            AppGroupBridge.shared.writeLatestResult(
                expression: record.expression,
                result: resultValue
            )
        }
        AppGroupBridge.shared.requestWidgetRefresh()
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// 删除单条
    func delete(_ record: HistoryRecord) {
        guard let ctx = context else { return }
        ctx.delete(record)
        try? ctx.save()
        fetch()
        syncToAppGroup()
    }

    /// 清空全部
    func clearAll() {
        guard let ctx = context else { return }
        for record in records {
            ctx.delete(record)
        }
        try? ctx.save()
        AppGroupBridge.shared.clearHistory()
        WidgetCenter.shared.reloadAllTimelines()
        fetch()
    }
}