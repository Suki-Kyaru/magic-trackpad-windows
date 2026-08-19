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

The current public binary prerelease is:

```text
v0.1.0-dev.6.0
```

The current final stable-release source is:

```text
v0.1.0
```

The frozen Windows 11 stable-release candidate is:

```text
v0.1.0-rc.2
```

Frozen rc.2 Setup SHA256:

```text
e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40
```

Its source commit is `b54ac7311b1a6e0736e91c2cac248fffcc485e04`.
See `docs/RC2_FINAL_VALIDATION.md` for the final validation evidence.

The frozen Windows 10 validation candidate is:

```text
v0.1.0-rc.1
```

Frozen rc.1 Setup SHA256:

```text
fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068
```

The previous frozen validated binary baseline remains:

```text
v0.1.0-dev.5.4.2
```

Published/frozen binary identities must not be silently rebuilt or reissued
under the same version. Security fixes are developed on a new source version
and require a new release identity before a new public binary is published.

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
