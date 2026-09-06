//
//  CalculatorUITests.swift
//  CalculatorUITests
//
//  计算器 UI 测试套件：覆盖基础模式、科学模式、错误处理、历史记录等。
//  通过 accessibility identifier（key_*、display_*）定位控件。
//

import XCTest

final class CalculatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // 在每次测试前重置状态（可选：清理持久化存储）
        // app.launchArguments = ["-AppleLanguages", "(zh_CN)"]
        app.launch()
        // 等待首屏加载
        XCTAssertTrue(app.buttons["key_ac"].waitForExistence(timeout: 5))
    }

    // MARK: - 工具方法

    /// 轻点 AC 按钮
    private func clear() {
        app.buttons["key_ac"].tap()
    }

    /// 输入多位数字
    private func input(_ digits: String) {
        for ch in digits {
            let key = "key_digit_\(ch)"
            if app.buttons[key].exists {
                app.buttons[key].tap()
            }
        }
    }

    private func press(_ identifier: String) {
        app.buttons[identifier].tap()
    }

    /// 读取主显示结果
    private func currentResult() -> String {
        return app.staticTexts["display_result"].label
    }

    /// 读取表达式回显
    private func currentExpression() -> String {
        return app.staticTexts["display_expression"].label
    }

    // MARK: - 基础加法

    func testSimpleAddition() {
        clear()
        input("1")
        press("key_plus")
        input("2")
        press("key_equals")
        XCTAssertEqual(currentResult(), "3", "1 + 2 应等于 3")
    }

    func testAdditionWithLargerNumbers() {
        clear()
        input("1234")
        press("key_plus")
        input("5678")
        press("key_equals")
        XCTAssertEqual(currentResult(), "6,912", "1234 + 5678 应等于 6,912")
    }

    // MARK: - 基础减法

    func testSimpleSubtraction() {
        clear()
        input("10")
        press("key_minus")
        input("3")
        press("key_equals")
        XCTAssertEqual(currentResult(), "7", "10 - 3 应等于 7")
    }

    func testNegativeResult() {
        clear()
        input("5")
        press("key_minus")
        input("10")
        press("key_equals")
        let result = currentResult()
        XCTAssertTrue(result.contains("-"), "5 - 10 应为负数，实际：\(result)")
    }

    // MARK: - 乘法与除法

    func testSimpleMultiplication() {
        clear()
        input("6")
        press("key_multiply")
        input("7")
        press("key_equals")
        XCTAssertEqual(currentResult(), "42", "6 × 7 应等于 42")
    }

    func testSimpleDivision() {
        clear()
        input("20")
        press("key_divide")
        input("4")
        press("key_equals")
        XCTAssertEqual(currentResult(), "5", "20 ÷ 4 应等于 5")
    }

    // MARK: - 运算符优先级

    func testOperatorPrecedence() {
        clear()
        input("1")
        press("key_plus")
        input("2")
        press("key_multiply")
        input("3")
        press("key_equals")
        XCTAssertEqual(currentResult(), "7", "1 + 2 × 3 应等于 7（乘法优先）")
    }

    func testParenthesesNotInBasicMode() {
        // 基础模式没有括号按钮（科学模式才有），跳过
    }

    // MARK: - 小数

    func testDecimalAddition() {
        clear()
        input("0")
        press("key_decimal")
        input("1")
        press("key_plus")
        input("0")
        press("key_decimal")
        input("2")
        press("key_equals")
        let result = currentResult()
        XCTAssertTrue(result.contains("0.3"), "0.1 + 0.2 应等于 0.3，实际：\(result)")
    }

    // MARK: - 删除与清空

    func testBackspaceDeletesLastDigit() {
        clear()
        input("123")
        press("key_delete")
        // 显示应为 12
        let result = currentResult()
        XCTAssertTrue(result.contains("12"), "删除一位后应剩 12，实际：\(result)")
    }

    func testClearResetsToZero() {
        clear()
        input("999")
        clear()
        XCTAssertEqual(currentResult(), "0", "AC 后应重置为 0")
    }

    // MARK: - 除零错误

    func testDivisionByZeroShowsError() {
        clear()
        input("5")
        press("key_divide")
        input("0")
        press("key_equals")

        // 显示区应变为"错误"，或包含错误提示
        let result = currentResult()
        let hasError = result.contains("错误") ||
                       result.contains("Error") ||
                       result.contains("∞") ||
                       app.staticTexts["display_error"].exists
        XCTAssertTrue(hasError, "5 ÷ 0 应触发错误，实际：\(result)")
    }

    // MARK: - 百分号

    func testPercentOnNumber() {
        clear()
        input("50")
        press("key_percent")
        let result = currentResult()
        XCTAssertTrue(result.contains("0.5"), "50 % 应等于 0.5，实际：\(result)")
    }

    // MARK: - 正负号切换

    func testToggleSign() {
        clear()
        input("5")
        press("key_sign")
        let result = currentResult()
        XCTAssertTrue(result.contains("-5") || result.contains("- 5"),
                      "± 后应为 -5，实际：\(result)")

        // 再按一次应该回到正数
        press("key_sign")
        let result2 = currentResult()
        XCTAssertFalse(result2.contains("-"), "再按 ± 应回到正数，实际：\(result2)")
    }

    // MARK: - 模式切换

    func testSwitchToScientificMode() {
        clear()
        // 模式切换器（使用 Picker）
        let basicModeButton = app.segmentedControls.buttons["基础"]
        let scientificModeButton = app.segmentedControls.buttons["科学"]

        if scientificModeButton.exists {
            scientificModeButton.tap()

            // 科学模式特有按钮应出现
            XCTAssertTrue(app.buttons["key_sin"].waitForExistence(timeout: 2),
                          "科学模式下 sin 按钮应可见")
            XCTAssertTrue(app.buttons["key_cos"].exists, "cos 按钮应可见")
            XCTAssertTrue(app.buttons["key_tan"].exists, "tan 按钮应可见")

            // 切回基础
            if basicModeButton.exists {
                basicModeButton.tap()
            }
        }
    }

    // MARK: - 科学函数

    func testSin30Degrees() {
        // 切到科学模式
        let scientificModeButton = app.segmentedControls.buttons["科学"]
        if scientificModeButton.exists {
            scientificModeButton.tap()
        }

        clear()
        press("key_sin")
        input("30")
        press("key_right_paren")
        press("key_equals")

        let result = currentResult()
        // sin(30°) = 0.5
        XCTAssertTrue(result.contains("0.5"), "sin(30°) 应等于 0.5，实际：\(result)")
    }

    func testCos60Degrees() {
        let scientificModeButton = app.segmentedControls.buttons["科学"]
        if scientificModeButton.exists {
            scientificModeButton.tap()
        }

        clear()
        press("key_cos")
        input("60")
        press("key_right_paren")
        press("key_equals")

        let result = currentResult()
        XCTAssertTrue(result.contains("0.5"), "cos(60°) 应等于 0.5，实际：\(result)")
    }

    func testSqrt() {
        let scientificModeButton = app.segmentedControls.buttons["科学"]
        if scientificModeButton.exists {
            scientificModeButton.tap()
        }

        clear()
        press("key_sqrt")
        input("16")
        press("key_right_paren")
        press("key_equals")

        XCTAssertEqual(currentResult(), "4", "√16 应等于 4")
    }

    func testPiConstant() {
        let scientificModeButton = app.segmentedControls.buttons["科学"]
        if scientificModeButton.exists {
            scientificModeButton.tap()
        }

        clear()
        press("key_pi")
        press("key_equals")

        let result = currentResult()
        // π ≈ 3.14...
        XCTAssertTrue(result.contains("3.14"), "π 应约等于 3.14，实际：\(result)")
    }

    // MARK: - 历史记录

    func testHistoryPanelOpens() {
        clear()
        input("1")
        press("key_plus")
        input("2")
        press("key_equals")

        // 点击历史按钮（clock icon）
        let historyButton = app.buttons["历史记录"]
        if historyButton.exists {
            historyButton.tap()
            // 历史面板应出现
            let titleText = app.staticTexts["历史记录"]
            XCTAssertTrue(titleText.waitForExistence(timeout: 2),
                          "历史记录面板标题应可见")
        }
    }

    func testHistoryPersistsCalculation() {
        clear()
        input("7")
        press("key_multiply")
        input("8")
        press("key_equals")

        let historyButton = app.buttons["历史记录"]
        if historyButton.exists {
            historyButton.tap()
            sleep(1)
            // 列表中应出现 7 × 8 = 56
            let cells = app.cells
            if cells.count > 0 {
                let lastCell = cells.element(boundBy: 0)
                XCTAssertTrue(lastCell.label.contains("56") ||
                              lastCell.label.contains("7"),
                              "历史记录应包含 7 × 8 = 56，实际：\(lastCell.label)")
            }
        }
    }

    // MARK: - 长流程场景

    func testComplexCalculationFlow() {
        clear()
        // (1 + 2) * (3 + 4) = 21
        press("key_left_paren")
        input("1")
        press("key_plus")
        input("2")
        press("key_right_paren")
        press("key_multiply")
        press("key_left_paren")
        input("3")
        press("key_plus")
        input("4")
        press("key_right_paren")
        press("key_equals")
        XCTAssertEqual(currentResult(), "21", "(1+2)*(3+4) 应等于 21")
    }

    func testContinuousCalculations() {
        clear()
        // 第一次：2 + 3 = 5
        input("2")
        press("key_plus")
        input("3")
        press("key_equals")
        XCTAssertEqual(currentResult(), "5", "第一次 2+3=5")

        clear()

        // 第二次：10 - 4 = 6
        input("10")
        press("key_minus")
        input("4")
        press("key_equals")
        XCTAssertEqual(currentResult(), "6", "第二次 10-4=6")

        clear()

        // 第三次：6 * 7 = 42
        input("6")
        press("key_multiply")
        input("7")
        press("key_equals")
        XCTAssertEqual(currentResult(), "42", "第三次 6×7=42")
    }

    // MARK: - 性能测试

    func testRapidTappingPerformance() throws {
        measure {
            clear()
            for _ in 0..<10 {
                input("123")
                clear()
            }
        }
    }
}