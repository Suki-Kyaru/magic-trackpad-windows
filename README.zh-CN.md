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
> 当前源码版本：`v0.1.0`。
>
> 当前公开预发行版：[`v0.1.0-dev.6.0`](https://github.com/Suki-Kyaru/magic-trackpad-windows/releases/tag/v0.1.0-dev.6.0)。
>
> 已发布二进制 ZIP 内 Final Setup SHA256：
> `f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791`。
>
> 上一个冻结并完成验收的二进制基线：`v0.1.0-dev.5.4.2`。
>
> 冻结的稳定版候选：`v0.1.0-rc.2`。
> rc.2 Setup SHA256：`e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40`。
> rc.2 源码提交：`b54ac7311b1a6e0736e91c2cac248fffcc485e04`。
> rc.2 源码 tree：`4f8ba3444993c601e41bf71c4f82e78629711d6c`。
> 完整验收证据：[`docs/RC2_FINAL_VALIDATION.md`](docs/RC2_FINAL_VALIDATION.md)。
>
> `v0.1.0-dev.6.0` 已完成受控发布回归并正式冻结。外层 `Setup.exe` 当前仍未
> 代码签名，内嵌上游驱动继续保持原始 Microsoft 签名。当前 `v0.1.0` 源码属于
> 最终稳定版源码；`v0.1.0` 公开稳定版二进制尚未发布。

## 界面截图

以下截图已使用 dev.6.0 预发布候选界面重新采集。

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
| Windows 10 包装/安装生命周期 | **当前 `v0.1.0` 版本线不支持；`v0.1.0-rc.1` 已在 Windows 10 x64 build 19044 上完成 A3120 失败验证** |

Windows 10 x64 build 19044 已使用 `v0.1.0-rc.1` 完成真机验证。Windows 能够选择
固定的 Microsoft 签名 A3120 `MI_01` 驱动，但其 UMDF function-driver 路径无法
完成配置，因此当前 `v0.1.0` 版本线继续仅支持 Windows 11 x64。

固定的上游包本身包含其他架构内容，上游也可能支持更多配置；只有本项目在相应
真实硬件/系统上完成验证后，才会升级为“本项目已验证支持”。

## 安装

当前公开二进制预发行版为 `v0.1.0-dev.6.0`。应从 GitHub Release 使用受控二进制
ZIP，不应把裸 `Setup.exe` 作为独立公开发布单元。

`v0.1.0-dev.6.0` 已成为冻结的公开发布身份，绝不能从 tag 之后的源码重新构建或
重新发布同版本二进制。`v0.1.0-dev.5.4.2` 继续作为上一个冻结并完成验收的二进制
基线。`v0.1.0-rc.2` 已成为冻结并完成验收的稳定版候选，完整证据见
[rc.2 最终验收记录](docs/RC2_FINAL_VALIDATION.md)。当前 `v0.1.0` 是最终稳定版源码，仍需完成一次受控的最终构建与公开发布。

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

在仓库根目录运行：

```powershell
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

### 3. 构建受控发布资产

冻结的 `v0.1.0-dev.5.4.2` 不允许从 tag 之后的源码重新构建。它已经验收的 Setup
SHA256 为：

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

当前源码为 `0.1.0`，根目录 `VERSION` 与 `installer/setup.iss` 中的
`#define MyAppVersion` 已保持一致。应在干净、已提交的源码状态下构建最终受控发布资产：

```powershell
.\scripts\Build-ReleaseBundle.ps1
```

输出：

```text
out\release\MagicTrackpad-for-Windows-0.1.0\
```

`Build-Installer.ps1` 会对已经冻结的 `0.1.0-dev.5.4.2`、`0.1.0-dev.6.0`
和 `0.1.0-rc.1` 主动阻断。冻结的 `0.1.0-rc.2` 也会被阻断；当前 `0.1.0` 只有在 VERSION/Inno 版本一致时
才允许构建；真正编译前仍会重新执行驱动载荷、安装器、卸载和许可证分发门禁。

`Build-ReleaseBundle.ps1` 会在同一次发布构建中内部调用 `Build-Installer.ps1`。
最终稳定版不要先单独预构建另一份同版本 Setup，再运行 Release Bundle。
如果 Release Bundle 在 Setup 已生成后失败，应保留这份 Setup，并按
[Release 合规流程](docs/oss/RELEASE_COMPLIANCE.md)使用其精确 SHA256 恢复；
不要为了重试而删除 Setup 并重新构建同一个版本。

正式发布资产应使用
[Release 合规流程](docs/oss/RELEASE_COMPLIANCE.md)，不要直接上传裸 `Setup.exe`。

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

本项目原创 wrapper 代码和原创文档使用 **MIT License**（`SPDX: MIT`）：

- [LICENSE](LICENSE)

固定的 `vitoplantamura/MagicTrackpad2ForWindows` 驱动/控制面板载荷仍是第三方
软件，继续遵循其上游 **GPLv2** 条款，**不会**被本项目重新许可为 MIT。

重新分发材料明确分开：

- [第三方说明](THIRD_PARTY_NOTICES.md)
- [GNU GPL version 2 文本](licenses/GPL-2.0.txt)
- [上游源码与构建溯源](docs/oss/UPSTREAM_SOURCE_PROVENANCE.md)
- [Release 合规流程](docs/oss/RELEASE_COMPLIANCE.md)

公开二进制采用包含 MIT/GPL/第三方说明/溯源材料的受控二进制包，并在同一
Release 位置提供精确上游对应源码包和构建 workflow 快照。

`v0.1.0-dev.6.0` 已按这套流程成为本仓库首个公开二进制预发行版；最终 Release
目录、对应源码、workflow 快照、溯源和 SHA256 材料均在公开前一起完成核验。

## 贡献、支持与安全

贡献/反馈/安全报告流程现已建立：

- [贡献指南](CONTRIBUTING.md)
- [支持与问题反馈](SUPPORT.md)
- [安全策略](SECURITY.md)
- [Coding Agent 仓库导航](AGENTS.md)
- [贡献者工作流与验证矩阵](docs/oss/CONTRIBUTOR_WORKFLOW.md)

GitHub Issue 表单和 Pull Request 模板位于 `.github/`。

`.github/workflows/ci.yml` 已定义非破坏性的 GitHub Actions CI：自动运行仓库/
许可证/贡献者契约、Windows PowerShell 5.1 兼容性、安装器静态安全检查，并编译
C++ helper。该工作流已经在 GitHub-hosted Windows runner 上实际成功运行；本地
复现仍继续作为维护者验证的一部分。

## 独立项目说明

Magic Trackpad for Windows 是独立社区项目，与 Apple Inc. 或 Microsoft
Corporation 无隶属、授权或背书关系。
