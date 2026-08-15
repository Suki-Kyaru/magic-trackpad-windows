# dev.5.4.1 Installer / Uninstall Preview Validation

Status: FROZEN / VALIDATED
Target: Windows 11 x64
Visual baseline: Inno Setup 6.7.0 `modern dynamic windows11`

## Scope

dev.5.4.1 closes the first user-facing installer/uninstaller UX layer on top of
the frozen dev.5.3 Driver Store lifecycle.

The validated user-facing flow is:

```text
Setup
  -> Windows UI-language selection
  -> Installation Information
  -> user-selectable destination folder
  -> Install
  -> Finish

Uninstall
  -> keep driver
     OR
  -> preview removing driver
```

The preview build never deletes the driver.

## Language validation

Supported installer languages:

- Simplified Chinese
- English

Policy:

- Simplified Chinese Windows UI -> Simplified Chinese
- unsupported Windows UI language -> English
- no language-selection dialog
- previous installation language may be reused on upgrade

English resources were explicitly validated with:

```text
/LANG=english
```

The English installation and uninstall resources displayed without mixed
Chinese project-specific text.

## Windows 11 visual baseline

Validated style:

```text
WizardStyle=modern dynamic windows11
```

The final accepted layout includes:

- dark/light dynamic style;
- Windows 11 built-in wizard appearance;
- normalized title/subtitle alignment;
- DPI-aware Windows stock folder icon;
- user-selectable destination folder;
- localized Install button on the final pre-installation page;
- no redundant Ready page.

## Destination-folder policy

The directory page is intentionally always visible:

```text
DisableDirPage=no
```

The user's previous path is used as the next default:

```text
UsePreviousAppDir=yes
```

Users may still change the path on every interactive install or upgrade.

The default remains:

```text
C:\Program Files\Magic Trackpad for Windows
```

unless a previous destination exists.

## Final geometry baseline

The accepted R10.2 geometry is page-local.

Header:

```text
Title -> Subtitle = 8 scaled px
```

InfoBefore:

```text
Body top = 4 scaled px
```

SelectDir:

```text
First row top = 8 scaled px
First row -> secondary instruction = 16 scaled px
Secondary instruction -> path field = 8 scaled px
```

Disk-space text and bottom navigation controls are not repositioned.

Do not reintroduce cross-container geometry derived from MainPanel coordinates
for controls that live on inner wizard pages.

## Uninstall branch 1: keep driver

Validated Simplified Chinese branch:

```text
active_language=chinesesimp
remove_driver_requested=false
preview_ran=false
preview_exit_code=-1
driver_delete_executed=false
app_uninstall_started=true
```

After application uninstall:

```text
driver.installed_count=1
driver.state=current
result=current
```

The application directory was removed while the driver remained installed.

## Uninstall branch 2: preview removing driver

Validated English branch:

```text
active_language=english
remove_driver_requested=true
preview_ran=true
preview_exit_code=0
driver_delete_executed=false
app_uninstall_started=true
```

The preview invokes the validated read-only driver plan.

R10.3 also requires a fresh detailed plan log for each preview action:

```text
UninstallPlan-YYYYMMDD-HHMMSS.log
```

The final VM validation produced a new log at the time of the preview rather
than reusing historical evidence.

After preview + application uninstall:

```text
driver.installed_count=1
driver.state=current
result=current
```

Therefore dev.5.4.1 preserves its preview-only safety boundary.

## Audit trail

A remove-driver preview should leave:

```text
UninstallDecisionPreview-*.log
UninstallPlan-*.log
```

The decision log records the selected branch.

The detailed plan log records the exact dynamically discovered package and
remains read-only.

## Frozen safety rules

dev.5.4.1 must not:

- call `/delete-driver` from the user-facing uninstaller;
- delete a driver during preview;
- hard-code `oem8.inf`, `oem116.inf`, or any published INF number;
- search generic Apple drivers;
- modify unrelated iPhone / Apple Mobile Device drivers;
- use `/force`;
- weaken the frozen dev.5.3 Driver Store lifecycle.

## Next phase

dev.5.4.2 may connect the already validated dev.5.3 real-removal core to the
user-facing "remove driver as well" choice.

That phase must preserve:

- default keep-driver behavior;
- exact dynamic driver identification;
- export-before-delete;
- no `/force`;
- post-delete verification;
- unrelated-Apple-driver isolation;
- bilingual user-facing messaging.
