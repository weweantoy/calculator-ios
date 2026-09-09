//
//  BasicCalculatorView.swift
//  App
//
//  基础模式键盘（照搬"计算器HD"布局）：
//  行1: AC ( ) ⌫   行2: ± % ÷ ×   行3: 7 8 9 +   行4: 4 5 6 −
//  行5: 1 2 3 | = 大键纵跨行5-6
//  行6: ⌨ 0 . | =
//  左下角键盘图标 = 切换到科学模式。
//

import SwiftUI
import CalculatorCore

struct BasicCalculatorView: View {

    @ObservedObject var viewModel: CalculatorViewModel

    private let spacing: CGFloat = 12

    var body: some View {
        VStack(spacing: spacing) {
            // 行 1: AC ( ) ⌫
            HStack(spacing: spacing) {
                CalculatorButton(key: .clear, action: viewModel.handleKey)
                CalculatorButton(key: .leftParen, action: viewModel.handleKey)
                CalculatorButton(key: .rightParen, action: viewModel.handleKey)
                CalculatorButton(key: .delete, action: viewModel.handleKey)
            }

            // 行 2: ± % ÷ ×
            HStack(spacing: spacing) {
                CalculatorButton(key: .toggleSign, action: viewModel.handleKey)
                CalculatorButton(key: .percent, action: viewModel.handleKey)
                CalculatorButton(key: .divide, action: viewModel.handleKey)
                CalculatorButton(key: .multiply, action: viewModel.handleKey)
            }

            // 行 3: 7 8 9 +
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(7), action: viewModel.handleKey)
                CalculatorButton(key: .digit(8), action: viewModel.handleKey)
                CalculatorButton(key: .digit(9), action: viewModel.handleKey)
                CalculatorButton(key: .plus, action: viewModel.handleKey)
            }

            // 行 4: 4 5 6 −
            HStack(spacing: spacing) {
                CalculatorButton(key: .digit(4), action: viewModel.handleKey)
                CalculatorButton(key: .digit(5), action: viewModel.handleKey)
                CalculatorButton(key: .digit(6), action: viewModel.handleKey)
                CalculatorButton(key: .minus, action: viewModel.handleKey)
            }

            // 行 5-6: 左侧 1 2 3 / ⌨ 0 . 两行，右侧 = 纵跨两行
            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        CalculatorButton(key: .digit(1), action: viewModel.handleKey)
                        CalculatorButton(key: .digit(2), action: viewModel.handleKey)
                        CalculatorButton(key: .digit(3), action: viewModel.handleKey)
                    }
                    HStack(spacing: spacing) {
                        ModeSwitchButton(viewModel: viewModel)
                        CalculatorButton(key: .digit(0), action: viewModel.handleKey)
                            .layoutPriority(2)
                        CalculatorButton(key: .decimal, action: viewModel.handleKey)
                    }
                }
                EqualsButton(action: {
                    HapticsManager.shared.commit()
                    viewModel.handleKey(.equals)
                })
            }
        }
        .padding(.horizontal, 12)
    }
}

/// 左下角键盘图标：切换到科学模式（对应"计算器HD"的键盘切换键）
struct ModeSwitchButton: View {

    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        Button(action: {
            HapticsManager.shared.commit()
            viewModel.switchMode(.scientific)
        }) {
            Image(systemName: "keyboard")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray3))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("key_mode_switch")
        .accessibilityLabel("切换到科学模式")
    }
}

/// = 大键：宽度与单键一致，高度纵跨两行
struct EqualsButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(CalculatorKey.equals.label)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("key_equals")
        .accessibilityLabel("等于")
    }
}
