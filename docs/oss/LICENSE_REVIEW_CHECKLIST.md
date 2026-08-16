# License / Redistribution Review Checklist

Status: OSS-1.3A EVIDENCE COLLECTED; POLICY NOT YET FINALIZED

This document is an engineering/legal-review checklist, not legal advice.

## Evidence now frozen

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

Treat this source SHA as the strongest currently available public evidence of the
source checkout used by the signed build.

See `UPSTREAM_SOURCE_PROVENANCE.md`.

## OSS-1.3B policy questions still open

1. Final license expression for code authored in this wrapper repository.
2. Whether to align wrapper code to GPLv2 for simplicity, or license independent
   wrapper components separately while honoring GPL obligations for the driver.
3. Exact SPDX wording (`GPL-2.0-only` vs `GPL-2.0-or-later`) must not be guessed
   from shorthand "GPLv2".
4. Final form of `THIRD_PARTY_NOTICES.md`.
5. Copyright/attribution notice for wrapper-authored code.
6. Public release source bundle layout.

## OSS-1.3C implementation gates

Before public binary distribution:

- add the final root LICENSE chosen in OSS-1.3B;
- preserve applicable upstream GPLv2 text;
- ship/furnish exact corresponding upstream source;
- preserve build/provenance information;
- keep signed upstream binaries byte-for-byte unchanged;
- update README licensing language from "review in progress";
- update THIRD_PARTY_NOTICES;
- add a release verifier that fails when source/license assets are missing;
- document wrapper `Setup.exe` signature status separately from driver signature.

## Conservative source-availability plan

For each binary release containing the pinned upstream driver, publish at the
same release/download location:

```text
MagicTrackpad-for-Windows-Setup-<version>-x64.exe
SHA256SUMS.txt
MagicTrackpad-for-Windows-source-<version>.zip
MagicTrackpad2ForWindows-corresponding-source-8874eaa3994f.zip
UPSTREAM_PROVENANCE.txt
GPL-2.0.txt
```

The exact final filenames may change in OSS-1.3C, but the evidence/source
coverage must not be weakened.
