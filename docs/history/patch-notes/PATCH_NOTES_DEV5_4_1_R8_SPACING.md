# dev.5.4.1 R8 - content spacing polish

VM review after R7 showed that the overall Windows 11 style and installation
flow were accepted, but the vertical content rhythm was still slightly
unbalanced.

## InfoBefore page

The page keeps:

- title: Installation Information / 安装说明
- subtitle: localized explanatory sentence

The redundant third instructional line is hidden in the UI:

`InfoBeforeClickLabel.Visible := False`

The scrollable body now starts 12 scaled pixels below the shared page subtitle.
Its bottom edge is preserved by increasing its height by the same delta.

This turns the page into:

```text
Title
Subtitle
    12px semantic gap
Body
```

instead of:

```text
Title
Subtitle
large gap
redundant click instruction
Body
```

## Destination page

The main destination content group moves upward by 8 scaled pixels:

- folder bitmap
- main destination label
- browse/instruction label
- path edit
- Browse button

The bottom disk-space line and navigation buttons are not moved.

## Copy correction

The destination instruction no longer says "click Next" after R6 changed the
last pre-installation action to Install.

Simplified Chinese:

`如需更改安装位置，请点击“浏览”。确认后点击“安装”。`

English:

`Click Browse to choose a different folder. When ready, click Install.`

## Unchanged

R8 does not change:

- `modern dynamic windows11`
- directory freedom
- remembered previous directory
- Ready-page removal
- language detection
- uninstall preview
- Driver Store lifecycle
- real driver deletion behavior
