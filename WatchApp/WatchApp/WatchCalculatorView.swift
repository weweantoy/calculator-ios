import SwiftUI
import CalculatorCore

/// Watch 主视图：4×5 紧凑布局
struct WatchCalculatorView: View {

    @Bindable var viewModel: WatchCalculatorViewModel

    private let rowSpacing: CGFloat = 6
    private let colSpacing: CGFloat = 6

    var body: some View {
        VStack(spacing: 6) {
            DisplayView(
                expression: viewModel.expression,
                result: viewModel.displayValue,
                error: viewModel.errorMessage
            )
            .frame(height: 52)

            ButtonGridView(
                onTap: viewModel.handle,
                rowSpacing: rowSpacing,
                colSpacing: colSpacing
            )
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
        .background(Color("CalcBackground", bundle: .main).ignoresSafeArea())
    }
}

/// 显示区
struct DisplayView: View {
    let expression: String
    let result: String
    let error: String?

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if !expression.isEmpty {
                Text(expression)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Text(error != nil ? "错误" : (result.isEmpty ? "0" : result))
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(error != nil ? .red : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 6)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("display_result")
    }
}

/// 按键网格（4 列 × 5 行）
struct ButtonGridView: View {
    let onTap: (WatchKeyAction) -> Void
    let rowSpacing: CGFloat
    let colSpacing: CGFloat

    private let row1: [WatchKeyAction] = [
        .clear, .toggleSign, .percent, .op(.divide)
    ]
    private let row2: [WatchKeyAction] = [
        .digit(7), .digit(8), .digit(9), .op(.multiply)
    ]
    private let row3: [WatchKeyAction] = [
        .digit(4), .digit(5), .digit(6), .op(.subtract)
    ]
    private let row4: [WatchKeyAction] = [
        .digit(1), .digit(2), .digit(3), .op(.add)
    ]
    private let row5: [WatchKeyAction] = [
        .digit(0), .decimal, .delete, .equals
    ]

    var body: some View {
        VStack(spacing: rowSpacing) {
            rowView(row1)
            rowView(row2)
            rowView(row3)
            rowView(row4)
            rowView(row5)
        }
    }

    private func rowView(_ keys: [WatchKeyAction]) -> some View {
        HStack(spacing: colSpacing) {
            ForEach(0..<keys.count, id: \.self) { idx in
                WatchButton(action: keys[idx], onTap: onTap)
            }
        }
    }
}

/// Watch 端按钮组件（紧凑版）
struct WatchButton: View {
    let action: WatchKeyAction
    let onTap: (WatchKeyAction) -> Void

    var body: some View {
        Button {
            onTap(action)
        } label: {
            Text(label)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }

    private var label: String {
        switch action {
        case .digit(let d): return String(d)
        case .decimal: return "."
        case .op(let op): return op.rawValue
        case .equals: return "="
        case .clear: return "AC"
        case .delete: return "⌫"
        case .toggleSign: return "±"
        case .percent: return "%"
        }
    }

    private var fontSize: CGFloat {
        switch action {
        case .equals, .op: return 18
        default: return 17
        }
    }

    private var background: Color {
        switch action {
        case .equals: return Color("CalcOperationButton", bundle: .main)
        case .op: return Color("CalcOperationButton", bundle: .main)
        case .clear, .delete, .toggleSign, .percent:
            return Color("CalcFunctionButton", bundle: .main)
        default:
            return Color("CalcDigitButton", bundle: .main)
        }
    }

    private var foreground: Color {
        switch action {
        case .digit, .decimal, .equals, .op: return .white
        default: return .black
        }
    }

    private var identifier: String {
        switch action {
        case .digit(let d): return "key_digit_\(d)"
        case .decimal: return "key_dot"
        case .op(let op):
            switch op {
            case .add: return "key_plus"
            case .subtract: return "key_minus"
            case .multiply: return "key_multiply"
            case .divide: return "key_divide"
            }
        case .equals: return "key_equals"
        case .clear: return "key_ac"
        case .delete: return "key_delete"
        case .toggleSign: return "key_sign"
        case .percent: return "key_percent"
        }
    }
}

#Preview {
    WatchCalculatorView(viewModel: WatchCalculatorViewModel())
}
