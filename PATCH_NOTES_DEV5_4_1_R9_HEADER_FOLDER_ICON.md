# dev.5.4.1 R9 - unified header rhythm + folder icon fix

R8 improved the installer flow, but VM screenshots exposed two remaining
geometry issues:

1. page title and subtitle were visually too close while the main content sat
   too far below them;
2. the destination-folder bitmap looked clipped after relative-position tweaks.

R9 replaces ad-hoc offsets with a stable page geometry contract.

## Header rhythm

For InfoBefore and Select Destination:

```text
Page title
    8 scaled px
Page subtitle
    16 scaled px
Primary content
```

The subtitle left edge is aligned to the page-title left edge.

`TNewStaticText.AdjustHeight` is used after the active page/language caption is
known so the layout follows the actual rendered text instead of relying on
Inno's default reserved label box height.

The reflow runs from `CurPageChanged`, after the page captions are active.

## InfoBefore

The redundant click-instruction label remains hidden.

The scrollable body starts at the common content anchor and preserves its
original bottom edge, preventing cumulative geometry changes when pages are
revisited.

## Destination folder icon

The destination image is rebuilt from the Windows stock `SIID_FOLDER` icon with
DPI-aware size candidates:

```text
16, 20, 24, 32, 40, 48, 64
```

`InitializeBitmapImageFromStockIcon` sizes the bitmap control to the loaded
system icon, avoiding the clipped default bitmap appearance.

The icon and primary explanation are vertically centered in the same first row.

## Destination rhythm

After the first row:

- 16 scaled px -> Browse/install instruction;
- 8 scaled px -> path edit;
- Browse button is vertically centered to the path edit.

Disk-space information and bottom navigation controls are not moved.

## Unchanged

R9 does not change:

- `modern dynamic windows11`;
- destination-folder freedom;
- remembered previous directory;
- Ready-page removal;
- Chinese/English language detection;
- uninstall preview;
- Driver Store lifecycle;
- real driver deletion behavior.
