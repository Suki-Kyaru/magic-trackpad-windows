# dev.5.4.1 R7 - Install information copy polish

VM visual review accepted the Windows 11 wizard style and the streamlined
destination-folder flow.

The remaining issue was the first page:

- the built-in title "Information" / "信息" was too generic;
- the default subtitle was boilerplate;
- the body repeated the product/version already visible in the window title;
- the page read like an Inno Setup template rather than a product page.

R7 keeps the page but gives it a clear job.

## Standard message overrides

The multilingual installer now uses language-qualified `[Messages]` entries:

English:
- `Installation Information`
- `Please review the following before continuing.`
- `When you are ready, click Next to choose the installation folder.`

Simplified Chinese:
- `安装说明`
- `安装前请确认以下事项。`
- `确认后点击“下一步”选择安装位置。`

No unqualified `[Messages]` entry is allowed.

## Body copy

Both language-specific InfoBefore files are shortened into three sections:

- installation contents;
- safety boundaries;
- uninstall preview.

The duplicate product/version heading is removed.

## Unchanged

R7 does not change:

- `modern dynamic windows11`;
- destination-folder freedom;
- remembered previous destination path;
- Ready-page removal;
- localized Install button;
- language auto detection;
- uninstall decision preview;
- Driver Store lifecycle;
- real driver deletion behavior.
