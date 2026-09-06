//
//  ThemeManager.swift
//  App
//
//  主题管理：深浅模式 + 强调色。
//  当前默认深色（与 iOS 系统计算器一致），提供主题切换预留接口。
//

import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {

    enum AppearanceMode: String, CaseIterable {
        case system, light, dark

        var displayName: String {
            switch self {
            case .system: return "跟随系统"
            case .light:  return "浅色"
            case .dark:   return "深色"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }
    }

    @Published var appearance: AppearanceMode = .dark
    @Published var accentColor: Color = .orange

    static let shared = ThemeManager()
    private init() {}
}