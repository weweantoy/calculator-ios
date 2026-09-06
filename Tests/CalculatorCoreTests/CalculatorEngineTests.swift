//
//  CalculatorEngineTests.swift
//  CalculatorCoreTests
//

import XCTest
@testable import CalculatorCore

final class CalculatorEngineTests: XCTestCase {

    // MARK: - 四则运算

    func testAddition() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("1+2")
        XCTAssertEqual(result, Decimal(3))
    }

    func testSubtraction() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("10-3")
        XCTAssertEqual(result, Decimal(7))
    }

    func testMultiplication() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("4*5")
        XCTAssertEqual(result, Decimal(20))
    }

    func testDivision() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("20/4")
        XCTAssertEqual(result, Decimal(5))
    }

    func testOperatorPrecedence() throws {
        let engine = CalculatorEngine()
        // 1 + 2 * 3 = 7
        let result = try engine.evaluate("1+2*3")
        XCTAssertEqual(result, Decimal(7))
    }

    func testParentheses() throws {
        let engine = CalculatorEngine()
        // (1 + 2) * 3 = 9
        let result = try engine.evaluate("(1+2)*3")
        XCTAssertEqual(result, Decimal(9))
    }

    func testNestedParentheses() throws {
        let engine = CalculatorEngine()
        // ((1+2)*(3+4)) = 21
        let result = try engine.evaluate("((1+2)*(3+4))")
        XCTAssertEqual(result, Decimal(21))
    }

    // MARK: - 小数与负数

    func testDecimal() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("0.1+0.2")
        // Decimal 精度：0.3 精确
        XCTAssertEqual(result, Decimal(string: "0.3"))
    }

    func testNegativeNumber() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("-5+10")
        XCTAssertEqual(result, Decimal(5))
    }

    func testUnaryMinusWithParentheses() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("-(3+4)")
        XCTAssertEqual(result, Decimal(-7))
    }

    func testLeadingNegative() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("-2*-3")
        XCTAssertEqual(result, Decimal(6))
    }

    // MARK: - 除零与错误

    func testDivisionByZero() {
        let engine = CalculatorEngine()
        XCTAssertThrowsError(try engine.evaluate("5/0")) { error in
            guard case CalculatorError.divisionByZero = error else {
                XCTFail("Expected divisionByZero, got \(error)")
                return
            }
        }
    }

    func testEmptyExpression() {
        let engine = CalculatorEngine()
        XCTAssertThrowsError(try engine.evaluate(""))
    }

    func testMismatchedParentheses() {
        let engine = CalculatorEngine()
        XCTAssertThrowsError(try engine.evaluate("(1+2"))
    }

    func testInvalidCharacter() {
        let engine = CalculatorEngine()
        XCTAssertThrowsError(try engine.evaluate("1+2#"))
    }

    // MARK: - 百分号

    func testPercent() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("50%")
        XCTAssertEqual(result, Decimal(string: "0.5"))
    }

    func testPercentInExpression() throws {
        let engine = CalculatorEngine()
        // 200 + 10% = 200 + 0.1 = 200.1
        let result = try engine.evaluate("200+10%")
        XCTAssertEqual(result, Decimal(string: "200.1"))
    }

    // MARK: - 常量

    func testPiConstant() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("pi")
        XCTAssertEqual(result, Decimal.piValue)
    }

    func testEConstant() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("e")
        XCTAssertEqual(result, Decimal.eValue)
    }

    // MARK: - 科学函数（角度模式）

    func testSin30Degrees() throws {
        let engine = CalculatorEngine(angleUnit: .degree)
        let result = try engine.evaluate("sin(30)")
        XCTAssertEqual(result, Decimal(0.5), accuracy: Decimal(string: "0.0001")!)
    }

    func testCos60Degrees() throws {
        let engine = CalculatorEngine(angleUnit: .degree)
        let result = try engine.evaluate("cos(60)")
        XCTAssertEqual(result, Decimal(0.5), accuracy: Decimal(string: "0.0001")!)
    }

    func testTan45Degrees() throws {
        let engine = CalculatorEngine(angleUnit: .degree)
        let result = try engine.evaluate("tan(45)")
        XCTAssertEqual(result, Decimal(1), accuracy: Decimal(string: "0.0001")!)
    }

    // MARK: - 科学函数（弧度模式）

    func testSinPiOver2Radians() throws {
        let engine = CalculatorEngine(angleUnit: .radian)
        let result = try engine.evaluate("sin(pi/2)")
        XCTAssertEqual(result, Decimal(1), accuracy: Decimal(string: "0.0001")!)
    }

    func testCosPiRadians() throws {
        let engine = CalculatorEngine(angleUnit: .radian)
        let result = try engine.evaluate("cos(pi)")
        XCTAssertEqual(result, Decimal(-1), accuracy: Decimal(string: "0.0001")!)
    }

    // MARK: - 对数

    func testLnE() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("ln(e)")
        XCTAssertEqual(result, Decimal(1), accuracy: Decimal(string: "0.0001")!)
    }

    func testLog10() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("log(100)")
        XCTAssertEqual(result, Decimal(2), accuracy: Decimal(string: "0.0001")!)
    }

    func testLnOfNegativeThrows() {
        let engine = CalculatorEngine()
        XCTAssertThrowsError(try engine.evaluate("ln(-1)"))
    }

    // MARK: - 平方根

    func testSqrt() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("sqrt(16)")
        XCTAssertEqual(result, Decimal(4))
    }

    func testSqrtOfNegativeThrows() {
        let engine = CalculatorEngine()
        XCTAssertThrowsError(try engine.evaluate("sqrt(-4)"))
    }

    // MARK: - 混合复杂表达式

    func testComplexExpression1() throws {
        let engine = CalculatorEngine(angleUnit: .degree)
        // 2 * (3 + 4) - sqrt(9) + sin(30) = 14 - 3 + 0.5 = 11.5
        let result = try engine.evaluate("2*(3+4)-sqrt(9)+sin(30)")
        XCTAssertEqual(result, Decimal(string: "11.5"), accuracy: Decimal(string: "0.0001")!)
    }

    func testComplexExpression2() throws {
        let engine = CalculatorEngine()
        // (10 + 20) / (2 * 3) + log(100) = 5 + 2 = 7
        let result = try engine.evaluate("(10+20)/(2*3)+log(100)")
        XCTAssertEqual(result, Decimal(7), accuracy: Decimal(string: "0.0001")!)
    }

    func testMultiplicationSymbols() throws {
        let engine = CalculatorEngine()
        // 同时支持 × 与 *
        let r1 = try engine.evaluate("3×4")
        let r2 = try engine.evaluate("3*4")
        XCTAssertEqual(r1, r2)
        XCTAssertEqual(r1, Decimal(12))
    }

    func testDivisionSymbols() throws {
        let engine = CalculatorEngine()
        let r1 = try engine.evaluate("20÷4")
        let r2 = try engine.evaluate("20/4")
        XCTAssertEqual(r1, r2)
        XCTAssertEqual(r1, Decimal(5))
    }

    func testWhitespaceIgnored() throws {
        let engine = CalculatorEngine()
        let result = try engine.evaluate("  1  +  2  ")
        XCTAssertEqual(result, Decimal(3))
    }

    // MARK: - 引擎切换角度单位

    func testAngleUnitSwitch() throws {
        let engineDegree = CalculatorEngine(angleUnit: .degree)
        let engineRadian = CalculatorEngine(angleUnit: .radian)

        // sin(90°) = 1, sin(π/2 rad) = 1
        let a = try engineDegree.evaluate("sin(90)")
        let b = try engineRadian.evaluate("sin(pi/2)")
        XCTAssertEqual(a, Decimal(1), accuracy: Decimal(string: "0.0001")!)
        XCTAssertEqual(b, Decimal(1), accuracy: Decimal(string: "0.0001")!)
    }
}

// MARK: - Decimal 精度辅助

private func XCTAssertEqual(_ lhs: Decimal, _ rhs: Decimal, accuracy: Decimal, file: StaticString = #file, line: UInt = #line) {
    let diff = abs(lhs - rhs)
    if diff > accuracy {
        XCTFail("\(lhs) 与 \(rhs) 差值 \(diff) 超出允许误差 \(accuracy)", file: file, line: line)
    }
}

private func XCTAssertEqual(_ lhs: Decimal, _ rhs: Decimal, file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(lhs == rhs, "\(lhs) != \(rhs)", file: file, line: line)
}

private func abs(_ d: Decimal) -> Decimal {
    return d < 0 ? -d : d
}