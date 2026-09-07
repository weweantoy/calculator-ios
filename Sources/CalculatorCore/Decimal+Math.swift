//
//  Decimal+Math.swift
//  CalculatorCore
//
//  Decimal 不包含三角函数与对数函数，此扩展通过 Double 桥接实现。
//  对于常见精度需求（科学计算器级）足够安全；
//  对于极端精度需求，应使用专门的 Decimal 数学库。
//

import Foundation

extension Decimal {

    // MARK: - 三角函数（弧度）

    /// 正弦函数（弧度）
    public var sine: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(sin(v))
    }

    /// 余弦函数（弧度）
    public var cosine: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(cos(v))
    }

    /// 正切函数（弧度）
    public var tangent: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(tan(v))
    }

    // MARK: - 三角函数（角度）

    /// 正弦函数（角度）
    public var sineDegrees: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(sin(v * .pi / 180.0))
    }

    /// 余弦函数（角度）
    public var cosineDegrees: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(cos(v * .pi / 180.0))
    }

    /// 正切函数（角度）
    public var tangentDegrees: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(tan(v * .pi / 180.0))
    }

    // MARK: - 对数与幂

    /// 自然对数 ln
    public var naturalLog: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(log(v))
    }

    /// 常用对数 log10
    public var commonLog: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        return Decimal(log10(v))
    }

    /// 平方根
    public var squareRoot: Decimal {
        let v = (self as NSDecimalNumber).doubleValue
        guard v >= 0 else { return Decimal.nan }
        return Decimal(sqrt(v))
    }

    /// 平方
    public var squared: Decimal {
        self * self
    }

    /// 幂运算 `self ^ exponent`
    /// 通过 Double 桥接实现；底数为负且指数非整数时结果为 NaN。
    public func power(_ exponent: Decimal) -> Decimal {
        let base = (self as NSDecimalNumber).doubleValue
        let exp  = (exponent as NSDecimalNumber).doubleValue
        let raw  = pow(base, exp)
        if raw.isNaN || raw.isInfinite { return Decimal.nan }
        return Decimal(raw)
    }

    /// 百分比（值 / 100）
    public var percent: Decimal {
        self / Decimal(100)
    }

    // MARK: - 常用常量

    public static let piValue: Decimal = Decimal(Double.pi)
    public static let eValue: Decimal  = Decimal(M_E)

    // MARK: - 辅助

    /// 是否为 NaN
    public var isNaN: Bool {
        return (self as NSDecimalNumber).doubleValue.isNaN
    }

    /// 是否为无穷
    public var isInfinite: Bool {
        return (self as NSDecimalNumber).doubleValue.isInfinite
    }

    /// 安全除法：除数为 0 时返回 .nan
    public static func safeDivide(_ lhs: Decimal, _ rhs: Decimal) -> Decimal {
        if rhs == 0 { return .nan }
        return lhs / rhs
    }
}