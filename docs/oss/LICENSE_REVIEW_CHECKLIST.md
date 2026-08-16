# License / Redistribution Review Checklist

Status: OSS-1.3C IMPLEMENTED; PUBLIC BINARY RELEASE NOT YET PUBLISHED

This document is an engineering/open-source compliance checklist, not legal
advice.

## Licensing model

Project-authored wrapper code and original documentation:

```text
MIT License
SPDX identifier: MIT
Copyright (c) 2026 Suki-Kyaru
```

Third-party driver/control-panel payload:

```text
vitoplantamura/MagicTrackpad2ForWindows
upstream GPLv2 terms
not relicensed by this project
```

See `LICENSE_POLICY_DECISION.md`.

## Frozen upstream evidence

Pinned signed payload:

```text
Release: v2.0
Asset: MT2FW11-20260223-MSSigned.zip
SHA256: 2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

Strongest preserved signed-build source evidence:

```text
source checkout:
8874eaa3994f0e7e40fa40312250bbc5f13cc928

workflow revision:
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa

v2.0 tag:
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3

Actions run:
22308909844
```

See `UPSTREAM_SOURCE_PROVENANCE.md`.

## Implemented repository files

Required repository material now includes:

- `LICENSE`
- `licenses/GPL-2.0.txt`
- `licenses/README.md`
- `THIRD_PARTY_NOTICES.md`
- `docs/oss/UPSTREAM_SOURCE_PROVENANCE.md`
- `docs/oss/RELEASE_COMPLIANCE.md`
- `scripts/Verify-LicenseDistribution.ps1`
- `scripts/Build-ReleaseBundle.ps1`
- `scripts/Verify-ReleaseBundle.ps1`

## Frozen dev.5.4.2 artifact boundary

`v0.1.0-dev.5.4.2` is a validated frozen artifact, not a version number that the
post-tag OSS branch may reuse for a different binary.

Frozen Setup SHA256:

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

Therefore:

- OSS-1.3C does not change `installer/setup.iss`;
- `Build-Installer.ps1` refuses to build while `VERSION` remains
  `0.1.0-dev.5.4.2`;
- future builds require `VERSION` and Inno `MyAppVersion` to be changed together;
- `Build-ReleaseBundle.ps1` also rejects the frozen version on post-tag source.

This prevents a second, different Setup executable from being presented under
the already-frozen dev.5.4.2 identity.

## Binary distribution unit

The release tooling does **not** treat a naked `Setup.exe` as the publishable
binary asset.

It creates:

```text
MagicTrackpad-for-Windows-<version>-x64-binary.zip
```

containing:

```text
MagicTrackpad-for-Windows-Setup-<version>-x64.exe
LICENSE
GPL-2.0.txt
THIRD_PARTY_NOTICES.md
UPSTREAM_PROVENANCE.txt
SOURCE_AVAILABILITY.txt
```

The exact upstream corresponding-source archive and wrapper source archive are
published alongside that binary ZIP at the same release location.

This keeps the applicable license/notice material accompanying the distributed
binary without changing the already-frozen dev.5.4.2 installer.

## Release source bundle gate

After a future version bump and a clean committed source state,
`Build-ReleaseBundle.ps1` creates:

```text
MagicTrackpad-for-Windows-<version>-x64-binary.zip
MagicTrackpad-for-Windows-source-<version>.zip
MagicTrackpad2ForWindows-corresponding-source-8874eaa3994f.zip
UPSTREAM_BUILD_WORKFLOW-3611b8c6f4fa.yml
UPSTREAM_PROVENANCE.txt
SHA256SUMS.txt
```

The corresponding-source ZIP contains the exact upstream source commit plus
clearly named redistribution additions:

- GNU GPL version 2 text;
- the preserved workflow used as build evidence;
- a source-origin/provenance note.

`Verify-ReleaseBundle.ps1` checks:

- every required public release file exists;
- no naked Setup executable appears at the release root;
- SHA256SUMS covers every release file exactly once;
- binary ZIP contains Setup plus MIT/GPL/notice/provenance/source-availability
  material;
- legal/notice material matches repository copies;
- provenance contains exact asset/source/workflow/tag/Actions identifiers and
  archive hashes;
- wrapper source includes compliance/build tooling and excludes generated/local
  binary payloads;
- upstream source includes expected driver/build inputs and Microsoft
  SDK/WDK `10.0.26100.6584` package declarations.

## Upstream SPDX precision

Continue to describe the upstream component conservatively as `GPLv2` unless an
authoritative upstream notice establishes the precise
`GPL-2.0-only`/`GPL-2.0-or-later` expression.

The separate `licenses/GPL-2.0.txt` file preserves GNU GPL version 2 license
text for redistribution.

## Remaining productization

OSS-1.3C implements repository licensing and release-compliance tooling. It does
**not** publish a public binary release.

Still planned:

- a controlled post-dev.5.4.2 version bump before the next installer build;
- CONTRIBUTING / SECURITY;
- Issue / PR templates;
- GitHub Actions CI;
- public release automation/policy;
- wrapper code-signing strategy.

## Revisit gate

Reopen licensing analysis if the architecture begins directly incorporating,
linking, or modifying GPL-covered upstream source, if upstream licensing changes,
or if the distribution model materially changes.
