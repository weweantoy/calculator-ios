#!/usr/bin/env bash
# ============================================================
# Calculator 一键构建脚本（macOS）
# ============================================================
# 功能：
#   1. 用 xcodegen 把 project.yml 生成为 .xcodeproj
#   2. 用 xcodebuild 编译 + archive
#   3. 导出 .ipa（Development 模式，可直接安装到任意 iPhone）
#   4. 同步输出 .app 和 .dSYM
#
# 用法：
#   ./Scripts/build.sh            # 默认 Release 模式
#   ./Scripts/build.sh --debug    # Debug 模式
#   ./Scripts/build.sh --team ABC123XYZ   # 指定 Team ID
# ============================================================

set -e

# ====== 参数解析 ======
CONFIG="Release"
TEAM_ID="${DEVELOPER_TEAM_ID:-}"

while [[ $# -gt 0 ]]; do
  case $1 in
    --debug)
      CONFIG="Debug"
      shift
      ;;
    --team)
      TEAM_ID="$2"
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      echo "用法: $0 [--debug] [--team <TEAM_ID>]"
      exit 1
      ;;
  esac
done

# ====== 路径定位 ======
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT="$(dirname "$SCRIPT_DIR")"

cd "$ROOT"

# ====== 工具检查 ======
require() {
  local cmd=$1
  local hint=${2:-}
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ 缺少工具: $cmd"
    echo "   安装: ${hint}"
    echo ""
    echo "本 macOS 环境必须安装:"
    echo "   - Xcode (App Store)"
    echo "   - Xcode Command Line Tools: xcode-select --install"
    echo "   - xcodegen: brew install xcodegen"
    echo "   - fastlane (可选): gem install fastlane"
    exit 1
  fi
}

require xcodebuild
require xcodegen "brew install xcodegen"
require xcrun

# ====== Team ID ======
if [ -z "$TEAM_ID" ]; then
  echo "⚠️  未提供 Team ID，尝试从 Keychain 自动检测..."
  TEAM_ID=$(security find-identity -v -p codesigning 2>/dev/null | grep "Apple Development" | head -1 | awk '{print $NF}' | tr -d '()"' || true)
  if [ -z "$TEAM_ID" ]; then
    echo "❌ 无法自动检测 Team ID"
    echo "   请通过环境变量或参数指定："
    echo "     export DEVELOPER_TEAM_ID=ABC123XYZ"
    echo "   或者："
    echo "     $0 --team ABC123XYZ"
    echo ""
    echo "   Team ID 可以在 https://developer.apple.com/account 查看"
    exit 1
  fi
fi
echo "✅ Team ID: $TEAM_ID"

# ====== 清理 ======
echo "🧹 清理构建产物..."
rm -rf build/
rm -rf *.xcodeproj

# ====== 生成 Xcode 工程 ======
echo "📦 生成 Xcode 工程 (xcodegen)..."
xcodegen generate

# ====== 注入 Team ID ======
if [ -n "$TEAM_ID" ]; then
  echo "🔐 注入 Team ID 到工程..."
  /usr/libexec/PlistBuddy -c "Print" project.pbxproj >/dev/null 2>&1 || true
  # 用 sed 替换 DEVELOPMENT_TEAM 空值
  sed -i '' "s/DEVELOPMENT_TEAM = \"\";/DEVELOPMENT_TEAM = \"$TEAM_ID\";/g" "$ROOT/Calculator.xcodeproj/project.pbxproj" 2>/dev/null || true
fi

# ====== Archive ======
ARCHIVE_PATH="$ROOT/build/Calculator.xcarchive"
echo "🏗️  Archive ($CONFIG)..."
xcodebuild \
  -project Calculator.xcodeproj \
  -scheme Calculator \
  -configuration "$CONFIG" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Automatic \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean archive

# ====== 检查产物 ======
if [ ! -d "$ARCHIVE_PATH" ]; then
  echo "❌ Archive 失败：未生成 .xcarchive"
  exit 1
fi

APP_PATH=$(find "$ARCHIVE_PATH/Products/Applications" -name "*.app" -maxdepth 2 -type d | head -1)
if [ -z "$APP_PATH" ]; then
  echo "❌ 未找到 .app 产物"
  exit 1
fi

echo "✅ .app: $APP_PATH"

# ====== 复制 .app 到 build 目录 ======
mkdir -p "$ROOT/build/app"
cp -R "$APP_PATH" "$ROOT/build/app/"
echo "✅ .app 已复制到: $ROOT/build/app/$(basename "$APP_PATH")"

# ====== 导出 IPA ======
IPA_PATH="$ROOT/build/Calculator.ipa"
echo "📲 导出 IPA..."
mkdir -p "$ROOT/build/ExportOptions"

cat > "$ROOT/build/ExportOptions/Development.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>destination</key>
    <string>export</string>
    <key>compileBitcode</key>
    <false/>
    <key>embedSymbols</key>
    <true/>
</dict>
</plist>
EOF

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$ROOT/build/ExportOptions/Development.plist" \
  -exportPath "$ROOT/build" \
  -allowProvisioningUpdates 2>&1 | tail -20

if [ -f "$IPA_PATH" ]; then
  echo ""
  echo "=========================================="
  echo "✅ 构建成功！"
  echo "   📱 IPA: $IPA_PATH"
  echo "   📦 Size: $(du -h "$IPA_PATH" | cut -f1)"
  echo ""
  echo "下一步 — 安装到你的 iPhone："
  echo "   1. iPhone 连上 Mac"
  echo "   2. 打开 Xcode → Window → Devices and Simulators"
  echo "   3. 选中设备 → 点 + → 选 IPA"
  echo "   或者："
  echo "      xcrun devicectl device install app --device <UDID> $IPA_PATH"
  echo ""
  echo "或使用 AltStore / Sideloadly 无线安装："
  echo "   https://altstore.io"
  echo "   https://sideloadly.io"
  echo "=========================================="
else
  echo ""
  echo "⚠️  IPA 未生成（可能因未配置 Provisioning）"
  echo "✅ 但 .app 已就绪：$ROOT/build/app/$(basename "$APP_PATH")"
  echo ""
  echo "可用 Xcode 直接安装（自动签名）："
  echo "   open Calculator.xcodeproj"
  echo "   Product → Run（⌘R）"
  exit 0
fi
