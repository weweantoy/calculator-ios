import WidgetKit
import SwiftUI
import CalculatorCore

/// 锁屏 Widget + StandBy 模式
struct CalculatorLockScreenWidget: Widget {

    let kind: String = "CalculatorLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CalculatorProvider()
        ) { entry in
            CalculatorLockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("快速计算")
        .description("锁屏与 StandBy 模式下快速查看计算结果。")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct CalculatorLockScreenEntryView: View {

    @Environment(\.widgetFamily) private var family
    let entry: CalculatorEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView(entry: entry)
        case .accessoryRectangular:
            RectangularView(entry: entry)
        case .accessoryInline:
            InlineView(entry: entry)
        default:
            InlineView(entry: entry)
        }
    }
}

private struct CircularView: View {
    let entry: CalculatorEntry

    var body: some View {
        ZStack {
            if let latest = entry.latest {
                VStack(spacing: 0) {
                    Text(latest.result)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(latest.timestamp, style: .time)
                        .font(.system(size: 8))
                    Text("π")
                        .font(.system(size: 8))
                        .opacity(0)
                }
            } else {
                Image(systemName: "function")
                    .font(.system(size: 18))
            }
        }
        .containerBackground(for: .widget) {
            Circle().fill(Color.clear)
        }
        .widgetURL(CalculatorDeepLink.openApp)
    }
}

private struct RectangularView: View {
    let entry: CalculatorEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let latest = entry.latest {
                HStack {
                    Text(latest.result)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer()
                }
                Text(latest.expression)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .truncationMode(.head)
                Text(latest.timestamp, style: .time)
                    .font(.system(size: 9))
                    .opacity(0.8)
            } else {
                Text("计算器")
                    .font(.system(size: 14, weight: .semibold))
                Text("点按打开 App")
                    .font(.system(size: 10))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
        .widgetURL(CalculatorDeepLink.openApp)
    }
}

private struct InlineView: View {
    let entry: CalculatorEntry

    var body: some View {
        if let latest = entry.latest {
            Text("\(latest.result) = \(latest.expression)")
                .lineLimit(1)
        } else {
            Text("计算器 · 点按打开")
        }
    }
}
