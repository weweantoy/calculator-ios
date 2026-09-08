//
//  BasicCalculatorView.swift
//  App
//
//  基础模式键盘：5 行 × 4 列，0 键双宽。
//

import SwiftUI
import CalculatorCore

struct BasicCalculatorView: View {

    @ObservedObject var viewModel: CalculatorViewModel

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 4
    )

    private let rowSpacing: CGFloat = 12

    var body: some View {
        VStack(spacing: rowSpacing) {
            // 行 1: AC ⌫ % ÷（± 移除：与 = 重复场景少，删除键更常用）
            HStack(spacing: 12) {
                CalculatorButton(key: .clear, action: viewModel.handleKey)
                CalculatorButton(key: .delete, action: viewModel.handleKey)
                CalculatorButton(key: .percent, action: viewModel.handleKey)
                CalculatorButton(key: .divide, action: viewModel.handleKey)
            }

            // 行 2: 7 8 9 ×
            HStack(spacing: 12) {
                CalculatorButton(key: .digit(7), action: viewModel.handleKey)
                CalculatorButton(key: .digit(8), action: viewModel.handleKey)
                CalculatorButton(key: .digit(9), action: viewModel.handleKey)
                CalculatorButton(key: .multiply, action: viewModel.handleKey)
            }

            // 行 3: 4 5 6 −
            HStack(spacing: 12) {
                CalculatorButton(key: .digit(4), action: viewModel.handleKey)
                CalculatorButton(key: .digit(5), action: viewModel.handleKey)
                CalculatorButton(key: .digit(6), action: viewModel.handleKey)
                CalculatorButton(key: .minus, action: viewModel.handleKey)
            }

            // 行 4: 1 2 3 +
            HStack(spacing: 12) {
                CalculatorButton(key: .digit(1), action: viewModel.handleKey)
                CalculatorButton(key: .digit(2), action: viewModel.handleKey)
                CalculatorButton(key: .digit(3), action: viewModel.handleKey)
                CalculatorButton(key: .plus, action: viewModel.handleKey)
            }

            // 行 5: 0(双宽) . =
            HStack(spacing: 12) {
                CalculatorButton(key: .digit(0), action: viewModel.handleKey)
                    .layoutPriority(2)
                CalculatorButton(key: .decimal, action: viewModel.handleKey)
                CalculatorButton(key: .equals, action: {
                    HapticsManager.shared.commit()
                    viewModel.handleKey($0)
                })
            }
        }
        .padding(.horizontal, 12)
    }
}