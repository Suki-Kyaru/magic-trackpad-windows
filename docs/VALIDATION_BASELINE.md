# v0.1.0-dev.5.1 验证基线

本文件记录正式初始化 Git 时已经完成的真实验证范围，以及尚未完成的验证。

---

## 1. 开发环境

已验证：

```text
Visual Studio Community 2026 18.8
MSVC 19.51
Windows SDK 10.0.26100
CMake 4.3.1-msvc1
Inno Setup 6.7.0
PowerShell 7.6.4
```

C++ Release 构建成功：

```text
build\Release\MagicTrackpadHelper.exe
```

---

## 2. 真实硬件

设备：

```text
Apple Magic Trackpad
USB-C generation
A3120
PID_0324
```

Windows：

```text
Windows 11 x64
```

---

## 3. USB-C

已验证：

```text
USB\VID_05AC&PID_0324&MI_01
```

绑定：

```text
Apple USB Precision Touchpad Device (User-mode)
Provider: Bingxing Wang, Vito Plantamura
Driver: 2025.3980.1.1000
```

下游同时出现：

```text
符合 HID 标准的触摸板
Microsoft Input Configuration Device
```

探针：

```text
usb.present=true
usb.precision=true
result=ready
ExitCode=0
```

### MI_00

真实设备同时存在：

```text
USB\VID_05AC&PID_0324&MI_00
```

该接口仍由 Microsoft `input.inf` 管理，并可能在部分 Windows 版本中显示错误状态。

当前真实机器的 Precision Touchpad 主功能正常。

因此项目当前明确：

**不自动禁用、不强制绑定、不修改 MI_00。**

---

## 4. Bluetooth

上游 Bluetooth filter 正常绑定：

```text
Apple Multi-touch Trackpad HID Filter
Apple Multi-touch Auxiliary Services
```

Bluetooth 在线：

```text
bluetooth.present=true
bluetooth.remembered=true
bluetooth.paired=true
bluetooth.connected=true
bluetooth.precision=true
result=ready
ExitCode=0
```

妙控板关机：

```text
bluetooth.present=true
bluetooth.remembered=true
bluetooth.paired=true
bluetooth.connected=false
bluetooth.precision=true
result=paired-not-connected
ExitCode=4
```

USB-C 插入后：

```text
usb.present=true
usb.precision=true
bluetooth.connected=false
result=ready
```

---

## 5. Windows Precision Touchpad

真实验证：

- 一指指针；
- 单指轻点；
- 双指滚动；
- 双指右键；
- 双指缩放；
- 三指任务视图；
- 三指显示桌面；
- 三指切换应用；
- 三指点击中键；
- 四指切换虚拟桌面；
- Windows 触摸板高级手势。

Windows 设置页面可正常识别为 Precision Touchpad。

---

## 6. Haptic / Control Panel

上游：

```text
AmtPtpControlPanel.exe
```

已验证：

- macOS Click Options；
- Medium Haptic；
- Palm Rejection；
- Ignore Near Fingers；
- Ignore Button Finger；
- Bluetooth Battery；
- Windows Touchpad Settings。

Bluetooth 电量读取真实成功。

---

## 7. Driver Store

当前真实机器：

```text
Published INF: oem116.inf
Original INF: amtptpdevice.inf
Catalog: AmtPtpDevice.cat
Provider: Bingxing Wang, Vito Plantamura
Driver Version: 2025.3980.1.1000
```

探针：

```text
driver.installed_count=1
driver.installed=true
driver.state=current
result=current
ExitCode=0
```

识别逻辑不依赖 `oem116.inf` 固定值。

---

## 8. 上游 Release staging

官方 v2.0 ZIP：

```text
MT2FW11-20260223-MSSigned.zip
```

SHA256：

```text
2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

已验证：

- ZIP SHA256；
- 官方包装目录结构；
- AMD64 / ARM64 文件存在；
- INF Provider；
- INF DriverVer；
- CAT Authenticode；
- SYS Authenticode；
- staging 后逐文件 `PAYLOAD.sha256`。

---

## 9. 安装器

基线：

```text
v0.1.0-dev.5.1
```

真实机器已验证：

- 简体中文向导；
- Windows 11 x64 架构限制；
- UAC；
- current driver -> NO-OP；
- 控制面板安装；
- README / Third-party notice 安装；
- 开始菜单快捷方式；
- 控制面板完成页自动启动；
- Windows 触摸板设置快捷方式；
- 卸载器生成。

重复安装前后：

```text
driver.installed_count=1
driver.published_inf=oem116.inf
driver.current_version=2025.3980.1.1000
driver.state=current
```

均保持不变。

---

## 10. 外层安装器签名

当前：

```text
Setup Authenticode: NotSigned
```

这是当前开发阶段预期状态。

内嵌上游驱动的 CAT/SYS 仍保持 Microsoft 有效签名。

外层 Setup 签名属于后续公开发布前的产品化任务。

---

## 11. 尚未验证

### 必须完成

- 干净 Windows 11 x64 `not-installed -> installed`；
- 首次安装后 Driver Store 精确复核；
- 干净系统重复安装 NO-OP；
- VM snapshot 回滚后重复回归。

### 尚未实现或未正式开放

- 驱动安全卸载；
- 自动升级旧驱动；
- 多残留驱动自动清理；
- ARM64 正式安装器；
- 外层 Setup 代码签名；
- 自动 Bluetooth pairing；
- 自定义现代控制面板；
- 自动修改 Windows gesture；
- MI_00 workaround。

---

## 12. 冻结规则

在干净 VM 首次安装验证前：

**不要为了测试而卸掉当前真实机器已经正常工作的驱动。**

真实机器继续作为：

```text
A3120 hardware known-good baseline
```

虚拟机作为：

```text
clean install / rollback / installer lifecycle testbed
```
