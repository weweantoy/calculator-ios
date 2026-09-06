# 资源文件配置说明

本目录包含完整的 iOS 资源文件配置：

## 文件清单

| 文件/目录 | 用途 |
|---------|------|
| `Info.plist` | 应用元数据、启动屏、权限声明、方向支持 |
| `Assets.xcassets/` | 颜色与图标资源 |
| `zh_CN.lproj/Localizable.strings` | 中文本地化字符串 |
| `en.lproj/Localizable.strings` | 英文本地化字符串 |

## Info.plist 关键字段

| 字段 | 值 | 说明 |
|-----|-----|------|
| `CFBundleDisplayName` | `计算器` | 主屏图标下显示的名称 |
| `UILaunchScreen.UIColorName` | `CalcBackground` | 启动屏背景色（深色模式黑色，浅色模式白色）|
| `UISupportedInterfaceOrientations` | Portrait | 仅支持竖屏（iPhone） |
| `ITSAppUsesNonExemptEncryption` | `false` | 加密声明（App Store 必备）|
| `LSApplicationCategoryType` | `public.app-category.utilities` | 类别：工具 |

## Assets.xcassets 颜色集

| 名称 | 浅色值 | 深色值 | 用途 |
|-----|-------|-------|------|
| `AccentColor` | #FF9500 | #FF9500 | 系统强调色（如开关、链接）|
| `CalcBackground` | #FFFFFF | #000000 | 背景 |
| `CalcDigitButton` | #D1D1D6 | #333336 | 数字键 |
| `CalcFunctionButton` | #FFFFFF | #A5A5A5 | 函数键 |
| `CalcOperationButton` | #FF9500 | #FF9500 | 运算键 |
| `CalcTextPrimary` | #000000 | #FFFFFF | 主文字 |
| `CalcTextSecondary` | #6C6C6C | #808080 | 次文字 |

## App Icon 生成指南

`AppIcon.appiconset/Contents.json` 已声明全部 18 种尺寸。**实际 PNG 文件需另行生成**：

### 方案 A：使用 SF Symbols 导出（推荐）

1. 用 macOS 自带 Preview 创建 1024×1024 空白图
2. 打开 SF Symbols App（Xcode 自带），选择 `function` 或 `plus.forwardslash.minus`
3. 导出为 PNG，按下列尺寸另存：

| 尺寸 | 文件名 |
|-----|-------|
| 20×20 @2x | `AppIcon-20@2x.png` (40×40) |
| 20×20 @3x | `AppIcon-20@3x.png` (60×60) |
| 29×29 @2x | `AppIcon-29@2x.png` (58×58) |
| 29×29 @3x | `AppIcon-29@3x.png` (87×87) |
| 40×40 @2x | `AppIcon-40@2x.png` (80×80) |
| 40×40 @3x | `AppIcon-40@3x.png` (120×120) |
| 60×60 @2x | `AppIcon-60@2x.png` (120×120) |
| 60×60 @3x | `AppIcon-60@3x.png` (180×180) |
| 76×76 @1x | `AppIcon-76@1x.png` (76×76) |
| 76×76 @2x | `AppIcon-76@2x.png` (152×152) |
| 83.5×83.5 @2x | `AppIcon-83.5@2x.png` (167×167) |
| 1024×1024 | `AppIcon-1024.png` |

### 方案 B：使用 [appicon.co](https://appicon.co/)

1. 设计一张 1024×1024 PNG（透明背景）
2. 上传到 appicon.co 自动生成全部尺寸
3. 下载后解压到 `AppIcon.appiconset/`

### 方案 C：Xcode 15+ 的 "单一尺寸"

iOS 17+ 支持 1024×1024 单一图标，Xcode 自动缩放。简单场景下可只提供：
- `AppIcon-1024.png`（1024×1024，App Store + 所有设备）
- `AppIcon-60@2x.png`（120×120，设置页）
- `AppIcon-60@3x.png`（180×120，主屏）

## 本地化

将 `Localizable.strings` 中的字符串映射到 UI 时使用：

```swift
Text(NSLocalizedString("history_title", comment: ""))
```

### 切换测试语言

```swift
app.launchArguments = ["-AppleLanguages", "(en)"]
app.launch()
```

## 在 Xcode 中集成

1. 新建 iOS App 工程
2. 在工程导航器中右键 → `Add Files to "CalculatorApp"...`
3. 选择 `Info.plist`、`Assets.xcassets/`、`*.lproj/`
4. 在 `Project Settings → Info.plist File` 中选择本 `Info.plist`
5. 编译运行

## 启动屏自定义

如需更换启动屏为图片：

```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIImageName</key>
    <string>LaunchImage</string>
</dict>
```

并在 `Assets.xcassets` 中添加 `LaunchImage.imageset/`。