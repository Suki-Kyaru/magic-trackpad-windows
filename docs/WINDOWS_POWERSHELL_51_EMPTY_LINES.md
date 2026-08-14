# Windows PowerShell 5.1 empty-line compatibility

Diagnostic reports intentionally contain empty separator lines.

Do not expose report content through a mandatory `[string[]]` PowerShell
parameter, because Windows PowerShell 5.1 can reject an empty-string element
during parameter binding.

The runtime writer instead accepts an object sequence, normalizes values, and
casts to `[string[]]` only at the .NET file-write boundary.

This preserves:

- blank report separators;
- UTF-8 without BOM;
- Windows PowerShell 5.1 compatibility.
