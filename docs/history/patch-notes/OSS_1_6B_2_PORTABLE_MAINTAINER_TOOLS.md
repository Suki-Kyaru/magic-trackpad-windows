# OSS-1.6B.2 Portable Maintainer Tools

Public-readiness review found that several maintainer/verifier scripts still
defaulted `-RepoRoot` to the original author's local clone path:

```text
D:\Dev\magic-trackpad-windows
```

The public README build example and one release-compliance example also carried
author-specific `D:\Dev\...` paths.

This phase:

- changes maintainer/verifier `RepoRoot` defaults to derive the repository root
  from `$PSScriptRoot`;
- keeps explicit `-RepoRoot` override support;
- makes README build examples repository-root relative;
- replaces the upstream checkout example with a neutral placeholder;
- adds `Verify-MaintainerPortability.ps1`;
- wires that verifier into static CI and contributor/agent guidance.

The change does not alter driver logic, installation behavior, user-safe
uninstall behavior, helper machine-readable states, or the frozen dev.5.4.2
artifact identity.
