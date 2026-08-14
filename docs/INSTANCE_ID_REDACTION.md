# dev.5.2.2 设备实例 ID 脱敏

默认可分享诊断报告中：

- 保留 VID / PID / MI / Collection 等稳定硬件识别信息；
- 隐藏最终机器相关实例尾段；
- 隐藏 Bluetooth DEV 地址；
- 隐藏 `BLUETOOTHDEVICE_` 地址；
- 隐藏顶层 `bluetooth.address`。

因此普通支持诊断仍能判断：

```text
PID_0324
MI_01
COL01
```

但不会暴露：

```text
MAC/device address
PnP instance tail
USB serial-like container tail
```

如确实需要完整标识，仍可显式使用：

```powershell
.\scripts\Collect-Diagnostics.ps1 -IncludeIdentifiers
```
