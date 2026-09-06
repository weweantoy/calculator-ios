//
//  DisplayView.swift
//  App
//
//  显示区：右上角自适应字号的大数字 + 表达式回显 + 错误提示。
//

import SwiftUI
import CalculatorCore

struct DisplayView: View {

    let expression: String
    let result: String
    let error: String?

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // 表达式回显（小字号，灰色）
            if !expression.isEmpty {
                Text(expression)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.head)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("display_expression")
            }

            // 主显示：大字号，动态缩放
            Text(error != nil ? "错误" : result)
                .font(.system(size: dynamicFontSize, weight: .light))
                .foregroundStyle(error != nil ? .red : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityIdentifier("display_result")
                .accessibilityLabel("计算结果 \(error != nil ? error ?? "" : result)")

            // 错误信息
            if let error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("display_error")
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    /// 根据字符长度动态调整字号
    private var dynamicFontSize: CGFloat {
        let len = result.count
        if len <= 8  { return 64 }
        if len <= 12 { return 48 }
        if len <= 16 { return 36 }
        return 28
    }
}