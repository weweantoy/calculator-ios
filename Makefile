# ============================================================
# Calculator · Makefile
# ============================================================
# 一键快捷命令（macOS 终端运行）
#
# 常用：
#   make help         显示所有命令
#   make generate     生成 Xcode 工程
#   make test         运行单元测试
#   make build        构建并导出 IPA
#   make install      安装到已连接 iPhone
#   make run          在模拟器运行
#   make clean        清理构建产物
# ============================================================

SCHEME := Calculator
CONFIG := Release
TEAM_ID ?= $(DEVELOPER_TEAM_ID)

.PHONY: help
help: ## 显示帮助
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: install_tools
install_tools: ## 安装所需工具（xcodegen, fastlane）
	@command -v xcodegen >/dev/null || brew install xcodegen
	@command -v bundle >/dev/null || gem install bundler
	cd Fastlane && bundle install

.PHONY: generate
generate: ## xcodegen 生成 Xcode 工程
	xcodegen generate

.PHONY: open
open: generate ## 生成并在 Xcode 打开工程
	open Calculator.xcodeproj

.PHONY: test
test: ## 运行单元测试（SPM CalculatorCore）
	swift test

.PHONY: build
build: ## 构建并导出 IPA（需 Team ID）
	@if [ -z "$(TEAM_ID)" ]; then \
		echo "❌ 请设置 Team ID: make build TEAM_ID=ABC123XYZ"; \
		exit 1; \
	fi
	chmod +x Scripts/build.sh
	./Scripts/build.sh --team $(TEAM_ID)

.PHONY: run
run: generate ## 在 iPhone 模拟器运行
	xcodebuild -project Calculator.xcodeproj \
		-scheme $(SCHEME) \
		-configuration Debug \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		build
	open -a Simulator

.PHONY: install
install: build ## 安装到连接的 iPhone
	@./Scripts/install_device.sh $(DEVICE_UDID)

.PHONY: clean
clean: ## 清理构建产物
	rm -rf build/
	rm -rf *.xcodeproj
	rm -rf .build/
	rm -rf DerivedData/

.PHONY: lint
lint: ## 检查 Swift 代码风格
	@command -v swiftlint >/dev/null || brew install swiftlint
	swiftlint Sources App --quiet

.PHONY: archive
archive: generate ## 生成 Xcode Archive
	xcodebuild \
		-project Calculator.xcodeproj \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-destination "generic/platform=iOS" \
		-archivePath build/$(SCHEME).xcarchive \
		archive

.PHONY: icons
icons: ## 提示生成 AppIcon（需准备 1024×1024 PNG）
	@echo ""
	@echo "1. 设计 1024×1024 PNG (无透明度、无圆角)"
	@echo "2. 访问 https://appicon.co 上传，自动生成 18 种尺寸"
	@echo "3. 解压并复制到 App/Resources/Assets.xcassets/AppIcon.appiconset/"
	@echo ""

.PHONY: fastlane_test
fastlane_test: ## 通过 fastlane 上传 TestFlight
	cd Fastlane && bundle exec fastlane ios beta
