# Calculator · iOS / watchOS / Widget 计算器

> **一句话定位**：基于 SwiftUI + MVVM 的原生计算器，覆盖 iPhone + Apple Watch + Widget 三端，统一通过 App Group 共享历史与最近结果。

![Platform](https://img.shields.io/badge/iOS-17%2B-blueviolet)
![watchOS](https://img.shields.io/badge/watchOS-10%2B-orange)
![Swift](https://img.shields.io/badge/Swift-5.9-red)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 一、结论先行

| 维度 | 说明 |
|------|------|
| 平台覆盖 | **iOS 17+**（iPhone + iPad）、**watchOS 10+**（Apple Watch）、**iOS Widget**（Home + Lock Screen + StandBy） |
| 工程结构 | xcodegen 生成 `Calculator.xcodeproj`；含 4 个 Target：主 App + Watch App + Widget Extension + CalculatorCore SPM 库 |
| 性能 | `Decimal` 精度计算，28+ 单元测试，17+ UI 测试 |
| 数据同步 | App Group (`group.com.workbuddy.calc`) 跨 Target 共享历史记录 |
| 一键安装 | 开发者账号 / AltStore / Sideloadly / TestFlight 四条路径 |

---

## 二、四大特性

### 1. iOS 主 App（基础 + 科学双模式）
- 四列 × 多行按钮网格
- 触觉反馈（`UIImpactFeedbackGenerator`）
- SwiftUI 声明式 UI + MVVM
- SwiftData 持久化历史
- 深浅双主题 + 橙色强调色（与系统计算器一致）
- 双语支持（zh-Hans / en）

### 2. Apple Watch 配套 App（独立运行）
- watchOS 10+ 全新导航模型
- 4×5 紧凑布局，适配 Series 9 / 10 大屏
- `WKInterfaceDevice` 触觉反馈
- 运算结果实时同步到 iPhone 与 Widget

### 3. Widget Extension（三种配置）
| Widget | 尺寸 | 用途 |
|--------|------|------|
| **Calculator Home** | Small / Medium / Large | 最近结果快显、3 / 6 条历史 |
| **Calculator History** | Large | 10 条历史回放 |
| **Calculator Lock** | Circular / Rectangular / Inline | 锁屏与 StandBy 实时显示 |

### 4. 核心引擎（独立 SPM 包）
- `Decimal` 精度计算
- Recursive Descent Parser
- 支持运算符优先级与括号
- 角度单位（°/rad）动态切换
- 三角函数、对数、平方根、幂次、常量（π / e）

---

## 三、目录结构

```
CalculatorApp/
├── project.yml                          # xcodegen 主配置
├── Makefile                             # macOS 一键命令
├── Package.swift                        # SPM（CalculatorCore + Tests）
│
├── Sources/CalculatorCore/              # ★ 核心引擎（独立 SPM 库）
│   ├── Token.swift
│   ├── CalculatorMode.swift
│   ├── CalculatorEngine.swift           # Tokenizer + Parser + Evaluator
│   ├── NumberFormatter+Ext.swift
│   ├── Decimal+Math.swift
│   ├── AppGroupBridge.swift             # ★ 跨 Target 数据共享
│   └── ExampleUsage.swift
│
├── Tests/CalculatorCoreTests/           # 28+ 单元测试
│   ├── CalculatorEngineTests.swift
│   └── NumberFormatterTests.swift
│
├── App/                                 # iOS 主 App
│   ├── CalculatorApp.swift              # 入口 + ModelContainer
│   ├── ContentView.swift
│   ├── Models/HistoryRecord.swift
│   ├── ViewModels/
│   │   ├── CalculatorViewModel.swift
│   │   └── HistoryViewModel.swift       # 同步至 App Group
│   ├── Views/                           # 5 个 SwiftUI 视图
│   ├── Utilities/
│   └── Resources/                       # Info.plist + Assets + 双语
│
├── WatchApp/                            # Apple Watch App
│   └── WatchApp/
│       ├── WatchApp.swift               # @main
│       ├── ContentView.swift
│       ├── WatchCalculatorViewModel.swift
│       ├── WatchCalculatorView.swift
│       ├── Info.plist
│       ├── WatchApp.entitlements
│       └── Assets.xcassets/
│
├── WidgetExtension/                     # Widget Extension
│   └── WidgetExtension/
│       ├── WidgetExtensionBundle.swift
│       ├── CalculatorProvider.swift     # TimelineProvider
│       ├── CalculatorHomeWidget.swift   # Small/Medium/Large
│       ├── CalculatorHistoryWidget.swift
│       ├── CalculatorLockScreenWidget.swift
│       ├── Info.plist
│       ├── WidgetExtension.entitlements
│       └── Assets.xcassets/
│
├── UITests/                             # iOS UI 测试（XCUITest）
│   ├── CalculatorUITests.swift
│   └── CalculatorUITestsLaunchTests.swift
│
├── Scripts/                             # macOS 一键脚本
│   ├── build.sh                         # 构建 + 导出 IPA
│   ├── install_device.sh                # 安装到设备
│   └── download_to_device.md            # 完整安装文档
│
├── Fastlane/                            # 自动化上架
│   ├── Fastfile
│   ├── Appfile
│   └── Gemfile
│
├── .github/workflows/build.yml          # CI 自动构建
│
├── docs/                                # 设计文档
│   ├── Assets.md
│   └── UITests.md
│
├── README.md                            # 本文件
├── LICENSE                              # MIT
├── CHANGELOG.md
└── .gitignore
```

---

## 四、一键启动指南

### 前置条件
- macOS 13+ （必须，Xcode 平台限制）
- Xcode 15+ （`xcode-select --install`）
- xcodegen（`brew install xcodegen`）
- iPhone/iPad：iOS 17+

### 步骤

```bash
# 1. 进入工程目录
cd CalculatorApp

# 2. （仅第一次）安装工具
make install_tools

# 3. 修改 Team ID —— 打开 project.yml，把 DEVELOPMENT_TEAM: "" 改成你的 Team ID
# 或者通过环境变量：
export DEVELOPER_TEAM_ID=ABC123XYZ

# 4. 生成 Xcode 工程
make generate

# 5. 单元测试（无需 Apple ID）
make test

# 6. 构建 + 导出 IPA
make build                       # 末尾会输出 build/Calculator.ipa

# 7. 在 Xcode 中直接运行（自动安装到连接设备）
make open
# Product → Run（⌘R）

# 或模拟器
make run
```

**首次运行** 会自动创建 4 个 Target 的 `Calculator.xcodeproj`。

---

## 五、安装到 iPhone 的四种路径

### 路径 A · 开发者账号（推荐 · 永久 / 1 年）

```bash
# 1. 设置 Team ID
export DEVELOPER_TEAM_ID=ABC123XYZ

# 2. 构建 IPA
make build

# 3. iPhone 连到 Mac → 安装
xcrun devicectl device install app \
  --device <UDID> \
  build/Calculator.ipa
```

设备 UDID 通过 `xcrun devicectl list devices` 获取。

**首次需在 iPhone 信任证书**：设置 → 通用 → VPN 与设备管理 → 开发者 APP → 信任。

### 路径 B · AltStore（免费 · 7 天有效）

1. 下载 AltServer: https://altstore.io
2. Mac 上 → AltStore → Install AltStore → 选 iPhone
3. 输入 Apple ID（建议用 App-Specific Password）
4. iPhone 出现 AltStore App
5. My Apps → 拖入 `build/Calculator.ipa` → 开始

或用 Sideloadly（Windows 友好）：https://sideloadly.io

### 路径 C · TestFlight（分发给测试员）

```bash
make fastlane_test
```

会自动上传到 TestFlight，可邀请他人通过 TestFlight App 安装。

### 路径 D · 局域网无线调试

```bash
# iPhone + Mac 连同一 Wi-Fi
make open
# Product → Run（⌘R）→ 选你的 iPhone → 自动安装
```

### 详尽文档
更多安装细节、常见问题、签名故障排查：

👉 阅读 `Scripts/download_to_device.md`

---

## 六、架构图

```
┌──────────────────────────────────────────────────────────────┐
│                       iOS 主 App (CalculatorApp)            │
│                  SwiftUI + MVVM + SwiftData                  │
└────────────────────────────┬─────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ CalculatorCore│ │   Watch App │ │ Widget Ext.  │
    │  SPM 库       │ │  watchOS 10+ │ │ iOS 17+      │
    │  Decimal 精  │ │  紧凑 4×5    │ │ 3 种 size    │
    └──────────────┘ └──────────────┘ └──────────────┘
              └──────────────┴──────────────┘
                             │
                 ┌───────────▼────────────┐
                 │  App Group             │
                 │  group.com.workbuddy   │
                 │  UserDefaults(suite)   │
                 │  共享 history/lastest  │
                 └────────────────────────┘
```

---

## 七、关键技术决策

| 决策点 | 选型 | 原因 |
|--------|------|------|
| **精度** | `Decimal` | 避免 `Double` 浮点误差（`0.1 + 0.2 = 0.3` 精确） |
| **解析器** | Recursive Descent | 易于扩展运算符优先级、函数、括号 |
| **持久化** | SwiftData + App Group | 主 App 完整 SwiftData，跨 Target 仅共享轻量数据 |
| **架构** | MVVM + `@Observable` | SwiftUI 原生范式，无第三方依赖 |
| **测试** | XCTest + XCUITest | 行业标准，零额外配置 |
| **工程化** | xcodegen + Fastlane | project.yml 描述工程，可读、可 git diff |
| **CI** | GitHub Actions | 自动构建 + 上传 IPA artifact |

---

## 八、常见问题

| Q | A |
|---|---|
| **如何修改 Bundle ID？** | `project.yml` → `bundleIdPrefix`，xcodegen 会自动同步 |
| **如何加新依赖？** | `project.yml` → `packages:` 字段，参考现有 `CalculatorCore` |
| **模拟器能跑，真机不能？** | 检查 Team ID、Provisioning Profile、iOS 版本 |
| **Widget 不显示？** | 长按桌面 → 添加 → 搜 "计算器"；首次安装后系统抓取需 5-10 秒 |
| **AltStore 过期？** | 每 7 天通过 AltStore 重新加载；或订阅 AltStore Patreon |
| **如何发到 App Store？** | `make fastlane_test` 走 TestFlight → 在 App Store Connect 提审 |

---

## 九、可拓展方向（已留接口）

- **Siri Shortcuts**："Hey Siri, 用计算器算 365×7"（已配 entitlement `com.apple.developer.siri`）
- **iCloud 同步**：把 SwiftData container 改为 CloudKit backed
- **Apple Pencil 手写公式**：集成 Mathpix API（在 `CalculatorCore` 提供接口）
- **macOS Catalyst**：直接勾选 Target → Mac
- **Vision Pro**：Vision OS 1.0+ 兼容 SwiftUI

---

## 十、致谢

- 设计灵感：iOS 系统计算器
- 技术栈：SwiftUI、SwiftData、WidgetKit、WatchKit
- 构建工具：xcodegen、Fastlane、GitHub Actions

---

**准备好在 iPhone 上跑起来了吗？**

```bash
make open   # 用 Xcode 打开，自动安装到 iPhone
```
