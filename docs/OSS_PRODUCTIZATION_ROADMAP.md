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

## First public prerelease: completed

The first public binary prerelease has been published and closed:

- public prerelease: `v0.1.0-dev.6.0`;
- final source/tag target: `4ea2db6dc7ba1f7998f735d56ce1158c9b2be420`;
- final Setup SHA256: `f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791`;
- the outer Setup remains unsigned; the embedded upstream driver remains Microsoft-signed;
- validated project scope remains Windows 11 x64 + Apple USB-C Magic Trackpad A3120;
- current post-release source line: `v0.1.0-dev.6.1`.

Release closure included:

- Candidate 1 lifecycle validation covering install, uninstall, NO-OP, safe real driver removal/reinstall, backup verification, and connected-device fail-closed behavior;
- one final controlled release-bundle build from the final clean source state;
- focused clean-VM install and current-driver NO-OP validation against the exact final Setup;
- exact wrapper source, upstream corresponding source, workflow snapshot, provenance, and SHA256 closure;
- GitHub Draft/prerelease remote asset review before publication;
- publication as the repository's first public binary prerelease.

`v0.1.0-dev.6.0` is now frozen and must never be rebuilt or reissued under the same version.
Future binary publication must use a new version and repeat the controlled release process.

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
