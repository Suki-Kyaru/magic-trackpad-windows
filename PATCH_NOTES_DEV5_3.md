# v0.1.0-dev.5.3 - VM safe real driver-uninstall experiment

## Prerequisite validation

dev.5.2.5 passed on the clean Windows 11 x64 VM:

- installer runtime executed under Windows PowerShell 5.1;
- current driver path stayed NO-OP;
- dry-run dynamically targeted VM package `oem8.inf`;
- dry-run log was written successfully;
- Driver Store remained `current` with exactly one package;
- Start-menu diagnostics generated a valid no-device report.

## Purpose

This phase performs the first real driver package deletion, but only inside the
no-device VM laboratory scenario.

The script is installed into `Tools` for testing but is deliberately NOT exposed
as a Start-menu uninstall action.

## Destructive gates

`Invoke-SafeDriverUninstall.ps1` requires all of the following:

1. elevated administrator token;
2. explicit `ExpectedPublishedInf`, matching `oemN.inf`;
3. exact confirmation token `REMOVE:<oemN.inf>`;
4. helper driver state must be current;
5. exactly one matching package;
6. published INF must equal the explicit expected INF;
7. original INF, provider and driver version must match the frozen v2.0 package;
8. `%WINDIR%\INF\<oemN.inf>` must exist;
9. device state must be exactly `no-device` with helper exit code 2;
10. a persistent log and backup directory must be writable;
11. PnPUtil must successfully export the target package before deletion;
12. exported `amtptpdevice.inf` must be present.

Only then may it call:

`pnputil /delete-driver <published-inf> /uninstall`

The script never uses `/force`.

After deletion, helper `driver-status` must return exit code 10 and
`result=not-installed`.

## VM-only command example

For the currently validated VM:

```powershell
.\Invoke-SafeDriverUninstall.ps1 `
    -HelperPath ".\MagicTrackpadHelper.exe" `
    -ExpectedPublishedInf "oem8.inf" `
    -ConfirmToken "REMOVE:oem8.inf"
```

Do not reuse `oem8.inf` on another machine. The value is deliberately required
to match the machine's live dry-run result.

## Rollback

After successful removal:

1. verify helper reports `not-installed`;
2. rerun the same dev.5.3 Setup;
3. the normal safe-install path should reinstall the Microsoft-signed upstream
   package;
4. verify helper returns `current` with exactly one package.

The published `oemN.inf` number after reinstall is not assumed in advance.
