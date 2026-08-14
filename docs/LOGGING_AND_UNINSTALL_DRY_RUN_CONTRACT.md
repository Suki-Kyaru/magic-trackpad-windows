# v0.1.0-dev.5.2 日志与安全卸载 Dry-run 契约

## 目标

本阶段只增加：

1. 持久安装日志；
2. 一键诊断报告；
3. 驱动卸载目标 dry-run；
4. Git 行尾规范。

本阶段**不执行驱动卸载**。

## 持久安装日志

`installer/Run-SafeInstall.ps1` 会优先写入：

```text
C:\ProgramData\Magic Trackpad for Windows\Logs\
```

文件名：

```text
Install-YYYYMMDD-HHMMSS-PID.log
```

日志创建失败不会破坏原有安全安装逻辑。

Inno Setup 同时启用 `SetupLogging=yes`，保留安装器自身技术日志。

## 诊断报告

安装后开始菜单提供：

```text
生成诊断报告
打开诊断日志文件夹
```

诊断报告包含：

- Windows 版本；
- 架构；
- helper SHA256；
- driver-status；
- device status；
- 相关 PnP 设备。

诊断命令只读。

## 卸载 dry-run

命令：

```powershell
.\scripts\Get-UninstallPlan.ps1
```

在当前、单一、精确匹配的驱动包状态下，只输出：

```text
uninstall.mode=dry-run
uninstall.executed=false
uninstall.safe_target=true
uninstall.target_published_inf=oemN.inf
uninstall.command_preview=pnputil.exe /delete-driver oemN.inf /uninstall
result=plan-ready
```

不会执行 preview command。

识别依据仍来自 dev.3 的精确 Driver Store probe：

- Original INF；
- Catalog；
- Provider；
- Version；
- exactly one matching package。

不会根据 `Apple` 关键字批量寻找驱动。

## 阻断

以下状态不生成可执行目标：

- driver not installed；
- older；
- newer；
- multiple packages；
- Published INF 不符合 `oem[0-9]+.inf`；
- `%WINDIR%\INF\oemN.inf` 不存在。

## 真正卸载

后续阶段若开放真实删除，只能基于已经验收的 dry-run plan，
调用 Windows 官方支持的：

```text
pnputil /delete-driver <Published Name> /uninstall
```

当前 dev.5.2 不调用该命令。
