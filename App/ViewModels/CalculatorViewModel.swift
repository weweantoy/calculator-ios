//
//  CalculatorViewModel.swift
//  App
//
//  计算器主 ViewModel：
//  - 管理当前输入、表达式、结果、错误状态
//  - 处理按键事件
//  - 实时计算（用户输入过程中）
//  - 持久化历史记录（提交时）
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import WidgetKit
import CalculatorCore

@MainActor
final class CalculatorViewModel: ObservableObject {

    // MARK: - 状态

    @Published private(set) var mode: CalculatorMode = .basic
    @Published private(set) var expressionString: String = ""    // 用户输入的原始表达式
    @Published private(set) var displayString: String = "0"     // 显示区主显示（结果或当前数字）
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var angleUnit: AngleUnit = .degree

    /// 用于实时计算：当前正在编辑的表达式
    private var draftExpression: String = ""

    /// 最近一次「成功求值」的显示串；输入未完成时用它兜底，避免显示区闪 0
    private var lastValidDisplay: String?

    /// 引擎实例（可在角度单位切换时重建）
    private var engine: CalculatorEngine

    /// SwiftData 上下文（延迟注入）
    private var modelContext: ModelContext?

    // MARK: - 初始化

    init(angleUnit: AngleUnit = .degree) {
        self.angleUnit = angleUnit
        self.engine = CalculatorEngine(angleUnit: angleUnit)
        self.displayString = "0"
    }

    func attachHistoryContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - 模式与单位切换

    func switchMode(_ mode: CalculatorMode) {
        self.mode = mode
        // 切换模式时清空（避免科学/基础函数残留）
        clear()
    }

    func switchAngleUnit(_ unit: AngleUnit) {
        self.angleUnit = unit
        self.engine = CalculatorEngine(angleUnit: unit)
        recompute()
    }

    // MARK: - 按键入口

    /// 处理用户按键
    func handleKey(_ key: CalculatorKey) {
        switch key {
        case .digit(let d):
            appendDigit(d)
        case .decimal:
            appendDecimal()
        case .plus, .minus, .multiply, .divide:
            appendOperator(opSymbol(key))
        case .equals:
            commit()
        case .clear:
            clear()
        case .delete:
            backspace()
        case .percent:
            appendPercent()
        case .toggleSign:
            toggleSign()
        case .leftParen:
            appendText("(")
        case .rightParen:
            appendText(")")
        case .sin:
            appendFunction("sin")
        case .cos:
            appendFunction("cos")
        case .tan:
            appendFunction("tan")
        case .log:
            appendFunction("log")
        case .ln:
            appendFunction("ln")
        case .sqrt:
            appendFunction("sqrt")
        case .square:
            appendSquare()
        case .power:
            appendOperator("^")
        case .pi:
            appendConstant("π")
        case .e:
            appendConstant("e")
        case .modeSwitch, .angleUnitSwitch:
            break  // 由视图层处理
        }
    }

    // MARK: - 输入构造

    private func appendDigit(_ d: Int) {
        errorMessage = nil
        draftExpression.append("\(d)")
        expressionString = draftExpression
        recompute()
    }

    private func appendDecimal() {
        errorMessage = nil
        // 检查当前数字段是否已包含小数点，避免 "1.2.3"
        let pattern = #"\d+\.?\d*$"#
        if let range = draftExpression.range(of: pattern, options: .regularExpression) {
            let numStr = String(draftExpression[range])
            if numStr.contains(".") {
                return  // 已含小数点，忽略
            }
            draftExpression.append(".")
        } else {
            // 空表达式或以运算符 / 左括号结尾 → 自动补 "0."，避免 "sqrt(." 这类无法解析的输入
            draftExpression.append("0.")
        }
        expressionString = draftExpression
        recompute()
    }

    private func appendOperator(_ symbol: String) {
        errorMessage = nil
        let arithmeticOps = Set<Character>(["+", "-", "−", "×", "*", "·", "÷", "/"])

        if let last = draftExpression.last {
            if symbol == "^" {
                // 幂运算只对连续的 ^ 做替换，保留 "^(-3)" 这类负指数输入
                if last == "^" { draftExpression.removeLast() }
            } else if arithmeticOps.contains(last) {
                draftExpression.removeLast()
            }
        }
        draftExpression.append(symbol)
        expressionString = draftExpression
        recompute()
    }

    private func appendText(_ text: String) {
        errorMessage = nil
        draftExpression.append(text)
        expressionString = draftExpression
        recompute()
    }

    private func appendPercent() {
        errorMessage = nil
        guard !draftExpression.isEmpty else { return }
        guard let last = draftExpression.last else { return }

        let arithmeticOps = Set<Character>(["+", "-", "−", "×", "*", "·", "÷", "/", "^", "%"])
        // 末位是运算符、幂号或已有百分号时忽略，避免产生无法解析的表达式
        if arithmeticOps.contains(last) { return }

        // 统一追加 "%"，由引擎按 iOS 系统语义处理：
        //   A + B% → A + A×B/100 ；A − B% → A − A×B/100
        //   A × B% → A × B/100   ；A ÷ B% → A ÷ (B/100)
        //   单独 B% → B/100
        draftExpression.append("%")
        expressionString = draftExpression
        recompute()
    }

