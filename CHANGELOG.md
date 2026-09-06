# 变更日志

## [1.0.0] - 2026-09-06

### 新增
- 核心引擎 `CalculatorCore`：表达式解析器（Tokenizer + Recursive Descent Parser）
- iOS 主 App：基础 + 科学双模式、SwiftUI + MVVM
- Apple Watch 配套 App（watchOS 10+）：紧凑 4×5 布局
- Widget Extension（iOS 17+）：
  - Home Widget（Small / Medium / Large）
  - History Widget（Large）
  - Lock Screen + StandBy Widget（Circular / Rectangular / Inline）
- App Group 跨 Target 共享数据（iPhone ↔ Watch ↔ Widget）
- SwiftData 历史持久化
- 触觉反馈（`UIImpactFeedbackGenerator` / `WKInterfaceDevice`）
- 双语本地化（zh-Hans / en）
- 28+ 单元测试覆盖核心引擎
- 17+ XCUITest 覆盖 UI 流程
- GitHub Actions CI（自动构建 + 产物上传）
- 完整一键安装流程支持（开发者 / AltStore / Sideloadly / TestFlight）

### 工程
- xcodegen 一键生成 `.xcodeproj`
- Fastlane 自动上架
- Makefile 一键命令
- 跨平台构建脚本
