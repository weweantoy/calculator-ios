//
//  HapticsManager.swift
//  App
//
//  触觉反馈封装：所有按键统一触发 light impact。
//

import UIKit

final class HapticsManager {

    static let shared = HapticsManager()

    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)

    private init() {
        // 预热，减少首次触发延迟
        lightImpactGenerator.prepare()
        mediumImpactGenerator.prepare()
    }

    /// 按键触发：轻触反馈
    func keyTap() {
        lightImpactGenerator.impactOccurred()
        lightImpactGenerator.prepare()
    }

    /// 等号提交：中等触觉
    func commit() {
        mediumImpactGenerator.impactOccurred()
        mediumImpactGenerator.prepare()
    }
}