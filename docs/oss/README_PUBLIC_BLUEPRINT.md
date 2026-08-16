# Public README Blueprint

Status: IMPLEMENTED THROUGH OSS-1.3C

The root English README and Simplified Chinese companion are now the public
repository entry points.

They cover:

- project identity and development status;
- accepted Windows 11 screenshots;
- project-validated support matrix;
- install/uninstall flows;
- safe driver lifecycle model;
- diagnostics/privacy;
- build-from-source flow;
- upstream attribution;
- MIT wrapper / GPLv2 third-party license separation;
- frozen dev.5.4.2 artifact identity;
- controlled release/source-compliance process;
- technical documentation entry points.

## Maintenance rules

Future changes should keep the README aligned with executable/verifier contracts.

Do not:

- reintroduce stale dev.5.1 claims;
- imply unvalidated ARM64/Windows 10 wrapper support;
- describe the third-party upstream driver as MIT;
- publish a post-tag rebuild under `v0.1.0-dev.5.4.2`;
- instruct users/maintainers to upload a naked Setup executable as the official
  public release unit.

Update the README when:

- a new wrapper version is actually validated;
- CI badges become meaningful;
- CONTRIBUTING / SECURITY / GitHub templates are added;
- wrapper code signing is introduced;
- additional hardware/architectures are genuinely validated;
- a public binary release is published.
