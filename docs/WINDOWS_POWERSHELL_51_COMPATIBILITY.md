# Windows PowerShell 5.1 兼容规则

安装后的维护工具不能假设用户安装了 PowerShell 7。

当前正式运行入口使用：

```text
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe
```

因此 runtime scripts 必须兼容 Windows PowerShell 5.1。

UTF-8 无 BOM 输出统一使用：

```powershell
$encoding = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($Path, $Lines, $encoding)
```

不在 runtime scripts 中使用：

```text
Set-Content -Encoding utf8NoBOM
```

因为 Windows PowerShell 5.1 不支持该枚举值。

开发/构建脚本仍可在已验证的 PowerShell 7 环境中使用更现代的参数，
但安装到最终用户机器上的脚本应遵守 Windows PowerShell 5.1 兼容基线。
