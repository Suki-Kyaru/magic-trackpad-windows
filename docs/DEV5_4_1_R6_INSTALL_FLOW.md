# dev.5.4.1 R6 - installation flow decision

## Accepted visual base

Keep:

```text
WizardStyle=modern dynamic windows11
```

The built-in dark/light Windows 11 style is accepted as the visual baseline.

## Interactive installation flow

Use:

```text
Information
-> Destination folder
-> Install
-> Installation
-> Finished
```

Do not show a separate Ready to Install page.

## Destination folder is user-controlled

The destination page must remain visible even during upgrades:

```text
DisableDirPage=no
```

This supports users who deliberately organize installed software into specific
folders or drives.

The default path is still:

```text
C:\Program Files\Magic Trackpad for Windows
```

unless a previous installation directory exists.

Previous choice is remembered:

```text
UsePreviousAppDir=yes
```

but the user can override it again.

## Final action caption

Because the destination page is the final pre-installation page, its main
button must read the localized Inno Setup equivalent of:

```text
安装
Install
```

Use:

```text
SetupMessage(msgButtonInstall)
```

rather than hard-coding Chinese or English strings.
