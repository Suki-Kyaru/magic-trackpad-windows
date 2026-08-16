# License Policy Decision

Status: DECIDED IN OSS-1.3B; IMPLEMENTED IN OSS-1.3C
Decision date: 2026-08-16

This document records the project's licensing policy decision. It is an
engineering/open-source project policy, not legal advice.

## Decision

Project-authored Magic Trackpad for Windows wrapper code and original
documentation will be licensed under:

```text
MIT License
SPDX identifier: MIT
Copyright holder: Suki-Kyaru
Initial copyright year: 2026
```

The root `LICENSE` file is implemented in OSS-1.3C using the standard MIT
license text.

## Scope of the MIT license

The intended MIT scope is content authored specifically for this wrapper
project, including, unless a file states otherwise:

```text
helper/
installer/
scripts/
project-authored docs/
repository metadata and build/validation tooling
```

The MIT license does not relicense third-party material.

## Third-party exclusion

The following upstream project remains third-party software under its own
license terms:

```text
vitoplantamura/MagicTrackpad2ForWindows
```

This includes the pinned Microsoft-signed binary payload staged locally under:

```text
third_party/MagicTrackpad2ForWindows-v2.0/
```

and any corresponding upstream source archive preserved for redistribution
compliance.

The wrapper project:

- does not claim authorship of the upstream driver;
- does not relicense the upstream driver as MIT;
- does not edit or re-sign the signed INF/CAT/SYS/DLL payload;
- preserves upstream attribution and GPLv2 license material;
- supplies corresponding-source/provenance material when redistributing the
  upstream binary.

## Packaging model

For project engineering purposes, the wrapper and upstream driver are managed as
separate works packaged together.

The wrapper:

- is independently authored;
- communicates with Windows through Windows APIs and PnPUtil;
- discovers/manages the installed driver package externally;
- does not link upstream driver source into the helper/installer;
- does not compile upstream driver source into the wrapper executable;
- deploys the upstream binary payload as a distinct signed driver package.

GNU's GPL FAQ describes installation software and the GPL-covered files it
installs as separate works, and permits aggregation of independent programs.
That guidance supports the project's MIT-wrapper / GPL-third-party packaging
policy.

This is not a guarantee about how a court would classify every possible future
architecture. If the wrapper later directly incorporates, links, modifies, or
derives from upstream GPL-covered source, the license analysis must be reopened.

## Upstream GPL wording

The upstream repository/tag includes GNU GPL version 2 license text and upstream
lineage describes the USB driver as GPLv2.

The project will continue to describe the upstream component conservatively as
"GPLv2" in human-facing attribution until an authoritative upstream notice
clearly establishes the appropriate SPDX `only` versus `or-later` expression.

Do not invent:

```text
GPL-2.0-only
```

or:

```text
GPL-2.0-or-later
```

for upstream files solely from the shorthand "GPLv2".

## Public release policy

OSS-1.3C implements and verifies the repository/release materials below. A
public binary release is still a separate release decision and must pass the
release-bundle verifier:

```text
LICENSE
licenses/GPL-2.0.txt
THIRD_PARTY_NOTICES.md
corresponding upstream source archive
upstream provenance manifest
wrapper source archive
SHA256SUMS.txt
release compliance verifier
```

The precise final filenames may evolve, but the compliance coverage must not be
weakened.

## Copyright identity

The initial MIT copyright holder string will be:

```text
Suki-Kyaru
```

This matches the project's established Git author identity and avoids exposing a
different personal/legal name in public repository metadata.

If the project later accepts outside contributions, contributors retain their
copyright in their contributions unless a separate contribution agreement is
adopted. No CLA is created by this decision.

## Revisit triggers

Reopen this policy before release if any of these become true:

- upstream driver source is copied into wrapper-authored source files;
- the wrapper begins statically/dynamically linking against GPL-covered
  upstream libraries;
- upstream changes its licensing terms;
- a different third-party driver payload is introduced;
- public distribution model changes materially;
- professional legal review recommends a different treatment.

Absent such a trigger, future maintainers and coding agents should treat this
decision as the project's licensing baseline.

## OSS-1.3C implementation note

The frozen `v0.1.0-dev.5.4.2` Setup artifact is not rebuilt by OSS-1.3C.
Post-tag licensing/release tooling changes live on the OSS productization branch,
while the validated dev.5.4.2 artifact remains tied to its original tag/source
state.

Future builds require a new version before `Build-Installer.ps1` will run.

Public binary publication uses a binary ZIP as the compliance unit. That ZIP
contains Setup plus MIT/GPL/third-party/provenance material; the exact upstream
corresponding-source ZIP is published alongside it.
