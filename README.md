# Magic Trackpad for Windows

面向 Windows 11 的 Apple Magic Trackpad 安装、状态检测与安全管理包装项目。

项目不重写上游触摸板驱动，而是基于
[`vitoplantamura/MagicTrackpad2ForWindows`](https://github.com/vitoplantamura/MagicTrackpad2ForWindows)
提供的 Microsoft 签名驱动，补充更适合普通用户的安装、检测、诊断和后续卸载体验。

## 当前基线

**版本：`v0.1.0-dev.5.1`**

当前已经完成：

- Windows 11 x64 C++ 状态探针；
- A3120 USB-C / Bluetooth 状态识别；
- Bluetooth `paired / remembered / connected` 真实在线状态区分；
- Precision Touchpad 驱动链识别；
- Driver Store 中 `AmtPtpDevice.inf` 的精确识别；
- 当前驱动重复安装 NO-OP / 幂等验证；
- 官方 v2.0 Release ZIP 固定 SHA256、文件布局、版本与签名校验；
- Inno Setup x64 简体中文安装器；
- 控制面板、Windows 触摸板设置与开始菜单快捷方式；
- 安装结束自动打开需要管理员权限的上游控制面板。

## 已完成真实硬件验证

真实 A3120 Magic Trackpad 已验证：

- USB-C Precision Touchpad；
- Bluetooth Precision Touchpad；
- Windows 双指、三指、四指原生手势；
- Haptic 点击反馈；
- Bluetooth 电量读取；
- 蓝牙开机在线与关机离线状态；
- USB-C 插入后的连接状态切换；
- 当前版安装器重复运行不会重复写入 Driver Store；
- 安装前后 Published INF 保持同一 `oem*.inf`；
- 简体中文安装向导；
- 控制面板与 Windows 触摸板设置快捷方式。

详细状态见：

- `docs/DEVELOPMENT_HISTORY.md`
- `docs/VALIDATION_BASELINE.md`

## 尚未完成的关键验收

当前安装器还**没有**完成一台干净 Windows 11 x64 系统上的真实首次安装验证。

下一项核心验收为：

1. 准备干净 Windows 11 x64 虚拟机；
2. 创建 Clean 快照；
3. 确认安装前 `driver-status -> not-installed`；
4. 双击 `Setup.exe`；
5. 确认驱动包进入 Driver Store；
6. 确认安装后 `driver-status -> current`；
7. 再次运行 Setup，确认走 NO-OP；
8. 恢复快照并重复必要的失败/恢复测试。

没有真实 Magic Trackpad 直通虚拟机也可以完成这一阶段，因为这一轮验证的是
**Driver Store / Setup / 幂等安装链**，不是输入数据面。

## 构建环境

当前已验证开发环境：

- Visual Studio Community 2026 / MSVC x64
- Windows SDK 10.0.26100
- CMake 4.3.1
- Inno Setup 6.7.0

构建 C++ helper：

```powershell
Set-Location "D:\Dev\magic-trackpad-windows"
.\scripts\Build.ps1
```

构建安装器：

```powershell
.\scripts\Build-Installer.ps1
```

输出目录：

```text
out\installer\
```

`build/` 与 `out/` 均属于本地构建产物，不进入 Git。

## 上游驱动载荷

本项目不修改 Microsoft 签名的上游驱动文件。

当前固定上游 Release：

- Project: `vitoplantamura/MagicTrackpad2ForWindows`
- Release: `v2.0`
- Asset: `MT2FW11-20260223-MSSigned.zip`
- SHA256:
  `2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f`

本地 staging 目录：

```text
third_party\MagicTrackpad2ForWindows-v2.0\
```

该目录包含二进制载荷，已由 `.gitignore` 排除。

需要重新 staging 时：

```powershell
.\scripts\Prepare-DriverPayload.ps1 `
    -SourceZip "D:\IDM\Compressed\MT2FW11-20260223-MSSigned.zip"

.\scripts\Verify-DriverPayload.ps1
```

## 当前安全边界

当前版本明确**不会**：

- 自动清理多个历史驱动包；
- 静默升级旧版驱动；
- 静默降级较新的驱动；
- 自动卸载驱动；
- 删除其他 Apple / iPhone / Boot Camp 驱动；
- 修改 A3120 的 `MI_00` 接口；
- 自动配对 Bluetooth；
- 修改 Windows 三指/四指手势；
- 修改上游 Microsoft 签名驱动；
- 自动支持尚未真机验证的 ARM64 安装。

当前卸载程序只移除：

- 控制面板；
- 文档；
- 开始菜单快捷方式；
- 安装器自身文件。

驱动暂时保留。

## Git 基线

本项目最初以 A3120 驱动验证实验开始，在 `v0.1.0-dev.5.1` 已形成可用安装器后才正式初始化 Git。

因此：

- 不伪造 dev.1 ～ dev.5.1 的历史提交；
- 首个 Git commit 直接记录当前真实稳定基线；
- 早期演进过程记录在 `docs/DEVELOPMENT_HISTORY.md`；
- 后续所有开发均从正式 Git 历史继续。

建议首个提交：

```text
feat: 建立妙控板 Windows 安装器首个稳定基线
```

## License / Third-party

上游驱动采用 GPL-2.0。

当前第三方说明见：

`THIRD_PARTY_NOTICES.md`

在对外公开分发安装器前，还需要最终确认：

- GPL-2.0 许可证随包分发；
- 对应源码访问方式；
- 上游作者与项目来源说明；
- 外层 `Setup.exe` 的代码签名策略。

当前外层安装器尚未签名；内嵌上游驱动 CAT/SYS 仍保持 Microsoft 签名。
