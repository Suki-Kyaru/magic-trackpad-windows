# 开发历史

本文件记录项目在正式建立 Git 仓库之前已经真实发生并验证过的开发过程。

这些阶段**不是后来补造的 Git commit**。项目直到 `v0.1.0-dev.5.1`
形成可用安装器以后才执行 `git init`，因此早期历史以文档形式保留。

---

## 起点：A3120 Windows 可用性验证

目标最初只是确认 Apple USB-C Magic Trackpad A3120 在 Windows 11 下是否可以获得：

- Precision Touchpad；
- 三指/四指原生手势；
- Haptic；
- Bluetooth；
- 电量读取。

真实设备最终验证成功。

上游驱动：

`vitoplantamura/MagicTrackpad2ForWindows v2.0`

真实设备 ID：

`PID_0324`

---

## dev.1 — A3120 PnP / Precision 状态探针

建立最小 C++ helper：

```text
MagicTrackpadHelper.exe status
```

初步识别：

- A3120；
- USB；
- Bluetooth PnP 节点；
- Precision Touchpad；
- 上游驱动 Provider；
- Published INF；
- Driver Version。

真实 Bluetooth 在线状态首次返回：

```text
bluetooth.present=true
bluetooth.precision=true
driver.bound=true
result=ready
ExitCode=0
```

### dev.1 实机发现

Magic Trackpad 关机后，Windows 仍保留 Bluetooth HID PnP 节点。

因此 `DIGCF_PRESENT` 不能代表远端 Bluetooth 设备当前真的在线。

---

## dev.2 — Bluetooth 真实连接状态

引入 Windows Bluetooth API：

- `fRemembered`
- `fAuthenticated`
- `fConnected`

状态模型扩展为：

```text
bluetooth.present
bluetooth.remembered
bluetooth.paired
bluetooth.connected
bluetooth.precision
```

新增：

```text
result=paired-not-connected
ExitCode=4
```

### dev.2 真机三态验证

Bluetooth 在线：

```text
bluetooth.connected=true
bluetooth.precision=true
result=ready
ExitCode=0
```

Bluetooth 已配对但妙控板关机：

```text
bluetooth.remembered=true
bluetooth.paired=true
bluetooth.connected=false
bluetooth.precision=true
result=paired-not-connected
ExitCode=4
```

USB-C 在线：

```text
usb.present=true
usb.precision=true
bluetooth.connected=false
result=ready
ExitCode=0
```

至此连接状态探针形成闭环。

---

## dev.3 — Driver Store 精确识别

新增：

```text
MagicTrackpadHelper.exe driver-status
```

不通过模糊搜索 `Apple` 判断驱动，而是精确核对：

```text
Original INF = AmtPtpDevice.inf
Catalog      = AmtPtpDevice.cat
Provider     = Bingxing Wang, Vito Plantamura
```

真实设备环境验证：

```text
driver.installed_count=1
driver.published_inf=oem116.inf
driver.current_version=2025.3980.1.1000
driver.state=current
result=current
ExitCode=0
```

注意：

`oem116.inf` 只是当前机器动态分配的 Published INF，任何正式逻辑都不得写死该编号。

---

## dev.4 — 安全安装门禁

开始设计第一次写操作。

安全状态规则：

- `current` → 成功 NO-OP；
- `not-installed` → 允许安装；
- `older` → 暂时阻断；
- `newer` → 阻断，禁止静默降级；
- `multiple-packages` → 阻断，禁止自动猜测/清理。

---

## dev.4.1 — PowerShell exit-code 热修

真实测试发现 PowerShell 函数把外部 helper 标准输出和
`$LASTEXITCODE` 一起写回 success stream，导致：

```text
$state
```

不是单一整数，而是“多行输出 + 0”。

修复后：

- 捕获 helper stdout；
- 立即捕获整数 `$LASTEXITCODE`；
- 用 `Write-Host` 重放诊断文本；
- 函数只返回整数状态码。

实体机验证：

```text
[PASS] Expected driver is already installed and current.
[NO-OP] No driver-store changes were made.
[PASS] Current-driver installation path is idempotent.
[PASS] Published INF remained unchanged: driver.published_inf=oem116.inf
```

---

## dev.4.2 — 官方 Release ZIP 布局兼容

官方 v2.0 ZIP SHA256 校验正确，但 ZIP 实际包含顶层包装目录：

```text
MT2FW11-20260223-MSSigned\
  AMD64\
  ARM64\
  AmtPtpControlPanel.exe
```

staging 脚本原先错误假设 `AMD64` 位于 ZIP 根目录。

修复后：

- 自动解析唯一合法 payload root；
- 支持 ZIP 根直出和包装目录；
- 多个合法候选根时直接阻断；
- 后续 INF / Provider / Version / CAT / SYS 签名检查不变。

真实官方 ZIP staging 通过：

```text
SHA256:
2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f

[PASS] Microsoft-signed upstream v2.0 payload staged.
[PASS] Driver payload hashes and signatures verified.
```

---

## dev.5 — 第一版 Inno Setup 安装器

首次生成真实：

```text
MagicTrackpad-for-Windows-Setup-0.1.0-dev.5-x64.exe
```

实现：

- Windows 11 x64 限制；
- 管理员权限；
- 安全驱动 gate；
- 当前版 NO-OP；
- 控制面板安装；
- README / Third-party Notice；
- 开始菜单快捷方式；
- 卸载器。

### dev.5 真机验证

安装前后：

```text
driver.installed_count=1
driver.published_inf=oem116.inf
driver.state=current
```

保持不变。

安装器文件与快捷方式正确落盘。

### dev.5 发现

安装完成页自动打开 `AmtPtpControlPanel.exe` 时出现：

```text
ShellExec failed; code 740
The requested operation requires elevation.
```

同时安装向导框架仍是英文。

---

## dev.5.1 — 简体中文向导 + 控制面板 UAC 热修

确认上游 `AmtPtpControlPanel.exe` manifest 使用：

```text
requestedExecutionLevel = requireAdministrator
```

Inno Setup 完成页改为继承 Setup 已提升凭据启动控制面板。

同时加载本机：

```text
Inno Setup 6\Languages\ChineseSimplified.isl
```

并保留关键中文消息覆盖。

### dev.5.1 实机验收

全部通过：

- 简体中文向导；
- Setup UAC；
- 当前驱动 NO-OP；
- 控制面板落盘；
- 控制面板完成页自动启动；
- 开始菜单控制面板入口；
- Windows 触摸板设置入口；
- 卸载入口；
- Driver Store 仍只有一个匹配包；
- Published INF 仍为 `oem116.inf`；
- 当前驱动版本仍为 `2025.3980.1.1000`。

`v0.1.0-dev.5.1` 因此被选为：

**项目正式初始化 Git 时的首个稳定源码基线。**

---

## 下一阶段

下一核心验证不再继续修改已稳定的真实设备驱动链。

优先进行：

1. 干净 Windows 11 x64 虚拟机；
2. 创建 Clean snapshot；
3. 安装前 `driver-status -> not-installed`；
4. 双击 dev.5.1 Setup；
5. 验证 `not-installed -> current`；
6. 重复运行 Setup 验证 NO-OP；
7. 恢复 snapshot；
8. 后续加入安装/诊断日志；
9. 设计安全卸载 dry-run；
10. 最后才开放真实驱动卸载。

现代中文控制面板、ARM64、自动升级与其他产品化工作均后置。
