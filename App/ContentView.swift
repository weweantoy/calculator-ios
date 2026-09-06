//
//  ContentView.swift
//  App
//
//  根视图：组合显示区、模式切换器、键盘与历史入口。
//

import SwiftUI
import CalculatorCore

struct ContentView: View {

    @StateObject private var calculatorVM = CalculatorViewModel()
    @Environment(\.modelContext) private var modelContext

    @State private var showHistory: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer(minLength: 0)

                DisplayView(
                    expression: calculatorVM.expressionString,
                    result: calculatorVM.displayString,
                    error: calculatorVM.errorMessage
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if calculatorVM.mode == .basic {
                    BasicCalculatorView(viewModel: calculatorVM)
                } else {
                    ScientificCalculatorView(viewModel: calculatorVM)
                }
            }
            .padding(.bottom, 8)

            if showHistory {
                HistoryPanelView(
                    historyVM: HistoryViewModel(context: modelContext),
                    onSelect: { record in
                        calculatorVM.applyHistory(record)
                        showHistory = false
                    },
                    onClose: { showHistory = false }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showHistory)
        .onAppear {
            // 注入 SwiftData 上下文（仅在首次出现时执行）
            calculatorVM.attachHistoryContext(modelContext)
        }
        .onOpenURL { url in
            // 来自 Widget / Watch / 外部的 Deep Link
            // calc://open          → 打开主界面
            // calc://history       → 打开历史面板
            switch url.host {
            case "history":
                showHistory = true
            default:
                showHistory = false
            }
        }
    }

    // MARK: - 顶部栏

    private var topBar: some View {
        HStack {
            Text(calculatorVM.mode.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            Picker("模式", selection: $calculatorVM.mode) {
                ForEach(CalculatorMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 160)

            Spacer()

            Button(action: { showHistory.toggle() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18))
                    .foregroundStyle(.orange)
            }
            .accessibilityLabel("历史记录")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}