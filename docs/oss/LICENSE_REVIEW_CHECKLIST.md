# License / Redistribution Review Checklist

Status: OSS-1.3B POLICY DECIDED; OSS-1.3C IMPLEMENTATION PENDING

This document is an engineering/open-source compliance checklist, not legal
advice.

## Frozen upstream evidence

### Pinned signed payload

```text
Project: vitoplantamura/MagicTrackpad2ForWindows
Release: v2.0
Asset: MT2FW11-20260223-MSSigned.zip
SHA256: 2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

### Upstream release/tag

`refs/tags/v2.0` resolves to:

```text
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3
```

The tag includes the GNU General Public License version 2 text.

### Signed-build provenance

The v2.0 Release points to GitHub Actions run:

```text
22308909844
```

That workflow revision is:

```text
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa
```

The workflow explicitly checks out `ref: ossign`, creates a source tarball from
the checkout, and uploads it before building.

Archived run metadata identifies that source artifact as:

```text
source-code-8874eaa3994f0e7e40fa40312250bbc5f13cc928
```

Treat this source SHA as the strongest currently available public evidence of
the source checkout used by the signed build.

See `UPSTREAM_SOURCE_PROVENANCE.md`.

## OSS-1.3B policy decision

The author has selected:

```text
Project-authored wrapper code/docs: MIT
SPDX identifier: MIT
Copyright holder: Suki-Kyaru
Third-party MagicTrackpad2ForWindows: upstream GPLv2 terms, not relicensed
```

See `LICENSE_POLICY_DECISION.md`.

The project uses a separate-works/aggregation packaging policy for the current
architecture. This is an engineering compliance position supported by GNU GPL
FAQ guidance, not a binding legal determination.

The policy must be revisited if future code directly incorporates or links
GPL-covered upstream source.

## Upstream SPDX precision

Do not guess `GPL-2.0-only` versus `GPL-2.0-or-later` for upstream files from
the shorthand "GPLv2".

Preserve the actual upstream GPL version 2 license text in the redistribution
package and use conservative human-readable attribution unless upstream supplies
a more precise authoritative notice.

## OSS-1.3C implementation gates

Before public binary distribution:

- add root `LICENSE` with standard MIT text;
- use `Copyright (c) 2026 Suki-Kyaru`;
- add/preserve the applicable upstream GPL version 2 license text separately;
- rewrite `THIRD_PARTY_NOTICES.md` with explicit MIT-vs-third-party scope;
- preserve exact upstream corresponding source;
- preserve build/provenance information;
- keep signed upstream binaries byte-for-byte unchanged;
- update README licensing language from "implementation pending";
- add a source/release packaging script;
- add a release verifier that fails when source/license/provenance assets are
  missing;
- document wrapper `Setup.exe` signature status separately from driver
  signature.

## Conservative release layout

Target shape:

```text
MagicTrackpad-for-Windows-Setup-<version>-x64.exe
SHA256SUMS.txt
MagicTrackpad-for-Windows-source-<version>.zip
MagicTrackpad2ForWindows-corresponding-source-8874eaa3994f.zip
UPSTREAM_PROVENANCE.txt
GPL-2.0.txt
```

The source/provenance coverage must remain intact even if filenames change.

## Public release gate

Until OSS-1.3C is complete:

```text
license policy: decided
license implementation: incomplete
public binary release: blocked
```
