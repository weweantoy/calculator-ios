# ============================================================
# Calculator · 下载到 iPhone 全流程
# ============================================================
#
# 本文档汇集从仓库源码到 iPhone 真机运行的完整流程。
# 适用两种交付方式：
#   A. 开发者（Apple Developer 账号）：标准流程
#   B. 普通用户（无付费开发者账号）：通过 AltStore / Sideloadly 临时签名
#
# ============================================================


# ============================================================
# 路径 A · 开发者账号（推荐 · 永久签名 7 天 / 1 年）
# ============================================================

## 0. 前置条件
- 一台 macOS 电脑（macOS 13+）
- 安装 Xcode 15+（App Store 下载）
- 安装 xcodegen（`brew install xcodegen`）
- Apple Developer 账号（个人 $99/年，企业另议）
- 一台 iPhone（iOS 17+）

## 1. 获取 Team ID
登录 https://developer.apple.com/account → Membership → Team ID
形如 `ABC123XYZ`

## 2. 配置签名
打开 `project.yml`，在 `settings.base.DEVELOPMENT_TEAM` 处填入：
```yaml
DEVELOPMENT_TEAM: "ABC123XYZ"
```

或在 xcconfig 中通过环境变量：
```bash
export DEVELOPER_TEAM_ID=ABC123XYZ
```

## 3. 一键构建
```bash
chmod +x Scripts/build.sh
./Scripts/build.sh
```
或：
```bash
./Scripts/build.sh --team ABC123XYZ
```

生成的产物：
- `build/Calculator.ipa`  —— 主交付物
- `build/Calculator.app` —— 已签名 App Bundle
- `build/Calculator.xcarchive` —— Xcode Archive

## 4. 安装到 iPhone
### 方式 1：USB 直连
```bash
# 1. iPhone 连到 Mac
# 2. 列出设备
xcrun devicectl list devices
# 输出形如：
#   <UDID>  My iPhone  iPhone 15  iOS 17.0  Connected

# 3. 安装
xcrun devicectl device install app \
  --device <UDID> \
  build/Calculator.ipa
```

### 方式 2：Xcode 安装（更稳）
```bash
open build/Calculator.xcarchive  # 拖入 Xcode Organizer
```
或：
```bash
xcodebuild -exportArchive \
  -archivePath build/Calculator.xcarchive \
  -exportPath build \
  -exportOptionsPlist build/ExportOptions/Development.plist
open Calculator.xcodeproj
# Product → Run (⌘R)
```

## 5. 信任证书（首次安装必做）
1. iPhone 上：设置 → 通用 → VPN 与设备管理
2. 点 "开发者 APP"
3. 选择你的 Apple ID → 信任

## 6. 启动
主屏 App 名为「计算器」。


# ============================================================
# 路径 B · 普通用户（无需付费 · 7 天有效期）
# ============================================================

适用：没买 Apple Developer 账号，但想在 iPhone 上跑起来体验。

## B.1. AltStore（推荐）
AltStore 用你自己的 Apple ID 给 App 临时签名，**完全免费**。

### 准备工作
- iPhone + iPhone 用的 Apple ID（自己的）
- Mac 或 Windows 电脑
- iTunes（Windows）/ Finder（macOS）已安装

### 步骤
1. Mac 上下载 AltServer：https://altstore.io
2. 用 USB 连 iPhone 到 Mac
3. AltServer → Install AltStore → 选 iPhone
4. 输入 Apple ID 与密码（**建议用 App-Specific Password**）
5. iPhone 上出现 AltStore App
6. AltStore → My Apps → URL Schemes 或直接拖入 `Calculator.ipa`
7. 设备上信任证书：设置 → 通用 → 设备管理 → 信任

### 有效期：7 天，过期需重新加载
或购买 AltStore Patreon（仅一年 $99），延至 1 年。

## B.2. Sideloadly（仅 Windows）
Windows 用户用 Sideloadly：
1. 下载：https://sideloadly.io
2. 连接 iPhone
3. 把 `build/Calculator.ipa` 拖入
4. 输入 Apple ID
5. Start

