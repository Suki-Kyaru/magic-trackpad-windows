# OSS-1.5A.2 Clean-Runner Dependency Hotfix

Local OSS-1.5A static checks passed because the developer machine already had a
validated helper at `build/Release/MagicTrackpadHelper.exe`.

A clean GitHub `contracts` job would not have that build product, while the
original Windows PowerShell compatibility test required it.

This correction:

- keeps the contracts job truly static;
- moves dynamic Windows PowerShell 5.1 compatibility into the helper-build job;
- runs it only after a fresh `build-ci` helper is produced;
- adds optional `-HelperPath` to the compatibility test;
- ignores local `build-ci/`;
- keeps dev.5.4.2 installer/release builds excluded.

No driver/install/uninstall product behavior changed.
