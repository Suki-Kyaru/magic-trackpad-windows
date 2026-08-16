# OSS-1.5A.3 Local / Hosted Helper-Build Unification

Local clean-build validation proved that Visual Studio 2026 + bundled CMake
4.3.1 can configure/build the helper and that the fresh helper passes the
Windows PowerShell 5.1 compatibility suite.

The developer's ordinary PowerShell session did not have `cmake` on PATH.

This correction adds `scripts/Build-CIHelper.ps1` and makes both local
reproduction and the GitHub helper-build job use it.

The script:

- prefers CMake from PATH;
- falls back to Visual Studio's bundled CMake via `vswhere.exe`;
- performs a clean `build-ci` x64 helper build;
- runs Windows PowerShell 5.1 compatibility using that fresh helper.

Also adds explicit LF normalization for `.gitignore`.

No product/driver/install/uninstall behavior changed.
