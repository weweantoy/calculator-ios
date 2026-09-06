# UI 测试说明

本目录包含 XCUITest 自动化测试，目标覆盖计算器所有功能场景。

## 文件清单

| 文件 | 用途 |
|-----|------|
| `CalculatorUITests.swift` | 功能测试（17+ 用例）|
| `CalculatorUITestsLaunchTests.swift` | 启动性能与冒烟测试 |

## 测试覆盖矩阵

### 基础运算
- 加法（含大数与负结果）
- 减法
- 乘法
- 除法
- 运算符优先级
- 小数加法（`0.1 + 0.2 = 0.3`）

### 编辑与清空
- 删除（Backspace）
- 全部清除（AC）
- 正负号切换（± 往返）
- 百分号（%）

### 错误处理
- 除零 → 错误提示

### 模式切换
- 基础 ⇄ 科学模式

### 科学函数
- sin(30°) = 0.5
- cos(60°) = 0.5
- √16 = 4
- π 常量

### 历史记录
- 面板打开
- 历史项持久化

### 长流程场景
- 复杂表达式 `(1+2)*(3+4) = 21`
- 连续多次计算
- 快速点击性能基线

## 运行测试

### 在 Xcode 中

1. 打开工程
2. 选中 `CalculatorUITests` scheme（或 target）
3. `Cmd + U` 运行所有测试
4. 或在测试导航器中右键单个测试 → `Run`

### 命令行

```bash
xcodebuild test \
  -project CalculatorApp.xcodeproj \
  -scheme CalculatorApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

## 控件定位策略

所有可交互控件均设置了 `accessibilityIdentifier`，XCUITest 通过稳定 ID 定位：

| 类型 | 标识符格式 | 示例 |
|-----|----------|------|
| 数字键 | `key_digit_<0-9>` | `key_digit_7` |
| 运算符 | `key_<op>` | `key_plus`, `key_minus` |
| 函数键 | `key_<name>` | `key_sin`, `key_cos` |
| 修饰键 | `key_<name>` | `key_ac`, `key_delete`, `key_percent` |
| 常量 | `key_<name>` | `key_pi`, `key_e` |
| 显示区 | `display_<type>` | `display_result`, `display_expression`, `display_error` |

## 在代码中如何添加新测试

```swift
func testMyNewFeature() {
    // 准备
    clear()
    
    // 输入
    input("42")
    press("key_plus")
    input("8")
    press("key_equals")
    
    // 断言
    XCTAssertEqual(currentResult(), "50")
}
```

### 工具方法

`CalculatorUITests` 提供了以下辅助方法：

- `clear()` - 点 AC
- `input(_:)` - 输入多位数字
- `press(_:)` - 点指定 identifier 的按钮
- `currentResult()` - 读取主显示
- `currentExpression()` - 读取表达式回显

## 调试技巧

### 查看控件树

```swift
print(app.debugDescription)
```

或在测试中断点后，在 lldb 中：

```
po app.debugDescription
```

### 等待控件出现

```swift
let exists = app.buttons["key_sin"].waitForExistence(timeout: 5)
```

### 慢速运行（观察 UI）

`Edit Scheme → Test → Options → Debug Process: Slow Animations`

## 持续集成

将以下命令加入 CI 流水线：

```yaml
- name: Run UI Tests
  run: |
    xcodebuild test \
      -project CalculatorApp.xcodeproj \
      -scheme CalculatorApp \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -resultBundlePath ./build/TestResults \
      | xcpretty
```

### GitHub Actions 示例

```yaml
name: UI Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          xcodebuild test \
            -project CalculatorApp.xcodeproj \
            -scheme CalculatorApp \
            -destination 'platform=iOS Simulator,name=iPhone 15'
```