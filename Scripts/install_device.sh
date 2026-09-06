#!/usr/bin/env bash
# ============================================================
# Calculator 一键安装到 iPhone（macOS）
# ============================================================
# 用法：
#   ./Scripts/install_device.sh <DEVICE_UDID>
# ============================================================

set -e

DEVICE_UDID=${1:-}
ROOT="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd | xargs dirname )"
IPA="$ROOT/build/Calculator.ipa"

if [ -z "$DEVICE_UDID" ]; then
  echo "正在枚举已连接设备..."
  xcrun devicectl list devices 2>/dev/null | head -20
  echo ""
  echo "用法: $0 <DEVICE_UDID>"
  echo ""
  echo "DEVICE_UDID 可以从 Xcode → Window → Devices and Simulators 获取"
  echo "或运行："
  echo "  xcrun devicectl list devices"
  exit 1
fi

if [ ! -f "$IPA" ]; then
  echo "❌ 未找到 IPA: $IPA"
  echo "请先运行 ./Scripts/build.sh 构建"
  exit 1
fi

echo "📱 正在安装到设备 $DEVICE_UDID ..."
xcrun devicectl device install app \
  --device "$DEVICE_UDID" \
  "$IPA"

echo ""
echo "✅ 安装完成！"
echo "在 iPhone 上启动：设置 → 通用 → VPN 与设备管理 → 信任开发者证书"
echo ""
echo "提示：如果是首次安装，需要先信任开发者证书："
echo "   设置 → 通用 → VPN 与设备管理 → 开发者 APP → 信任"
