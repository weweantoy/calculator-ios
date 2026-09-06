import WidgetKit
import SwiftUI
import CalculatorCore

/// 主 Widget：最近结果展示
struct CalculatorHomeWidget: Widget {

    let kind: String = "CalculatorHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CalculatorProvider()
        ) { entry in
            CalculatorHomeWidgetView(entry: entry)
        }
        .configurationDisplayName("计算器")
        .description("快速查看最近一次计算结果。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

struct CalculatorHomeWidgetView: View {

    @Environment(\.widgetFamily) private var family
    let entry: CalculatorEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(entry: entry)
        case .systemMedium:
            MediumView(entry: entry)
        case .systemLarge:
            LargeView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }
}

// MARK: - Small

private struct SmallView: View {

    let entry: CalculatorEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "function")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.orange)

            Spacer()

            if let latest = entry.latest {
                Text(latest.result)
                    .font(.system(size: 28, weight: .light))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Text(latest.expression)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                Text("0")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.primary)
                Text("点击打开")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
        .widgetURL(CalculatorDeepLink.openApp)
    }
}

// MARK: - Medium

private struct MediumView: View {

    let entry: CalculatorEntry

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "function")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
                Spacer()
                if let latest = entry.latest {
                    Text(latest.result)
                        .font(.system(size: 32, weight: .light))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Text(latest.expression)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("0")
                        .font(.system(size: 38, weight: .light))
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("历史")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                ForEach(entry.history.prefix(3)) { item in
                    HStack {
                        Text(item.result)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(item.expression)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.head)
                    }
                }
                if entry.history.isEmpty {
                    Text("暂无记录")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
        .widgetURL(CalculatorDeepLink.openHistory)
    }
}

// MARK: - Large

private struct LargeView: View {

    let entry: CalculatorEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "function")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.orange)
                Text("计算器")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            if let latest = entry.latest {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最近一次")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(latest.result)
                        .font(.system(size: 36, weight: .light))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Text(latest.expression)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.head)
                }
            }

            Divider()

            Text("历史记录")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            ForEach(entry.history.prefix(6)) { item in
                HStack(spacing: 8) {
                    Text(item.result)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.orange)
                        .frame(width: 60, alignment: .trailing)
                    Text(item.expression)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.head)
                    Spacer()
                    Text(item.timestamp, style: .relative)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 2)
            }

            if entry.history.isEmpty {
                Text("暂无记录")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color("WidgetBackground")
        }
        .widgetURL(CalculatorDeepLink.openApp)
    }
}
