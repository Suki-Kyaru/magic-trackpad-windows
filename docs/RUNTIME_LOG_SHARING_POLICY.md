# Runtime Log Sharing Policy

There are two different log classes.

## Shareable diagnostic report

`Diagnostics-*.txt`

This is the default report users may send to a maintainer.

It is privacy-minimized by default and redacts machine-specific identifiers.

Use this report for normal support.

## Local technical logs

Examples:

```text
Install-*.log
DriverRemoval-*.log
UninstallPlan-*.log
```

These logs are intended primarily for local validation and advanced debugging.

Windows PowerShell transcript-based install logs can contain:

- Windows user name;
- computer name;
- temporary file paths;
- process identifiers;
- command-line arguments;
- local installation paths.

Therefore raw local technical logs must not be presented as the default
shareable support artifact.

Before publishing or attaching a local technical log to a public issue, review
and redact machine-specific information.

## Repository rule

Do not commit real-machine or VM runtime logs to Git.

Validation conclusions belong in documentation; raw logs remain local evidence.
