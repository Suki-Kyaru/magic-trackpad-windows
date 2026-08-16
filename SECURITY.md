# Security Policy

## Reporting a vulnerability

Please do **not** publish exploit details, sensitive logs, machine identifiers,
or a proof-of-concept for a security vulnerability in a public issue.

When the GitHub repository provides private security reporting, use GitHub's
private vulnerability/security-advisory reporting path.

If private reporting is not available, open a minimal public issue that states
only that you need a private contact channel for a security report. Do not
include vulnerability details in that issue.

## What counts as security-sensitive here

Examples include:

- unsafe Driver Store package selection/deletion;
- a path that could remove unrelated drivers;
- bypass of the connected-device removal guard;
- command/script injection in installer or tooling;
- privilege-boundary mistakes;
- untrusted payload acceptance or signature/hash bypass;
- diagnostics leaking identifiers despite the documented privacy contract;
- release tooling publishing the wrong source/license/provenance material;
- arbitrary file overwrite/delete paths.

Ordinary device compatibility or gesture issues are usually normal bug reports.

## What to include privately

When possible, provide:

- affected project version/commit;
- Windows version/build and architecture;
- hardware/connection mode if relevant;
- exact reproduction steps;
- impact;
- whether administrative privileges are required;
- sanitized diagnostic output;
- suggested fix, if known.

Do not send passwords, recovery keys, private certificates, signing keys, or
unredacted personal data.

## Supported baseline

There is not yet a public binary release from this repository.

The currently frozen validated development artifact is:

```text
v0.1.0-dev.5.4.2
```

It must not be silently rebuilt/reissued under the same version.

Security fixes are developed on the active repository branch and will use a new
version before any new public binary is built.

## Disclosure process

The maintainer will aim to:

1. reproduce/triage the report;
2. identify affected safety contracts;
3. prepare a minimal fix and regression test;
4. run the relevant validation matrix;
5. coordinate disclosure after a fixed build/release is ready when appropriate.

No fixed response-time SLA is promised for this volunteer project.

## Third-party driver vulnerabilities

If the vulnerability is entirely inside
`vitoplantamura/MagicTrackpad2ForWindows`, it may also need to be reported to the
upstream project.

Do not assume that reporting it here automatically notifies upstream.

The wrapper project will not modify/re-sign the signed upstream payload as an
unreviewed hotfix.
