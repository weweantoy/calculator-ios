#!/usr/bin/env bash
# ============================================================
# push_to_github.sh — 推送工程到 GitHub 并触发 Actions 构建
# ============================================================
#
# 用法：
#   ./Scripts/push_to_github.sh <GITHUB_PAT> [REPO_NAME]
#
# 参数：
#   GITHUB_PAT   Personal Access Token（必须；GitHub 自 2021 年起禁用密码推送）
#   REPO_NAME    仓库名，默认 calculator-ios
#
# 工作流程：
#   1. 用 PAT 调用 GitHub API 创建仓库（如已存在则跳过）
#   2. 添加 remote origin
#   3. git push -u origin main
#   4. 等待 Actions 触发 + 完成
#   5. 下载 Calculator.ipa artifact
#
# 注意事项：
#   - PAT 不会写入任何文件，仅作为环境变量使用
#   - 推送成功后会清空历史以防误用
# ============================================================

set -euo pipefail

PAT="${1:-}"
REPO="${2:-calculator-ios}"
USER_NAME="shenmdushifuyun"  # GitHub 用户名（不含 @gmail.com 后缀）

if [ -z "$PAT" ]; then
    echo "❌ 错误：必须提供 GitHub Personal Access Token 作为第一个参数。"
    echo "用法：$0 <GITHUB_PAT> [REPO_NAME]"
    echo ""
    echo "PAT 获取路径："
    echo "  https://github.com/settings/personal-access-tokens/new"
    exit 1
fi

REPO_DESCRIPTION="iOS 计算器 APP — SwiftUI 原生 + watchOS 配套 + Widget Extension"

echo "==> 1. 检查仓库是否已存在"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${USER_NAME}/${REPO}")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✓ 仓库 ${USER_NAME}/${REPO} 已存在，跳过创建"
elif [ "$HTTP_STATUS" = "404" ]; then
    echo "==> 仓库不存在，正在创建"
    CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: token $PAT" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/user/repos" \
        -d "{
            \"name\": \"${REPO}\",
            \"description\": \"${REPO_DESCRIPTION}\",
            \"private\": false,
            \"auto_init\": false
        }")
    CREATE_STATUS=$(echo "$CREATE_RESPONSE" | tail -1)
    if [ "$CREATE_STATUS" != "201" ]; then
        echo "❌ 创建仓库失败：HTTP $CREATE_STATUS"
        echo "$CREATE_RESPONSE" | head -n -1
        exit 1
    fi
    echo "✓ 仓库创建成功"
else
    echo "❌ 未知错误：HTTP $HTTP_STATUS"
    exit 1
fi

echo "==> 2. 配置 remote origin"
REMOTE_URL="https://${PAT}@github.com/${USER_NAME}/${REPO}.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"

echo "==> 3. 推送到 main 分支"
git push -u origin main 2>&1 | tail -10

# 推送完成后，清除 remote URL 中的 PAT（避免泄露到 git 历史）
git remote set-url origin "https://github.com/${USER_NAME}/${REPO}.git"

echo ""
echo "✓ 推送完成"
echo ""
echo "==> 4. 触发 GitHub Actions workflow"
WORKFLOW_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: token $PAT" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${USER_NAME}/${REPO}/actions/workflows/build.yml/dispatches" \
    -d "{\"ref\": \"main\"}")
WORKFLOW_STATUS=$(echo "$WORKFLOW_RESPONSE" | tail -1)
if [ "$WORKFLOW_STATUS" = "204" ]; then
    echo "✓ Workflow 触发成功"
else
    echo "⚠ Workflow 触发返回 HTTP $WORKFLOW_STATUS（可能是 git push 已自动触发）"
fi

echo ""
echo "==> 5. 等待 Actions 完成（约 5-10 分钟）"
echo "监控 URL: https://github.com/${USER_NAME}/${REPO}/actions"
echo ""

# 轮询 workflow 状态
for i in {1..30}; do
    sleep 30
    RUN_DATA=$(curl -s \
        -H "Authorization: token $PAT" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${USER_NAME}/${REPO}/actions/runs?per_page=1")
    STATUS=$(echo "$RUN_DATA" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    CONCLUSION=$(echo "$RUN_DATA" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "[$i/30] status=$STATUS conclusion=$CONCLUSION"
    if [ "$STATUS" = "completed" ]; then
        break
    fi
done

if [ "${CONclusion:-}" = "success" ]; then
    echo ""
    echo "✓ Actions 构建成功！"
    echo ""
    echo "==> 6. 下载 Calculator-IPA artifact"
    ARTIFACT_URL=$(curl -s \
        -H "Authorization: token $PAT" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/${USER_NAME}/${REPO}/actions/runs?per_page=1" | \
        grep -o '"archive_download_url":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$ARTIFACT_URL" ]; then
        mkdir -p build
        curl -s -L \
            -H "Authorization: token $PAT" \
            -o build/Calculator-IPA.zip \
            "$ARTIFACT_URL"
        echo "✓ 已下载到：build/Calculator-IPA.zip"

        cd build && unzip -o Calculator-IPA.zip && cd ..
        echo "✓ 已解压：build/Calculator.ipa"
        echo ""
        echo "============================================================"
        echo "  🎉 完成！"
        echo "============================================================"
        echo "产物：build/Calculator.ipa"
        echo ""
        echo "下一步：在 iPhone 上安装"
        echo "  1. 下载 Sideloadly：https://sideloadly.io"
        echo "  2. 用 USB 连 iPhone"
        echo "  3. 把 Calculator.ipa 拖入 Sideloadly"
        echo "  4. 输入 Apple ID → Start"
        echo "  5. iPhone → 设置 → 通用 → VPN 与设备管理 → 信任证书"
        echo ""
    fi
elif [ "${CONCLUSION:-}" = "failure" ]; then
    echo "❌ Actions 构建失败，请查看："
    echo "   https://github.com/${USER_NAME}/${REPO}/actions"
    exit 1
else
    echo "⚠ Actions 仍在运行或超时，最长等待 15 分钟"
    echo "   可手动查看：https://github.com/${USER_NAME}/${REPO}/actions"
fi
