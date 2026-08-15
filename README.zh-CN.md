# Magic Trackpad for Windows

[English](README.md)

一个面向 Windows 11 的 Apple Magic Trackpad 安装、诊断与生命周期管理项目。
项目基于
[MagicTrackpad2ForWindows](https://github.com/vitoplantamura/MagicTrackpad2ForWindows)
提供的 Microsoft 签名 Precision Touchpad 驱动。

本项目**不会重写或重新签名上游驱动**。重点是让普通 Windows 用户获得更安全、
可解释的安装、精确 Driver Store 识别、隐私友好的诊断，以及可预测的卸载/重装体验。

> **开发状态**
>
> 当前已验证基线：`v0.1.0-dev.5.4.2`。
>
> 本仓库暂未发布公开二进制 Release。外层 `Setup.exe` 当前尚未代码签名；安装器
> 内嵌的上游驱动仍保持原始 Microsoft 签名。公开分发所需的许可证/源码分发闭环
> 正在 OSS 产品化阶段完成。

## 界面截图

| 安装说明 | 安装位置 |
| --- | --- |
| ![简体中文安装说明页](docs/assets/screenshots/installer-information-zh-cn.png) | ![简体中文安装位置页](docs/assets/screenshots/installer-destination-zh-cn.png) |

实体设备正在连接时的失败即保留保护：

![Magic Trackpad 正在连接时阻止删除驱动](docs/assets/screenshots/uninstall-connected-guard-zh-cn.png)

简体中文 Windows UI 会自动使用简体中文安装器；其他暂未支持的 Windows UI
语言自动回退 English，不弹额外语言选择框。

## 本项目增加了什么

真正的 Precision Touchpad 功能由上游驱动提供。本仓库主要补齐外围产品生命周期：

- Windows 11 风格的中英文安装器；
- 精确识别目标 Driver Store 包，不用模糊的“Apple”关键字删除驱动；
- 当前目标驱动已是最新版时走幂等 NO-OP；
- 固定上游 Release、SHA256 和签名校验；
- 小型 C++ helper，用于设备/驱动状态判断；
- Bluetooth `remembered / paired / connected` 真实状态识别；
- 默认脱敏的诊断报告；
- 控制面板、Windows 触摸板设置、诊断、日志、卸载等开始菜单入口；
- 仅卸载程序并保留驱动的安全默认分支；
- 可选的真实驱动移除：删除前导出备份、核对备份、不用 `/force`、删除后再核验；
- Magic Trackpad 正在连接时，在破坏性动作之前阻止驱动移除。

## 已验证支持范围

下面只写**本包装项目真实验证过**的范围，不把上游可能支持的配置自动算成我们的
正式支持范围。

| 项目 | 本项目已验证基线 |
| --- | --- |
| 操作系统 | Windows 11 x64 |
| 硬件 | Apple USB-C Magic Trackpad A3120 |
| USB | 已验证 |
| Bluetooth | 已验证 |
| Windows Precision Touchpad | 已验证 |
| 电量读取 | 已验证 |
| Haptic 点击反馈 | 已验证 |
| Windows 原生双指/三指/四指手势 | 已验证 |
| ARM64 包装/安装生命周期 | **尚未真机验证** |
| Windows 10 包装/安装生命周期 | **本项目暂不声明支持** |

固定的上游包本身包含其他架构内容，上游也可能支持更多配置；只有本项目在相应
真实硬件/系统上完成验证后，才会升级为“本项目已验证支持”。

## 安装

当前尚未发布公开 Release。开发基线请按
[从源码构建](#从源码构建)生成安装器。

普通用户流程：

1. 运行 `MagicTrackpad-for-Windows-Setup-<version>-x64.exe`；
2. 阅读安装说明；
3. 自行选择安装位置；
4. 点击**安装**；
5. 通过 Windows 正常配对/连接 Magic Trackpad；
6. 在 **Windows 触摸板设置** 中配置手势。

如果系统中已经只有一个精确匹配且版本正确的目标驱动，Setup 会走 NO-OP，
不会重复往 Driver Store 添加同一个驱动包。

## 卸载

交互式卸载器提供两个选择。

### 仅卸载程序并保留驱动

这是默认/推荐选项。

会移除程序、工具、文档和快捷方式，但保留 Magic Trackpad 驱动。

静默卸载也固定为非破坏模式，默认保留驱动。

### 同时卸载程序和 Magic Trackpad 驱动

真实安全删除链：

1. 精确识别唯一匹配的目标驱动；
2. 核验 Original INF、Provider、版本；
3. 检查 Magic Trackpad 当前设备状态；
4. 先把精确目标驱动导出到带时间戳的备份目录；
5. 验证 INF/CAT/DLL/SYS 四类预期文件都存在；
6. 不使用 `/force`，调用 PnPUtil 删除；
7. 删除后再次查询 Driver Store，必须得到 `not-installed`。

如果 Magic Trackpad 当前通过 USB 或 Bluetooth 正在连接，驱动删除会在备份/
删除之前被阻止。用户可以断开设备后重试，也可以只卸载程序并保留驱动。

卸载器不会模糊搜索或删除其他 Apple、iPhone、Apple Mobile Device 或 Boot Camp
驱动。

## 安全模型

这些规则属于产品契约，不是“尽量做到”：

- `oemN.inf` 始终动态识别，绝不硬编码；
- 只有精确匹配的目标驱动可以进入安装/删除链；
- 不会静默降级更高版本驱动；
- 多个匹配包/歧义状态直接 fail-closed，要求人工检查；
- 上游 Microsoft 签名驱动按原始字节部署；
- 真正删除前必须先成功备份；
- 正常删除链禁止 `/force`；
- 实体设备正在连接时禁止破坏性删除；
- 删除后必须确认 Driver Store 状态为 `not-installed`；
- 不自动修改 A3120 的 `MI_00` 接口作为 workaround；
- 不静默修改 Bluetooth 配对状态或 Windows 手势偏好。

详细验证证据见 [docs/README.md](docs/README.md)。

## 诊断与隐私

开始菜单提供**生成诊断报告**。

默认生成的 `Diagnostics-*.txt` 会主动脱敏：

- 计算机名/用户名；
- Bluetooth 地址；
- 机器相关 PnP instance 尾段；

同时保留排障需要的稳定硬件和驱动状态。

`Install-*.log`、`DriverRemoval-*.log`、`UninstallDecision-*.log` 等原始技术日志
可能包含本机信息，公开提交前应检查并脱敏。

见 [运行日志分享策略](docs/RUNTIME_LOG_SHARING_POLICY.md)。

## 从源码构建

### 已验证开发环境

- Visual Studio Community 2026 / MSVC x64
- Windows SDK 10.0.26100
- CMake 4.3.1（项目最低 3.25）
- Inno Setup 6.7.0
- 开发脚本使用 PowerShell 7
- 安装到最终用户机器上的 runtime scripts 兼容 Windows PowerShell 5.1

### 1. 构建 helper

```powershell
Set-Location "D:\Dev\magic-trackpad-windows"
.\scripts\Build.ps1
```

### 2. 准备固定上游驱动载荷

当前固定：

- Project：`vitoplantamura/MagicTrackpad2ForWindows`
- Release：`v2.0`
- Asset：`MT2FW11-20260223-MSSigned.zip`
- SHA256：
  `2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f`

```powershell
.\scripts\Prepare-DriverPayload.ps1 `
    -SourceZip "C:\path\to\MT2FW11-20260223-MSSigned.zip"

.\scripts\Verify-DriverPayload.ps1
```

载荷会放到：

```text
third_party\MagicTrackpad2ForWindows-v2.0\
```

该二进制目录故意不进入 Git。

### 3. 构建安装器

```powershell
.\scripts\Build-Installer.ps1
```

输出：

```text
out\installer\
```

构建过程会再次执行载荷校验和当前静态安全门禁。

## 仓库结构

```text
helper/       C++ 设备/Driver Store helper
installer/    Inno Setup 安装器资源
scripts/      构建、验证、诊断和安全生命周期脚本
third_party/  固定上游载荷的元数据/准备说明
docs/         契约、验证证据、OSS 规划和开发历史
```

技术文档从 [docs/README.md](docs/README.md) 开始。

原始历史 Patch Notes 已保存在 `docs/history/patch-notes/`；它们用于追溯开发过程，
不是当前产品行为的最高优先级定义。

## 上游驱动与致谢

本包装项目依赖并重新分发以下项目的**未修改**构建：

- [vitoplantamura/MagicTrackpad2ForWindows](https://github.com/vitoplantamura/MagicTrackpad2ForWindows)
- 固定 Release：`v2.0`

上游公开说明其驱动为面向 Windows 11 的 Microsoft 签名 Precision Touchpad driver，
并提供 USB-C、Bluetooth、电量、Haptic 和控制面板支持。

该项目本身也继承/发展自
[imbushuo/mac-precision-touchpad](https://github.com/imbushuo/mac-precision-touchpad)。

不要把上游驱动实现和驱动签名工作归属于本包装项目。

## 许可证状态

固定的上游驱动项目包含 GNU General Public License version 2。

**本包装仓库自身**最终的顶层 license expression，以及公开二进制/源码配套分发方式，
仍在 OSS-1.3 中审核。在该阶段完成前，不应因为开发安装器已经可构建，就把仓库视为
已经达到公开 Release 的许可证收口状态。

参见：

- [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
- [许可证/重新分发审核清单](docs/oss/LICENSE_REVIEW_CHECKLIST.md)

## 贡献与安全

公开贡献/安全流程正在 OSS 产品化分支中建设。

目前贡献者和 coding agents 应优先阅读：

- [文档索引](docs/README.md)
- [OSS 安装器 UX 基线](docs/OSS_INSTALLER_UX_BASELINE.md)
- [用户安全卸载契约](docs/DEV5_4_2_USER_SAFE_UNINSTALL_CONTRACT.md)
- [用户安全卸载验证](docs/DEV5_4_2_USER_SAFE_UNINSTALL_VALIDATION.md)
- [仓库结构规则](docs/oss/REPOSITORY_STRUCTURE.md)

`CONTRIBUTING.md`、`SECURITY.md`、Issue/PR 模板和 CI 会在后续 OSS 阶段加入。

## 独立项目说明

Magic Trackpad for Windows 是独立社区项目，与 Apple Inc. 或 Microsoft
Corporation 无隶属、授权或背书关系。
