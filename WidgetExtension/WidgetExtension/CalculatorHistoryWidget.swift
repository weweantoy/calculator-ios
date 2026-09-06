import WidgetKit
import SwiftUI
import CalculatorCore

/// 历史记录列表 Widget：长按桌面更直观查看历史
struct CalculatorHistoryWidget: Widget {

    let kind: String = "CalculatorHistoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CalculatorProvider()
        ) { entry in
            CalculatorHistoryWidgetView(entry: entry)
        }
        .configurationDisplayName("历史记录")
        .description("查看最近 10 条计算历史。")
        .supportedFamilies([.systemLarge])
    }
}

struct CalculatorHistoryWidgetView: View {

    let entry: CalculatorEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.orange)
                Text("历史记录")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text("查看全部")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
            }

            if entry.history.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("暂无历史记录")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("使用 App 进行计算后自动保存")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(entry.history.prefix(10)) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text(item.result)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.orange)
                            .frame(width: 80, alignment: .trailing)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.expression)
                                .font(.system(size: 13))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .truncationMode(.head)
                            Text(item.timestamp, style: .relative)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .accessibilityLabel("\(item.expression) 等于 \(item.result)")
                }
                Spacer()
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
        .widgetURL(CalculatorDeepLink.openHistory)
    }
}