    private func toggleSign() {
        errorMessage = nil
        // 找到末尾的数字段（含可选前导负号），对其取反。
        // 符合 iOS 系统计算器的"对最后输入数字取反"行为。
        let pattern = #"(-?\d+\.?\d*)$"#
        if let range = draftExpression.range(of: pattern, options: .regularExpression) {
            let numStr = String(draftExpression[range])
            let toggled: String
            if numStr.hasPrefix("-") {
                toggled = String(numStr.dropFirst())
            } else {
                toggled = "-" + numStr
            }
            draftExpression.replaceSubrange(range, with: toggled)
        } else {
            // 无末尾数字段：在末尾追加 *(-1)
            draftExpression.append("*(-1)")
        }
        expressionString = draftExpression
        recompute()
    }

    private func appendFunction(_ name: String) {
        errorMessage = nil
        // 函数插入为 "name("，等待用户输入参数
        draftExpression.append("\(name)(")
        expressionString = draftExpression
        recompute()
    }

    private func appendConstant(_ symbol: String) {
        errorMessage = nil
        draftExpression.append(symbol)
        expressionString = draftExpression
        recompute()
    }

    private func appendSquare() {
        errorMessage = nil
        guard !draftExpression.isEmpty else { return }
        guard let last = draftExpression.last else { return }
        let operators = Set<Character>(["+", "-", "−", "×", "*", "·", "÷", "/", "^"])
        if operators.contains(last) { return }

        // 追加 "^2" 而不是把整个表达式折叠成结果，
        // 与 iOS 系统计算器一致：输入 2+3 后按 x² 得到 2+3² = 11
        draftExpression.append("^2")
        expressionString = draftExpression
        recompute()
    }

    // MARK: - 编辑

    func backspace() {
        errorMessage = nil
        if !draftExpression.isEmpty {
            draftExpression.removeLast()
        }
        expressionString = draftExpression
        recompute()
    }

    func clear() {
        draftExpression = ""
        expressionString = ""
        displayString = "0"
        lastValidDisplay = nil
        errorMessage = nil
    }

    // MARK: - 提交与持久化

    /// 用户按下 = 时的提交动作
    func commit() {
        guard !draftExpression.isEmpty else { return }
        do {
            let result = try engine.evaluate(draftExpression)
            displayString = CalculatorNumberFormatter.format(result)

            // 持久化历史：本地 SwiftData
            if let ctx = modelContext {
                let record = HistoryRecord(
                    expression: draftExpression,
                    result: displayString
                )
                ctx.insert(record)
                try? ctx.save()
            }

            // 同步到 App Group（Apple Watch / Widget 可读）
            AppGroupBridge.shared.writeLatestResult(
                expression: draftExpression,
                result: result
            )
            AppGroupBridge.shared.appendHistory(
                expression: draftExpression,
                result: result
            )
            // 触发 Widget 刷新
            WidgetCenter.shared.reloadAllTimelines()

            // 将结果设为下一次输入起点。
            // 必须使用「可回读」的纯数字串（无千分位、无科学计数法），
            // 否则表达式如 "1.23E+16" 会被 tokenizer 判为无效字符。
            let plain = CalculatorNumberFormatter.plainString(result)
            draftExpression = plain
            expressionString = plain
            lastValidDisplay = displayString
        } catch let error as CalculatorError {
            errorMessage = error.localizedDescription
            displayString = "错误"
        } catch {
            errorMessage = "未知错误"
            displayString = "错误"
        }
    }

    /// 实时计算（用户输入过程中）
    private func recompute() {
        guard !draftExpression.isEmpty else {
            displayString = "0"
            errorMessage = nil
            return
        }
        do {
            let result = try engine.evaluate(draftExpression)
            displayString = CalculatorNumberFormatter.format(result)
            lastValidDisplay = displayString
            errorMessage = nil
        } catch {
            // 输入尚未完成（如 "5−"、"sqrt(" ）时不清零，
            // 保留上一次可用结果，避免显示区闪烁成 "0"
            if let last = lastValidDisplay {
                displayString = last
            }
        }
    }

    // MARK: - 历史复用

    func applyHistory(_ record: HistoryRecord) {
        draftExpression = record.expression
        expressionString = record.expression
        displayString = record.result
        lastValidDisplay = record.result
        errorMessage = nil
    }

    // MARK: - Helpers

    private func opSymbol(_ key: CalculatorKey) -> String {
        switch key {
        case .plus:     return "+"
        case .minus:    return "−"  // 显示用 Unicode 减号
        case .multiply: return "×"
        case .divide:   return "÷"
        default:        return ""
        }
    }
}