//
//  NumberFormatter+Ext.swift
//  CalculatorCore
//
//  数字格式化扩展：本地化、最大有效位数、科学计数法自动切换。
//

import Foundation

extension NumberFormatter {

    /// 计算器专用格式化器：
    /// - 默认 12 位有效小数
    /// - 极大/极小自动转科学计数
    /// - 支持负数、千分位
    public static func calculator(locale: Locale = .current) -> NumberFormatter {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 12
        f.usesSignificantDigits = false
        return f
    }

    /// 科学计数法格式化器（结果过大或过小时使用）
    public static func calculatorScientific(locale: Locale = .current) -> NumberFormatter {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .scientific
        f.usesGroupingSeparator = false
        f.maximumFractionDigits = 6
        return f
    }
}

public enum CalculatorNumberFormatter {

    /// 阈值：超过此数量级切换科学计数法
    private static let scientificLowerBound: Double = 1e-12
    private static let scientificUpperBound: Double = 1e16

    /// 将 Decimal 格式化为显示字符串
    /// - Parameters:
    ///   - value: 待格式化数值
    ///   - locale: 区域
    /// - Returns: 显示字符串
    public static func format(_ value: Decimal, locale: Locale = .current) -> String {
        let double = (value as NSDecimalNumber).doubleValue

        // NaN / Infinity
        if double.isNaN {
            return "错误"
        }
        if double.isInfinite {
            return double > 0 ? "∞" : "−∞"
        }

        // 极小或极大使用科学计数
        if abs(double) < scientificLowerBound && double != 0 {
            return NumberFormatter.calculatorScientific(locale: locale).string(from: value as NSDecimalNumber) ?? "\(double)"
        }
        if abs(double) >= scientificUpperBound {
            return NumberFormatter.calculatorScientific(locale: locale).string(from: value as NSDecimalNumber) ?? "\(double)"
        }

        // 普通十进制
        let formatter = NumberFormatter.calculator(locale: locale)

        // 整数化显示（无小数部分时去除小数点）
        if value.isInteger {
            formatter.maximumFractionDigits = 0
        }

        return formatter.string(from: value as NSDecimalNumber) ?? "\(double)"
    }
}

private extension Decimal {
    /// 是否为整数
    var isInteger: Bool {
        var rounded = Decimal()
        var copy = self
        NSDecimalRound(&rounded, &copy, 0, .plain)
        return rounded == self
    }
}