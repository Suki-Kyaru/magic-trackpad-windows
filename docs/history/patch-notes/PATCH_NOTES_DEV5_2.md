# v0.1.0-dev.5.2

新增：

- `.gitattributes` 固定源码 LF；
- 持久化 safe-install transcript；
- 安装器 SetupLogging；
- `Collect-Diagnostics.ps1`；
- 安装后诊断工具与日志快捷方式；
- `Get-UninstallPlan.ps1`；
- `Test-UninstallDryRun.ps1`；
- dry-run 前后 Driver Store probe 不变回归。

不新增：

- driver delete；
- driver upgrade；
- driver cleanup；
- MI_00 workaround；
- Bluetooth pairing；
- gesture modification。

本阶段的第一验收应在实体机和已安装驱动的 VM 中分别运行 dry-run，
确认动态目标分别为各自的 `oem*.inf`，且前后 Driver Store 状态完全不变。
