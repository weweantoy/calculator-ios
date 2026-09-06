//
//  HistoryPanelView.swift
//  App
//
//  历史记录面板：从底部弹出的全宽列表。
//

import SwiftUI
import CalculatorCore

struct HistoryPanelView: View {

    @ObservedObject var historyVM: HistoryViewModel
    let onSelect: (HistoryRecord) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 头部
            HStack {
                Text("历史记录")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button(action: { historyVM.clearAll() }) {
                    Text("清空")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.1))

            // 列表
            if historyVM.records.isEmpty {
                Spacer()
                Text("暂无历史记录")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(historyVM.records) { record in
                            historyRow(record)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(white: 0.1).ignoresSafeArea())
        .onAppear { historyVM.fetch() }
    }

    private func historyRow(_ record: HistoryRecord) -> some View {
        Button(action: { onSelect(record) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.expression)
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                    Text(record.timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("= \(record.result)")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(Color.white.opacity(0.001))
        .contextMenu {
            Button(role: .destructive) {
                historyVM.delete(record)
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}