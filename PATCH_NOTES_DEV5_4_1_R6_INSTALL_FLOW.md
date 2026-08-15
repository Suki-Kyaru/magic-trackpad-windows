# dev.5.4.1 R6 - streamlined install flow hotfix

VM visual review accepted the built-in:

`WizardStyle=modern dynamic windows11`

but the Ready to Install page remained visually sparse and redundant.

R6 removes that page while preserving full installation-directory control.

## Final pre-install flow

```text
Info Before
  -> Select Destination Location
  -> Install
  -> Preparing / Installing
  -> Finished
```

## Directory policy

The destination page is intentionally always shown:

```text
DisableDirPage=no
```

This is stricter than Inno Setup's default `auto` behavior, which can hide the
directory page when the application is already installed.

The user's previous installation directory remains the default:

```text
UsePreviousAppDir=yes
```

Users may still change it on every interactive install or upgrade.

## Ready-page policy

The redundant Ready page is disabled:

```text
DisableReadyPage=yes
```

The destination page therefore becomes the final interactive page before
installation.

Its primary button uses Inno Setup's own localized caption:

```text
SetupMessage(msgButtonInstall)
```

Going back to an earlier page restores the localized Next caption, and the
Finished page uses the localized Finish caption.

## Removed

The R5 `PreparingLabel.Top + ScaleY(6)` visual tweak is removed because the
Ready/Preparing visual workaround is no longer needed as part of this UX
direction.

## Unchanged

R6 does not change:

- `modern dynamic windows11`;
- Simplified Chinese / English detection;
- English fallback;
- localized InfoBefore content;
- uninstall decision preview;
- driver install core;
- driver removal core;
- dev.5.4.1 preview-only guarantee.
