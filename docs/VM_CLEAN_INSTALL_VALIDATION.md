# Windows 11 x64 干净虚拟机安装验收

## 验收目标

验证 `v0.1.0-dev.5.1` 在一台未安装 Magic Trackpad 驱动的干净 Windows 11 x64 环境中，能否完成：

1. 安装前准确识别 `not-installed`；
2. 双击 Setup 后将固定的 Microsoft 签名驱动写入 Driver Store；
3. 安装后准确识别 `current`；
4. 无真实 Magic Trackpad 时仍保持 `no-device`；
5. 第二次运行 Setup 时保持单一驱动包，不重复写入。

## 安装前

`driver-status`：

```text
driver.installed_count=0
driver.installed=false
driver.state=not-installed
result=not-installed
ExitCode=10
```

`status`：

```text
device.model=not-detected
usb.present=false
bluetooth.present=false
driver.bound=false
result=no-device
ExitCode=2
```

## 第一次 Setup 安装

安装完成后：

```text
driver.installed_count=1
driver.installed=true
driver.published_inf=oem8.inf
driver.original_inf=amtptpdevice.inf
driver.catalog=AmtPtpDevice.cat
driver.provider=Bingxing Wang, Vito Plantamura
driver.current_version=2025.3980.1.1000
driver.state=current
result=current
ExitCode=0
```

说明：

- `not-installed -> current` 成功；
- Published INF 在 VM 中动态分配为 `oem8.inf`；
- 项目没有写死实体机的 `oem116.inf`；
- 没有真实妙控板也可以预安装签名驱动；
- 设备探针仍正确返回 `no-device / ExitCode=2`。

## 第二次 Setup 重复安装

再次运行同一安装器后：

```text
driver.installed_count=1
driver.published_inf=oem8.inf
driver.current_version=2025.3980.1.1000
driver.state=current
result=current
ExitCode=0
```

说明：

- matching package 数量仍为 1；
- Published INF 仍为 `oem8.inf`；
- 没有重复生成第二份驱动包；
- current-driver NO-OP / 幂等安装链在干净 VM 中通过。

## 最终判定

`v0.1.0-dev.5.1` 已完成两类互补验证。

实体机 A3120：

- USB-C Precision Touchpad；
- Bluetooth Precision Touchpad；
- Haptic；
- 电量；
- Windows 多指手势；
- current -> Setup -> current；
- `oem116.inf` 保持不变。

干净 Windows 11 x64 VM：

- not-installed -> Setup -> current；
- 0 matching packages -> 1 matching package；
- Published INF 动态分配为 `oem8.inf`；
- second Setup -> current / NO-OP；
- matching package count 始终保持 1；
- 无真实设备时仍正确返回 `no-device`。

因此：

**v0.1.0-dev.5.1 的 Windows 11 x64 驱动安装生命周期已闭环。**

## 下一阶段

优先进入：

1. 安装/诊断日志；
2. 安全卸载 dry-run；
3. 精确卸载目标识别；
4. VM 快照中验证卸载；
5. 再决定是否开放真实驱动卸载。
