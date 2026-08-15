# dev.5.4.1 R7 - first-page content decision

## Page purpose

Keep the InfoBefore page as the product's safety and scope summary.

Do not use the generic default heading "Information" / "信息".

Use:

```text
Installation Information
安装说明
```

The page should answer three questions before the user selects an install path:

1. What will be installed?
2. What will this installer deliberately not touch?
3. What does the current uninstall preview do?

## Copy rules

Do not repeat the product name and development version inside the scrollable
body because the window title already identifies the package.

Keep the body concise enough that common 100% / 125% DPI layouts do not feel
like a legal document.

Use language-qualified Inno `[Messages]` overrides for standard page captions,
and language-specific `InfoBeforeFile` resources for the body.

## Flow

```text
安装说明 / Installation Information
  -> 选择安装位置 / Destination folder
  -> 安装 / Install
  -> 安装过程
  -> 完成
```
