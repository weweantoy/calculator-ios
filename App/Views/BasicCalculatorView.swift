//
//  BasicCalculatorView.swift
//  App
//
//  基础模式键盘（恢复 v1.3 原始布局）：
//  行1: AC ± % ÷   行2: 7 8 9 ×   行3: 4 5 6 −
//  行4: 1 2 3 +    行5: 0 . =
//

import SwiftUI
import CalculatorCore

struct BasicCalculatorView: View {

    @ObservedObject var viewModel: CalculatorViewModel

    private let spacing: CGFloat = 12

    var body: some View {
        VStack(spacing: spacing) {
            // 行 1: AC ⌫ % ÷
            HStack(spacing: spacing) {
                CalculatorButton(key: .clear, action: viewModel.handleKey)
                CalculatorButton(key: .delete, action: viewModel.handleKey)
                CalculatorButton(key: .percent, action: viewModel.handleKey)
                CalculatorButton(key: .divide, action: viewModel.handleKey)
            }

            // 行 2: 7 8 9 ×
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(7), action: viewModel.handleKey)
                CalculatorButton(key: .digit(8), action: viewModel.handleKey)
                CalculatorButton(key: .digit(9), action: viewModel.handleKey)
                CalculatorButton(key: .multiply, action: viewModel.handleKey)
            }

            // 行 3: 4 5 6 −
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(4), action: viewModel.handleKey)
                CalculatorButton(key: .digit(5), action: viewModel.handleKey)
                CalculatorButton(key: .digit(6), action: viewModel.handleKey)
                CalculatorButton(key: .minus, action: viewModel.handleKey)
            }

            // 行 4: 1 2 3 +
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(1), action: viewModel.handleKey)
                CalculatorButton(key: .digit(2), action: viewModel.handleKey)
                CalculatorButton(key: .digit(3), action: viewModel.handleKey)
                CalculatorButton(key: .plus, action: viewModel.handleKey)
            }

            // 行 5: 0 . =
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(0), action: viewModel.handleKey)
                CalculatorButton(key: .decimal, action: viewModel.handleKey)
                CalculatorButton(key: .equals, action: viewModel.handleKey)
            }
        }
        .padding(.horizontal, 12)
    }
}
