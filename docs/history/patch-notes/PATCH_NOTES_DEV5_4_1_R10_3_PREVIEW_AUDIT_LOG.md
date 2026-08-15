# dev.5.4.1 R10.3 - uninstall preview audit-log hotfix

Final English uninstall-preview validation passed:

- remove-driver preview requested;
- preview executed successfully;
- preview exit code was 0;
- application uninstall completed;
- driver remained installed and current;
- no driver deletion was executed.

One observability gap remained:

`RunDriverRemovalPreview` invoked `Get-UninstallPlan.ps1` without `-WriteLog`.

Therefore the preview worked, but no fresh detailed `UninstallPlan-*.log` was
created for that specific uninstall attempt.

R10.3 adds only:

```text
-WriteLog
```

to the read-only preview invocation.

Now every "preview removing driver" action leaves both:

- `UninstallDecisionPreview-*.log`
- `UninstallPlan-*.log`

under the ProgramData log directory.

No driver deletion is wired in.
No installer geometry, localization, Driver Store logic, or uninstall choice
behavior changes.
