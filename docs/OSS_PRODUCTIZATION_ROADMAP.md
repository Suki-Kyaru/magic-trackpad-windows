# OSS Productization Roadmap After dev.5.4.2

Status after OSS-1.6 public repository launch, main ruleset activation, and public-readiness closure.

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

## Contributor workflow

Completed in OSS-1.4:

- `CONTRIBUTING.md`;
- `SUPPORT.md`;
- `SECURITY.md`;
- concise root `AGENTS.md`;
- GitHub bug/feature issue forms;
- pull request template;
- development environment guidance;
- risk-based validation matrix;
- coding/PowerShell/Inno safety conventions;
- explicit "do not weaken" contracts for contributors/coding agents;
- static contributor-workflow verifier.

## CI / reproducibility

Completed in OSS-1.5A/B:

- non-destructive GitHub Actions workflow on `windows-2025-vs2026`;
- repository/license/contributor/static-installer contract suite;
- fresh x64 C++ helper configure/build;
- Windows PowerShell 5.1 runtime compatibility using the fresh helper;
- explicit support for both current-driver and clean no-driver dry-run states;
- frozen dev.5.4.2 installer/release build exclusion;
- read-only Actions token permissions and non-persistent checkout credentials;
- real hosted validation for push, pull-request merge ref, and merged `main`;
- zero uploaded CI artifacts.

Future release CI remains a separate phase. It may add upstream payload
hash/signature validation, installer build on a **new** wrapper version,
release/source-bundle verification, artifact SHA256 generation, and clean-source
gates only after the release version and packaging policy are reviewed.

CI must not invent, silently replace, or modify the pinned upstream signed
driver payload.

## First public release preparation

Current release line:

- selected source/prerelease version: `v0.1.0-dev.6.0`;
- last fully validated binary baseline: `v0.1.0-dev.5.4.2`;
- wrapper Setup remains unsigned for the initial prerelease candidate;
- dev.6.0 Candidate 1 has been built and used to refresh the English/Simplified
  Chinese installation and connected-device fail-closed screenshot set.

Candidate 1 behavioral validation is now closed:

- clean-VM install: `not-installed` -> one exact current Driver Store package;
- application-only uninstall: application removed while the driver remained;
- reinstall with the exact current driver: NO-OP Driver Store path, count remained one;
- VM safe driver removal: export -> four-file backup verification -> delete without
  `/force` -> post-check `not-installed`;
- reinstall after safe removal: returned to one exact current package while the
  driver backup remained preserved;
- physical-host A3120 connected-device guard: destructive removal failed closed,
  `remove.executed=false`, `other_apple_drivers_touched=false`, `result=connected`;
- English and Simplified Chinese candidate screenshots were captured.

Before the first public binary release:

- commit the Candidate 1 validation evidence;
- rebuild the final dev.6.0 candidate from the final clean committed HEAD;
- re-run focused identity/signature/smoke checks against that exact final binary;
- generate and verify the controlled release directory;
- re-capture screenshots only if the final candidate changes user-visible UI;
- publish as a prerelease only after asset/source/SHA verification;
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
