//
//  ScientificCalculatorView.swift
//  App
//
//  科学模式键盘：在基础模式上增加科学函数行。
//  布局：
//    行 1: (  )  π  e
//    行 2: sin cos tan log
//    行 3: ln  √  x² AC
//    行 4: 7  8  9  ÷
//    行 5: 4  5  6  ×
//    行 6: 1  2  3  −
//    行 7: 0(双) .  =
//    行 8: %
//
//  角度单位切换器独立放置在顶部栏。
//

import SwiftUI
import CalculatorCore

struct ScientificCalculatorView: View {

    @ObservedObject var viewModel: CalculatorViewModel

    private let rowSpacing: CGFloat = 8

    var body: some View {
        VStack(spacing: rowSpacing) {
            // 行 1: ( ) π e
            HStack(spacing: 8) {
                CalculatorButton(key: .leftParen, action: viewModel.handleKey)
                CalculatorButton(key: .rightParen, action: viewModel.handleKey)
                CalculatorButton(key: .pi, action: viewModel.handleKey)
                CalculatorButton(key: .e, action: viewModel.handleKey)
            }

            // 行 2: sin cos tan log
            HStack(spacing: 8) {
                CalculatorButton(key: .sin, action: viewModel.handleKey)
                CalculatorButton(key: .cos, action: viewModel.handleKey)
                CalculatorButton(key: .tan, action: viewModel.handleKey)
                CalculatorButton(key: .log, action: viewModel.handleKey)
            }

            // 行 3: ln √ x² AC
            HStack(spacing: 8) {
                CalculatorButton(key: .ln, action: viewModel.handleKey)
                CalculatorButton(key: .sqrt, action: viewModel.handleKey)
                CalculatorButton(key: .square, action: viewModel.handleKey)
                CalculatorButton(key: .clear, action: viewModel.handleKey)
            }

            // 行 4: 7 8 9 ÷
            HStack(spacing: 8) {
                CalculatorButton(key: .digit(7), action: viewModel.handleKey)
                CalculatorButton(key: .digit(8), action: viewModel.handleKey)
                CalculatorButton(key: .digit(9), action: viewModel.handleKey)
                CalculatorButton(key: .divide, action: viewModel.handleKey)
            }

            // 行 5: 4 5 6 ×
            HStack(spacing: 8) {
                CalculatorButton(key: .digit(4), action: viewModel.handleKey)
                CalculatorButton(key: .digit(5), action: viewModel.handleKey)
                CalculatorButton(key: .digit(6), action: viewModel.handleKey)
                CalculatorButton(key: .multiply, action: viewModel.handleKey)
            }

            // 行 6: 1 2 3 −
            HStack(spacing: 8) {
                CalculatorButton(key: .digit(1), action: viewModel.handleKey)
                CalculatorButton(key: .digit(2), action: viewModel.handleKey)
                CalculatorButton(key: .digit(3), action: viewModel.handleKey)
                CalculatorButton(key: .minus, action: viewModel.handleKey)
            }

            // 行 7: 0(双) . =
            HStack(spacing: 8) {
                CalculatorButton(key: .digit(0), action: viewModel.handleKey)
                    .layoutPriority(2)
                CalculatorButton(key: .decimal, action: viewModel.handleKey)
                CalculatorButton(key: .equals, action: {
                    HapticsManager.shared.commit()
                    viewModel.handleKey($0)
                })
            }

            // 行 8: ± %
            HStack(spacing: 8) {
                CalculatorButton(key: .toggleSign, action: viewModel.handleKey)
                CalculatorButton(key: .percent, action: viewModel.handleKey)
                CalculatorButton(key: .delete, action: viewModel.handleKey)
                    .layoutPriority(2)
                CalculatorButton(key: .plus, action: viewModel.handleKey)
            }
        }
        .padding(.horizontal, 8)
    }
}