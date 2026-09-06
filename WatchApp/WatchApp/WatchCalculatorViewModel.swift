import Foundation
import SwiftUI
import CalculatorCore
import WatchKit

/// Apple Watch 计算器状态机
///
/// 与 iOS 端 `CalculatorViewModel` 的区别：
/// - 仅支持基础模式（无 sin/cos/tan 等科学函数）
/// - 输入通过 `WKInterfaceDevice` 触觉反馈
/// - 运算结果通过 App Group 同步到 iPhone 与 Widget
@Observable
final class WatchCalculatorViewModel {

    // MARK: - 公开状态

    private(set) var displayValue: String = "0"
    private(set) var expression: String = ""
    private(set) var errorMessage: String?

    // MARK: - 内部数据

    /// 草稿表达式：用字符串拼接，与 iOS 端保持一致
    private var draftExpression: String = ""

    private enum Op: Character {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
    }

    // MARK: - 引擎

    private let engine = CalculatorEngine(mode: .basic, angleUnit: .degree)

    // MARK: - 主入口

    func handle(_ action: WatchKeyAction) {
        errorMessage = nil

        switch action {
        case .digit(let d):
            appendDigit(d)
        case .decimal:
            appendDecimal()
        case .op(let op):
            applyOperator(op)
        case .equals:
            compute()
        case .clear:
            clearAll()
        case .delete:
            backspace()
        case .toggleSign:
            toggleSign()
        case .percent:
            appendPercent()
        }
        recompute()
    }

    // MARK: - 输入处理

    private func appendDigit(_ d: Int) {
        guard (0...9).contains(d) else { return }
        draftExpression.append(String(d))
        expression = draftExpression
    }

    private func appendDecimal() {
        let segments = draftExpression.split(whereSeparator: { "+-×÷".contains($0) })
        if let last = segments.last, last.contains(".") {
            return
        }
        draftExpression.append(".")
        expression = draftExpression
    }

    private func applyOperator(_ op: WatchKeyAction.Op) {
        if let last = draftExpression.last, "+-×÷".contains(last) {
            draftExpression.removeLast()
        }
        draftExpression.append(String(op.rawValue))
        expression = draftExpression
    }

    private func compute() {
        guard !draftExpression.isEmpty else { return }
        do {
            let result = try engine.evaluate(draftExpression)
            displayValue = NumberFormatter.formatDecimal(result)
            expression = draftExpression + " ="
            AppGroupBridge.shared.writeLatestResult(
                expression: draftExpression,
                result: result
            )
            draftExpression = result == 0 ? "0" : NumberFormatter.formatDecimal(result)
            WKInterfaceDevice.current().play(.success)
        } catch let err as CalculatorError {
            errorMessage = err.localizedDescription
            displayValue = "错误"
            WKInterfaceDevice.current().play(.failure)
        } catch {
            errorMessage = error.localizedDescription
            displayValue = "错误"
            WKInterfaceDevice.current().play(.failure)
        }
    }

    private func clearAll() {
        draftExpression.removeAll()
        expression = ""
        displayValue = "0"
        errorMessage = nil
        WKInterfaceDevice.current().play(.click)
    }

    private func backspace() {
        if !draftExpression.isEmpty {
            draftExpression.removeLast()
        }
        expression = draftExpression
        WKInterfaceDevice.current().play(.click)
    }

    private func toggleSign() {
        let pattern = "(-?\\d+\\.?\\d*)$"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(
               in: draftExpression,
               range: NSRange(draftExpression.startIndex..., in: draftExpression)
           ),
           let range = Range(match.range, in: draftExpression) {
            let current = String(draftExpression[range])
            let newValue: String
            if current.hasPrefix("-") {
                newValue = String(current.dropFirst())
            } else {
                newValue = "-" + current
            }
            draftExpression.replaceSubrange(range, with: newValue)
            expression = draftExpression
        } else if !draftExpression.isEmpty {
            draftExpression = "-(" + draftExpression + ")"
            expression = draftExpression
        }
        WKInterfaceDevice.current().play(.click)
    }

    private func appendPercent() {
        let pattern = "(\\d+\\.?\\d*)$"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(
               in: draftExpression,
               range: NSRange(draftExpression.startIndex..., in: draftExpression)
           ),
           let range = Range(match.range, in: draftExpression) {
            let current = String(draftExpression[range])
            if let value = Decimal(string: current) {
                let percent = value / 100
                let newValue = NumberFormatter.formatDecimal(percent)
                draftExpression.replaceSubrange(range, with: newValue)
                expression = draftExpression
            }
        }
        WKInterfaceDevice.current().play(.click)
    }

    /// 实时计算中间结果
    private func recompute() {
        guard !draftExpression.isEmpty else {
            displayValue = "0"
            return
        }
        do {
            let result = try engine.evaluate(draftExpression)
            displayValue = NumberFormatter.formatDecimal(result)
        } catch {
            displayValue = ""
        }
    }
}

/// Watch 端按键事件
enum WatchKeyAction {
    case digit(Int)
    case decimal
    case op(Op)
    case equals
    case clear
    case delete
    case toggleSign
    case percent

    enum Op: String {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
    }
}
