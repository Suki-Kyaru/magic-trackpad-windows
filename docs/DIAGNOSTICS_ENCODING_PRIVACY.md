# dev.5.2.1 诊断编码与隐私规则

诊断报告默认应适合直接分享给维护者。

默认报告不包含：

- Windows 用户名；
- 计算机名；
- Bluetooth MAC / device address；
- A3120 USB serial-like container identifier；
- 用户目录绝对路径。

如确实需要完整本机标识，可显式运行：

```powershell
.\scripts\Collect-Diagnostics.ps1 -IncludeIdentifiers
```

helper 的 stdout/stderr 通过显式 UTF-8 解码捕获，避免 Windows PowerShell
将中文设备名错误解释为其他代码页。

此规则只影响诊断报告，不影响设备、驱动或安装器行为。
