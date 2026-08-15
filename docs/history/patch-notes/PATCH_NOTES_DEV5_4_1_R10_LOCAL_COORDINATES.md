# dev.5.4.1 R10 - local-coordinate layout reset

R9 screenshots made the underlying mistake obvious: the header looked correct
but the page body was pushed far too low.

Root cause:
header controls and body controls were treated as though their Top/Height values
shared one coordinate system.

Inno Setup exposes a `MainPanel`, an `InnerPage`, and separate page objects for
InfoBefore and SelectDir. R9 used the MainPanel header geometry to calculate
body positions that live on another page surface.

R10 removes that cross-container geometry completely.

## Header

Only MainPanel header controls are related to each other:

```text
PageNameLabel
8 scaled px
PageDescriptionLabel
```

The subtitle is left-aligned to the title.

## InfoBefore body

The memo uses its own page-local coordinate system:

```text
Top = ScaleY(12)
```

Its original bottom edge is preserved locally.

## SelectDir body

The destination content also uses only local page coordinates:

```text
Top = ScaleY(12)
folder icon + main label
16 px
secondary instruction
8 px
path field + Browse
```

No MainPanel coordinate participates in those calculations.

## Folder icon

The DPI-aware Windows stock folder icon remains.

## Safety

R10 does not move:

- disk-space label;
- Back / Install / Cancel buttons.

It also does not touch any driver, localization, or uninstall logic.
