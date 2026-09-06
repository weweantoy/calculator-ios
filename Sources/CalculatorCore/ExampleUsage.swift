//
//  ExampleUsage.swift
//  CalculatorCore
//
//  使用示例：演示 CalculatorEngine 的典型调用方式。
//

import Foundation

/// CalculatorCore 使用示例（不参与正式构建，仅作文档参考）
public enum CalculatorEngineExample {

    public static func run() {
        let engine = CalculatorEngine(angleUnit: .degree)

        // 1. 基础四则
        do {
            let r = try engine.evaluate("1 + 2 * 3")
            print("1 + 2 * 3 = \(CalculatorNumberFormatter.format(r))")
        } catch {
            print("错误：\(error)")
        }

        // 2. 括号嵌套
        do {
            let r = try engine.evaluate("(1 + 2) * (3 + 4)")
            print("(1+2)*(3+4) = \(CalculatorNumberFormatter.format(r))")
        } catch {
            print("错误：\(error)")
        }

        // 3. 科学函数
        do {
            let r = try engine.evaluate("sin(30) + cos(60)")
            print("sin(30) + cos(60) = \(CalculatorNumberFormatter.format(r))")
        } catch {
            print("错误：\(error)")
        }

        // 4. 切换弧度
        engine.angleUnit = .radian
        do {
            let r = try engine.evaluate("sin(pi/2)")
            print("sin(π/2 rad) = \(CalculatorNumberFormatter.format(r))")
        } catch {
            print("错误：\(error)")
        }

        // 5. 除零
        do {
            _ = try engine.evaluate("5/0")
        } catch CalculatorError.divisionByZero {
            print("捕获到除零错误")
        } catch {
            print("其他错误：\(error)")
        }
    }
}