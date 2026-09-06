//
//  CalculatorApp.swift
//  App
//
//  iOS App 入口：注册 SwiftData 容器，挂载根视图。
//

import SwiftUI
import SwiftData
import CalculatorCore

@main
struct CalculatorApp: App {

    /// SwiftData 容器：持久化历史记录
    let modelContainer: ModelContainer = {
        let schema = Schema([HistoryRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // 容器创建失败时回退到内存模式
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)  // 默认深色主题
        }
        .modelContainer(modelContainer)
    }
}