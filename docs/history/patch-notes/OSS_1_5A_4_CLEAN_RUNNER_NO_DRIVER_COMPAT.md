# OSS-1.5A.4 Clean Runner No-Driver Compatibility

The local fresh-helper test ran on a machine where the exact current driver was
installed, so `Get-UninstallPlan.ps1` returned:

```text
exit 0
result=plan-ready
```

A clean GitHub-hosted runner does not have the project driver installed. The
same safe dry-run is expected to return:

```text
exit 20
result=nothing-to-remove
```

The old Windows PowerShell compatibility test treated every nonzero plan exit as
a test failure, which would misclassify a clean runner's valid state.

This correction accepts exactly:

- exit 0 with `result=plan-ready`;
- exit 20 with `result=nothing-to-remove`;

and requires `uninstall.executed=false` in both cases.

Other dry-run states remain failures.

No Driver Store, install, uninstall, or product behavior changed.
