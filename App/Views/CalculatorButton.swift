//
//  CalculatorButton.swift
//  App
//
//  计算器按钮组件：圆角矩形，支持双宽，触觉反馈。
//

import SwiftUI
import CalculatorCore

struct CalculatorButton: View {

    let key: CalculatorKey
    let action: (CalculatorKey) -> Void

    var body: some View {
        Button(action: {
            HapticsManager.shared.keyTap()
            action(key)
        }) {
            Text(key.label)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        // UI 测试辅助：稳定的 identifier 与人类可读标签
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(accessibilityLabel)
    }

    /// 稳定的测试 ID，XCUITest 通过此字段查找按钮
    private var accessibilityIdentifier: String {
        switch key {
        case .digit(let d):                return "key_digit_\(d)"
        case .decimal:                     return "key_decimal"
        case .plus:                        return "key_plus"
        case .minus:                       return "key_minus"
        case .multiply:                    return "key_multiply"
        case .divide:                      return "key_divide"
        case .equals:                      return "key_equals"
        case .clear:                       return "key_ac"
        case .delete:                      return "key_delete"
        case .percent:                     return "key_percent"
        case .toggleSign:                  return "key_sign"
        case .leftParen:                   return "key_left_paren"
        case .rightParen:                  return "key_right_paren"
        case .sin:                         return "key_sin"
        case .cos:                         return "key_cos"
        case .tan:                         return "key_tan"
        case .log:                         return "key_log"
        case .ln:                          return "key_ln"
        case .sqrt:                        return "key_sqrt"
        case .square:                      return "key_square"
        case .pi:                          return "key_pi"
        case .e:                           return "key_e"
        case .modeSwitch:                  return "key_mode_switch"
        case .angleUnitSwitch:             return "key_angle_unit"
        }
    }

    /// 无障碍标签（VoiceOver 朗读）
    private var accessibilityLabel: String {
        switch key {
        case .digit(let d):  return "数字 \(d)"
        case .decimal:       return "小数点"
        case .plus:          return "加"
        case .minus:         return "减"
        case .multiply:      return "乘"
        case .divide:        return "除"
        case .equals:        return "等于"
        case .clear:         return "全部清除"
        case .delete:        return "删除"
        case .percent:       return "百分号"
        case .toggleSign:    return "正负号切换"
        case .leftParen:     return "左括号"
        case .rightParen:    return "右括号"
        case .sin:           return "正弦"
        case .cos:           return "余弦"
        case .tan:           return "正切"
        case .log:           return "常用对数"
        case .ln:            return "自然对数"
        case .sqrt:          return "平方根"
        case .square:        return "平方"
        case .pi:            return "圆周率"
        case .e:             return "自然常数"
        case .modeSwitch:    return "模式切换"
        case .angleUnitSwitch: return "角度单位"
        }
    }

    // MARK: - 样式

    private var fontSize: CGFloat {
        switch key {
        case .digit:        return 28
        case .decimal:      return 32
        case .plus, .minus, .multiply, .divide: return 32
        case .equals:       return 34
        case .sin, .cos, .tan, .log, .ln, .sqrt, .square:
            return 18
        case .pi, .e:       return 26
        case .leftParen, .rightParen:
            return 28
        default:            return 22
        }
    }

    private var fontWeight: Font.Weight {
        switch key {
        case .clear, .equals: return .semibold
        default: return .regular
        }
    }

    private var foregroundColor: Color {
        switch key.category {
        case .operation: return .white
        case .function:  return .black
        case .digit:     return .white
        case .modifier:  return .black
        }
    }

    private var backgroundColor: Color {
        switch key.category {
        case .operation: return .orange
        case .function:  return Color(white: 0.65)         // #A5A5A5
        case .digit:     return Color(white: 0.2)          // #333336
        case .modifier:  return Color(white: 0.65)         // #A5A5A5
        }
    }
}