设备 → 信任 → 完成。

## B.3. iOS App Signer（macOS）
1. 下载：https://dantheman827.github.io/ios-app-signer/
2. Input File → `Calculator.app`
3. Signing → 选你的 Apple ID + Provisioning Profile
4. Start
5. 产出 `Calculator.ipa`
6. 用 Xcode → Devices → Install


# ============================================================
# 路径 C · TestFlight（推荐用于给多个测试用户分发）
# ============================================================

如果你有 Apple Developer 账号且想给其他人体验：

1. App Store Connect → 我的 App → 创建新 App
2. 准备：
   - 1024×1024 PNG 图标（无透明度）
   - 6.7" / 6.1" / 5.5" 三种尺寸截图
   - 描述、关键词、隐私政策 URL
3. Xcode → Product → Archive → Distribute App → TestFlight
4. 上传后，App Store Connect → TestFlight 添加测试员
5. 测试员通过邮箱邀请安装 TestFlight App
6. 体验有效期 90 天 / Build 数量有限


# ============================================================
# 路径 D · 局域网无线安装（最快）
# ============================================================

适合开发调试：
```bash
# 1. iPhone 连同一 Wi-Fi
# 2. 找到 iPhone 的 IP
xcrun devicectl list devices | grep -i iphone

# 3. xcodebuild 直接 run，Xcode 自动无线部署
xcodebuild -project Calculator.xcodeproj \
  -scheme Calculator \
  -destination 'platform=iOS,id=<UDID>' \
  build
# Product → Run (⌘R)
```


# ============================================================
# 常见问题
# ============================================================

## Q: 签名失败 "No signing certificate"
A: 检查 keychain 是否有 "Apple Development" 证书。
   Xcode → Settings → Accounts → Download Manual Profiles。

## Q: "Could not find Developer Disk Image"
A: iOS 版本和 Xcode 不匹配。
   macOS：升级 Xcode 或在 Xcode 偏好设置中下载对应 iOS 模拟器。

## Q: iPhone 提示"未受信任的开发者"
A: 设置 → 通用 → VPN 与设备管理 → 开发者 APP → 信任。

## Q: AltStore 反复掉签
A: 7 天过期。每月用 AltStore 重新加载一次即可。
   或考虑小狐狸 / Feather 等替代工具。

## Q: 想要上 App Store 正式发布
A: 需要苹果开发者账号注册 App + 提交审核。完整流程另写文档。

## Q: Widget / Apple Watch 无法安装
A: 单独 Watch + Widget 安装（需要在 iPhone 上），
   首次会自动跟随主 App 安装。

## Q: 模拟器能跑，真机不能跑？
A: 多半是 Bundle Identifier 冲突或描述文件问题。
   Xcode → Signing & Capabilities 重新勾选 Team。

# ============================================================
# 文件清单
# ============================================================

运行 `./Scripts/build.sh` 后：

| 路径 | 用途 |
|------|------|
| `build/Calculator.ipa` | 主交付物，发送给测试用户 |
| `build/Calculator.xcarchive` | 备份用，可重新导出 |
| `build/Calculator.app/` | 已签名 App Bundle |
| `build/app/Calculator.app` | 同上，单独目录 |
| `build/ExportOptions/Development.plist` | 导出配置 |

# ============================================================
# 关于"下载到手机运行"的最快方案
# ============================================================

**普通用户 + 不想折腾**：
1. 找朋友/同事借一台 mac
2. `xcodegen generate && open Calculator.xcodeproj`
3. 修改 Team ID 为你的 Apple ID（个人也行）
4. ⌘R 自动安装到连接 iPhone

**纯 Windows 用户**：
1. 用 GitHub Actions 构建（参考 docs/CI.md）
2. 下载产物 IPA → Sideloadly 装到手机

**直接给我预编译的 IPA**：
联系开发者（生成 Scripts/release_ipa.sh 可输出给非开发者的 IPA）


# ============================================================
