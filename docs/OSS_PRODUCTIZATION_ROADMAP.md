# OSS Productization Roadmap After dev.5.4.2

Status after OSS-1.3C.

The validated driver lifecycle remains frozen. OSS productization is improving
the repository, licensing, contributor workflow, CI, and release engineering
around that stable core.

## Completed foundation

### Repository / public entry points

Completed:

- public English README;
- Simplified Chinese README;
- validated hardware/OS support matrix;
- accepted Windows 11 screenshots;
- documentation index and historical patch-note archive;
- explicit wrapper-versus-upstream architecture boundary;
- static README/repository verifiers.

### Licensing / source distribution

Completed in OSS-1.3A/B/C:

- MIT policy for project-authored wrapper code/docs;
- separate GPLv2 third-party treatment;
- root MIT `LICENSE`;
- GNU GPL version 2 redistribution text;
- final third-party notices;
- exact signed-build source/workflow/tag provenance;
- corresponding-source archive tooling;
- controlled binary ZIP carrying license/notice/provenance material;
- SHA256 release manifest and release verifier;
- frozen dev.5.4.2 same-version rebuild guard.

A public binary release has **not** been published yet.

## Next: contributor workflow

Add:

- `CONTRIBUTING.md`;
- `SECURITY.md`;
- issue templates;
- pull request template;
- development environment instructions;
- validation matrix;
- coding/PowerShell/Inno conventions;
- explicit "do not weaken" safety contracts for contributors and coding agents.

## Then: CI / reproducibility

Automate on Windows:

- C++ configure/build;
- static verifier suite;
- Windows PowerShell 5.1 compatibility checks where available;
- upstream payload hash/signature validation;
- installer build on a **new** wrapper version;
- release/source-bundle verification;
- artifact SHA256 generation;
- clean-source / no-runtime-log gates.

CI must not invent, silently replace, or modify the pinned upstream signed
driver payload.

## First public release preparation

Before the first public binary release:

- choose and validate the next wrapper version;
- build a new installer without reusing `v0.1.0-dev.5.4.2`;
- run the complete regression matrix;
- generate and verify the controlled release directory;
- decide wrapper code-signing strategy;
- publish only verified release assets;
- document beta support/reporting expectations.

## Deferred

Do not mix into immediate OSS productization:

- ARM64 wrapper support without real hardware validation;
- driver upgrade/downgrade automation;
- MI_00 hacks;
- custom kernel-driver rewrites;
- unrelated control-panel redesign.

The strongest value of the project remains safe packaging, diagnostics,
lifecycle management, explicit safety contracts, and maintainable Windows
integration around a validated upstream driver.
