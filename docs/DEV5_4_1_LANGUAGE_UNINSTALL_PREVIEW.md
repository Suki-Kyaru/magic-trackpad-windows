# dev.5.4.1 - UI language auto detection and uninstall decision preview


## Wizard visual style

dev.5.4.1 uses the Inno Setup built-in Windows 11 style:

```text
WizardStyle=modern dynamic windows11
```

Policy:

- `modern` keeps the newer flat wizard layout;
- `dynamic` follows the Windows light/dark appearance selected at Setup startup;
- `windows11` supplies the built-in Windows 11 light-style counterpart;
- the native title bar is retained for now;
- no custom VCL style file, background image, or title-bar override is used.

This intentionally keeps the first visual pass close to Inno Setup's maintained
built-in Windows 11 styling instead of inventing a custom theme before the
installer/uninstaller UX has been accepted.

## Language policy

The installer supports two UI languages in this phase:

- Simplified Chinese
- English

Selection policy:

1. Inno Setup uses `LanguageDetectionMethod=uilanguage`.
2. Simplified Chinese Windows UI -> Simplified Chinese.
3. Any unsupported UI language -> English.
4. Traditional Chinese is intentionally not treated as Simplified Chinese.
5. No language-selection dialog is shown.
6. A previous installation language may be reused on upgrade.

English is deliberately listed first in `[Languages]`, making it the safe
fallback when no supported UI language matches.

## Localization architecture

Standard Setup/Uninstall text comes from Inno Setup's language files.

Project-specific UI text uses language-qualified `[CustomMessages]` entries and
`{cm:...}` / `CustomMessage(...)`.

The frozen PowerShell/helper driver layer remains language-neutral.

## Localized content

Language-specific InfoBefore/README files are included:

- `INFO_BEFORE.en.txt`
- `INFO_BEFORE.zh-CN.txt`

Start-menu shortcut names and the Finish-page control-panel action are also
localized.

## dev.5.4.1 uninstall preview

Uninstall presents three actions through a localized confirmation dialog:

- Yes -> preview "remove driver"
- No -> uninstall application and keep driver (recommended)
- Cancel -> abort uninstall

Selecting the remove-driver preview runs the already validated read-only
`Get-UninstallPlan.ps1`.

dev.5.4.1 never executes the destructive driver removal command.

Regardless of the preview choice:

```text
driver_delete_executed=false
```

A small machine-readable preview log is written when actual application
uninstallation begins:

```text
C:\ProgramData\Magic Trackpad for Windows\Logs\
UninstallDecisionPreview-*.log
```

The log records the active installer language, choice, dry-run result, and the
fact that no driver deletion occurred.

## Silent uninstall

Silent uninstall defaults to keeping the driver and does not display the
interactive choice dialog.

## Validation plan

On a Simplified Chinese Windows VM:

- run Setup normally -> Chinese UI expected;
- confirm Start-menu items and custom messages are Chinese;
- test uninstall "No" -> application removed, driver retained;
- reinstall;
- test uninstall "Yes" -> safe preview succeeds, application removed, driver
  still retained.

For the English resource path:

- reinstall with `/LANG=english` for resource validation;
- verify Setup custom strings, InfoBefore content, Start-menu items and uninstall
  choice are English.

A later non-Chinese Windows VM can validate automatic fallback independently.
