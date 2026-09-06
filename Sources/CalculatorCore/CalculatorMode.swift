//
//  CalculatorMode.swift
//  CalculatorCore
//
//  计算器模式与按键定义。
//

import Foundation

/// 计算器工作模式
public enum CalculatorMode: String, CaseIterable, Sendable {
    case basic       // 基础四则
    case scientific  // 科学（三角函数、对数、幂根等）

    public var displayName: String {
        switch self {
        case .basic:       return "基础"
        case .scientific:  return "科学"
        }
    }
}

/// 角度单位（仅科学模式有效）
public enum AngleUnit: String, CaseIterable, Sendable {
    case degree
    case radian

    public var displayName: String {
        switch self {
        case .degree: return "DEG"
        case .radian: return "RAD"
        }
    }

    public var symbol: String {
        switch self {
        case .degree: return "°"
        case .radian: return "rad"
        }
    }
}

/// 按键定义：覆盖基础与科学模式所有可输入按键。
public enum CalculatorKey: Hashable, Sendable {
    // 数字与小数点
    case digit(Int)        // 0-9
    case decimal

    // 基本运算符
    case plus
    case minus
    case multiply
    case divide

    // 修饰键
    case equals
    case clear             // AC：全部清除
    case delete            // DEL：删除最后一位
    case percent
    case toggleSign        // ±

    // 括号（科学模式）
    case leftParen
    case rightParen

    // 科学函数
    case sin
    case cos
    case tan
    case log              // log10
    case ln               // 自然对数
    case sqrt
    case square           // x²

    // 常量
    case pi
    case e

    // 模式与单位切换（视图层使用）
    case modeSwitch
    case angleUnitSwitch

    /// 按键显示文字
    public var label: String {
        switch self {
        case .digit(let d):              return "\(d)"
        case .decimal:                   return "."
        case .plus:                      return "+"
        case .minus:                     return "−"
        case .multiply:                  return "×"
        case .divide:                    return "÷"
        case .equals:                    return "="
        case .clear:                     return "AC"
        case .delete:                    return "⌫"
        case .percent:                   return "%"
        case .toggleSign:                return "±"
        case .leftParen:                 return "("
        case .rightParen:                return ")"
        case .sin:                       return "sin"
        case .cos:                       return "cos"
        case .tan:                       return "tan"
        case .log:                       return "log"
        case .ln:                        return "ln"
        case .sqrt:                      return "√"
        case .square:                    return "x²"
        case .pi:                        return "π"
        case .e:                         return "e"
        case .modeSwitch:                return "mode"
        case .angleUnitSwitch:           return "DEG/RAD"
        }
    }

    /// 按键分类（用于 UI 着色）
    public enum Category: Sendable {
        case digit       // 数字键（深色）
        case operation   // 运算符（橙色）
        case function    // 函数键（浅色）
        case modifier    // 修饰键（清空、删除等）
    }

    public var category: Category {
        switch self {
        case .digit, .decimal:
            return .digit
        case .plus, .minus, .multiply, .divide, .equals:
            return .operation
        case .sin, .cos, .tan, .log, .ln, .sqrt, .square, .pi, .e, .leftParen, .rightParen:
            return .function
        case .clear, .delete, .percent, .toggleSign, .modeSwitch, .angleUnitSwitch:
            return .modifier
        }
    }

    /// 是否占用双倍宽度（仅 0 键）
    public var isDoubleWidth: Bool {
        if case .digit(0) = self { return true }
        return false
    }
}