import SwiftUI
import CalculatorCore

/// Apple Watch 配套 App 根视图
///
/// 设计要点：
/// - 适配 watchOS 10+ 全新导航模型
/// - 仅保留基础模式（屏幕尺寸限制）
/// - 与 iOS App 通过 App Group 同步最近一次计算结果
struct ContentView: View {
    @State private var viewModel = WatchCalculatorViewModel()

    var body: some View {
        NavigationStack {
            WatchCalculatorView(viewModel: viewModel)
                .navigationTitle("计算器")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
