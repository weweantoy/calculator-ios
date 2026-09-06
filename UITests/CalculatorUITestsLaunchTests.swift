//
//  CalculatorUITestsLaunchTests.swift
//  CalculatorUITests
//
//  启动性能与冒烟测试：验证 App 能成功启动并显示基础 UI 元素。
//

import XCTest

final class CalculatorUITestsLaunchTests: XCTestCase {

    /// 启动性能指标（基线测试）
    func testAppLaunchPerformance() throws {
        // 此处 measure 块在多次迭代中测量启动时间
        if #available(iOS 17.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    /// 启动后能看到基本界面元素
    func testLaunchShowsBasicUIElements() throws {
        let app = XCUIApplication()
        app.launch()

        // 验证 AC、=、0 等基础按钮存在
        XCTAssertTrue(app.buttons["key_ac"].waitForExistence(timeout: 5), "AC 按钮应在启动后可见")
        XCTAssertTrue(app.buttons["key_equals"].exists, "= 按钮应可见")
        XCTAssertTrue(app.buttons["key_digit_0"].exists, "0 按钮应可见")

        // 验证显示区
        XCTAssertTrue(app.staticTexts["display_result"].exists, "主显示区应可见")

        // 初始结果应为 0
        let resultText = app.staticTexts["display_result"].label
        XCTAssertTrue(resultText.contains("0"), "初始结果显示应为 0，实际：\(resultText)")
    }

    /// 截屏（Xcode 自动存档）
    func testLaunchScreenshot() throws {
        let app = XCUIApplication()
        app.launch()
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "启动画面"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}