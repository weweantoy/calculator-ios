//
//  HistoryRecord.swift
//  App
//
//  SwiftData 历史记录模型。
//

import Foundation
import SwiftData

@Model
final class HistoryRecord {

    @Attribute(.unique) var id: UUID
    var expression: String       // 用户输入的表达式（人类可读）
    var result: String           // 计算结果（格式化后）
    var timestamp: Date          // 计算时间

    init(expression: String, result: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.expression = expression
        self.result = result
        self.timestamp = timestamp
    }
}