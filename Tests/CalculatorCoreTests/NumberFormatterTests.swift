//
//  NumberFormatterTests.swift
//  CalculatorCoreTests
//

import XCTest
@testable import CalculatorCore

final class NumberFormatterTests: XCTestCase {

    func testIntegerFormatting() {
        let result = CalculatorNumberFormatter.format(Decimal(1234))
        // 千分位 + 无小数
        XCTAssertTrue(result.contains("1") && result.contains("234"))
    }

    func testDecimalFormatting() {
        let result = CalculatorNumberFormatter.format(Decimal(string: "0.123456")!)
        XCTAssertTrue(result.contains("0.12"))
    }

    func testNegativeNumber() {
        let result = CalculatorNumberFormatter.format(Decimal(-42))
        XCTAssertTrue(result.contains("-") || result.contains("−"))
    }

    func testZeroFormatting() {
        let result = CalculatorNumberFormatter.format(Decimal(0))
        XCTAssertEqual(result, "0")
    }

    func testNanHandling() {
        let result = CalculatorNumberFormatter.format(Decimal.nan)
        XCTAssertEqual(result, "错误")
    }

    func testVerySmallNumberUsesScientific() {
        let result = CalculatorNumberFormatter.format(Decimal(string: "0.0000000000001")!)
        // 科学计数法包含 'E' 或 'e'
        XCTAssertTrue(result.contains("E") || result.contains("e"))
    }

    func testVeryLargeNumberUsesScientific() {
        let result = CalculatorNumberFormatter.format(Decimal(string: "100000000000000000")!)
        XCTAssertTrue(result.contains("E") || result.contains("e"))
    }

    func testIntegerHasNoDecimalPoint() {
        let result = CalculatorNumberFormatter.format(Decimal(100))
        XCTAssertFalse(result.contains("."))
    }
}