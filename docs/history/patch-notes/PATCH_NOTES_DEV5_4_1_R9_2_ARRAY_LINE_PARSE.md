# dev.5.4.1 R9.2 - array-line parse hotfix

R9.1 still failed before Pascal code compilation:

`Invalid section tag`

The reported line was the standalone array literal:

```text
[16, 20, 24, 32, 40, 48, 64]);
```

Inno Setup script sections themselves begin with square brackets. Keeping a
numeric Pascal array literal at the start of a physical line can therefore be
consumed by the outer script parser as a section tag before the `[Code]`
compiler sees it.

The official `InitializeBitmapImageFromStockIcon` example keeps the call and its
array argument on one physical line.

R9.2 changes only this source form:

```text
InitializeBitmapImageFromStockIcon(WizardForm.SelectDirBitmapImage,
  SIID_FOLDER, clNone, [16, 20, 24, 32, 40, 48, 64]);
```

is emitted as one physical line in `setup.iss`.

The verifier now rejects numeric Pascal array literals that begin a physical
script line.

No layout, localization, icon choice, driver, or uninstall behavior changes.
