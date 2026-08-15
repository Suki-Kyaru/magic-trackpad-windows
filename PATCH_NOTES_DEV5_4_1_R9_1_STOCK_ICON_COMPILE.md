# dev.5.4.1 R9.1 - stock icon call compile hotfix

R9 static contracts passed, but Inno Setup 6.7.0 stopped while compiling the
stock-folder icon initialization.

The geometry work had not yet been runtime-tested; the failure occurred first
inside the icon initialization expression.

The Inno Setup documentation demonstrates
`InitializeBitmapImageFromStockIcon` as a direct function call. R9 unnecessarily
assigned its Boolean return value to `FolderStockIconLoaded`, but that value was
never used.

R9.1 therefore:

- removes the unused `FolderStockIconLoaded` variable;
- invokes `InitializeBitmapImageFromStockIcon` directly;
- keeps `SIID_FOLDER`, `clNone`, and the DPI size candidates;
- adds a verifier rule requiring the documented direct-call shape.

Unchanged:

- Windows 11 style;
- 8px title/subtitle gap;
- 16px subtitle/content gap;
- InfoBefore body reflow;
- folder icon / destination-label vertical centering;
- 16px / 8px destination control rhythm;
- bottom disk-space/navigation geometry;
- language behavior;
- driver/uninstall core.
