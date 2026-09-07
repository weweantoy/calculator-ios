//
//  ScientificCalculatorView.swift
//  App
//
//  科学模式键盘：8 行 × 4 列 = 32 键，0 键单宽。
//
//  行 1: AC  ⌫   ±   %
//  行 2: (   )   π   e
//  行 3: sin cos tan ln
//  行 4: log √   x²  xʸ
//  行 5: 7   8   9   ÷
//  行 6: 4   5   6   ×
//  行 7: 1   2   3   −
//  行 8: 0   .   =   +
//
//  角度单位切换器独立放置在顶部栏。
//

import SwiftUI
import CalculatorCore

struct ScientificCalculatorView: View {

    @ObservedObject var viewModel: CalculatorViewModel

    private let spacing: CGFloat = 8

    var body: some View {
        VStack(spacing: spacing) {
            // 行 1: AC ⌫ ± %
            HStack(spacing: spacing) {
                CalculatorButton(key: .clear, action: viewModel.handleKey)
                CalculatorButton(key: .delete, action: viewModel.handleKey)
                CalculatorButton(key: .toggleSign, action: viewModel.handleKey)
                CalculatorButton(key: .percent, action: viewModel.handleKey)
            }

            // 行 2: ( ) π e
            HStack(spacing: spacing) {
                CalculatorButton(key: .leftParen, action: viewModel.handleKey)
                CalculatorButton(key: .rightParen, action: viewModel.handleKey)
                CalculatorButton(key: .pi, action: viewModel.handleKey)
                CalculatorButton(key: .e, action: viewModel.handleKey)
            }

            // 行 3: sin cos tan ln
            HStack(spacing: spacing) {
                CalculatorButton(key: .sin, action: viewModel.handleKey)
                CalculatorButton(key: .cos, action: viewModel.handleKey)
                CalculatorButton(key: .tan, action: viewModel.handleKey)
                CalculatorButton(key: .ln, action: viewModel.handleKey)
            }

            // 行 4: log √ x² xʸ
            HStack(spacing: spacing) {
                CalculatorButton(key: .log, action: viewModel.handleKey)
                CalculatorButton(key: .sqrt, action: viewModel.handleKey)
                CalculatorButton(key: .square, action: viewModel.handleKey)
                CalculatorButton(key: .power, action: viewModel.handleKey)
            }

            // 行 5: 7 8 9 ÷
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(7), action: viewModel.handleKey)
                CalculatorButton(key: .digit(8), action: viewModel.handleKey)
                CalculatorButton(key: .digit(9), action: viewModel.handleKey)
                CalculatorButton(key: .divide, action: viewModel.handleKey)
            }

            // 行 6: 4 5 6 ×
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(4), action: viewModel.handleKey)
                CalculatorButton(key: .digit(5), action: viewModel.handleKey)
                CalculatorButton(key: .digit(6), action: viewModel.handleKey)
                CalculatorButton(key: .multiply, action: viewModel.handleKey)
            }

            // 行 7: 1 2 3 −
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(1), action: viewModel.handleKey)
                CalculatorButton(key: .digit(2), action: viewModel.handleKey)
                CalculatorButton(key: .digit(3), action: viewModel.handleKey)
                CalculatorButton(key: .minus, action: viewModel.handleKey)
            }

            // 行 8: 0 . = +
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(0), action: viewModel.handleKey)
                CalculatorButton(key: .decimal, action: viewModel.handleKey)
                CalculatorButton(key: .equals, action: {
                    HapticsManager.shared.commit()
                    viewModel.handleKey($0)
                })
                CalculatorButton(key: .plus, action: viewModel.handleKey)
            }
        }
        .padding(.horizontal, 8)
    }
}
