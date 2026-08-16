# Upstream License and Corresponding-Source Provenance

Status: OSS-1.3A EVIDENCE BASELINE
Date reviewed: 2026-08-16

This is an engineering compliance record, not legal advice.

## Upstream project

Project:

```text
vitoplantamura/MagicTrackpad2ForWindows
```

Pinned binary release used by this project:

```text
release tag: v2.0
asset: MT2FW11-20260223-MSSigned.zip
SHA256: 2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

The wrapper must continue deploying the signed driver payload byte-for-byte.

## v2.0 tag

GitHub `refs/tags/v2.0` resolves to:

```text
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3
```

The v2.0 tag commit includes a repository-root GNU GPL version 2 license text.

However, the signed release asset provenance requires more precision than
"source = v2.0 tag".

## Release build provenance

The v2.0 Release description identifies GitHub Actions run:

```text
22308909844
```

The workflow run itself has:

```text
workflow head SHA:
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa
```

The workflow definition at that revision does **not** simply build its own
`master` checkout. Its checkout step explicitly uses:

```yaml
repository: vitoplantamura/MagicTrackpad2ForWindows
ref: ossign
```

Immediately after checkout, the workflow runs:

```text
git rev-parse HEAD
```

and creates/uploads:

```text
source-<COMMIT_SHA>.tar.gz
source-code-<COMMIT_SHA>
```

The archived Actions metadata for run `22308909844` records the source artifact:

```text
source-code-8874eaa3994f0e7e40fa40312250bbc5f13cc928
```

Therefore the strongest available public evidence identifies the source checkout
used by the signed build as:

```text
8874eaa3994f0e7e40fa40312250bbc5f13cc928
```

That commit exists in the upstream repository and is the commit whose source the
workflow intentionally archived before compilation.

## Why the three SHAs must not be conflated

They serve different roles:

```text
8874eaa3994f0e7e40fa40312250bbc5f13cc928
    exact checkout/source artifact named by the build workflow

3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa
    master workflow revision that invoked checkout/build

6a308eccf6ae4fbc3cdcf267c3a525b4818824e3
    later v2.0 release tag commit, including root GPLv2 license text
```

Public redistribution documentation must not say that the binary was simply
"built from tag v2.0" unless additional upstream evidence establishes that.

## License lineage evidence

The upstream v2.0 tag contains the full GNU General Public License, version 2.

The upstream project README identifies the project as a fork/continuation of:

```text
imbushuo/mac-precision-touchpad
```

The original `imbushuo/mac-precision-touchpad` README explicitly states:

```text
USB driver: GPLv2
SPI driver: MIT
```

The payload redistributed by Magic Trackpad for Windows is the upstream
MagicTrackpad2ForWindows package, not the original SPI package.

Source inspection of representative `MagicTrackpad2ForWindows` driver files did
not find per-file SPDX/license headers. Repository search likewise did not find
an explicit `SPDX-License-Identifier` declaration.

Because the upstream root license text and the shorthand "GPLv2" do not provide
the same precision as an explicit SPDX notice distinguishing
`GPL-2.0-only` from `GPL-2.0-or-later`, this project will not invent that
distinction in OSS-1.3A.

## Recommended corresponding-source release payload

For any future public release that redistributes
`MT2FW11-20260223-MSSigned.zip`, the conservative engineering plan is to make
source available alongside the binary release, containing at minimum:

1. an archive of upstream source commit:

   ```text
   8874eaa3994f0e7e40fa40312250bbc5f13cc928
   ```

2. the exact build workflow definition from:

   ```text
   3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa
   ```

3. the applicable GNU GPL version 2 license text preserved from the v2.0
   upstream release;

4. a provenance manifest recording:
   - upstream repository;
   - release/tag;
   - signed binary asset name;
   - signed binary SHA256;
   - Actions run ID;
   - source checkout SHA;
   - workflow SHA;
   - source-archive SHA256.

This is intentionally stronger than relying only on a hyperlink to the current
upstream repository. The distributor should be able to preserve the exact source
needed for the binary it redistributes even if upstream branches/tags later
change or disappear.

## Policy status

OSS-1.3B selected MIT (`SPDX: MIT`) for project-authored wrapper code and
original documentation while keeping the upstream driver under its own GPLv2
terms.

OSS-1.3C implements the repository license files and controlled release/source
bundle tooling.

This remains an engineering/open-source compliance position rather than a
binding legal determination about derivative-work boundaries. Reopen the
analysis if future architecture directly incorporates, links, or modifies
GPL-covered upstream source.

A public binary release remains a separate, explicit action and must pass the
release-bundle verifier.

## OSS-1.3C implementation evidence

On 2026-08-16, `refs/heads/ossign` was re-checked and still resolved to:

```text
8874eaa3994f0e7e40fa40312250bbc5f13cc928
```

That is supporting evidence only. The release tooling archives the immutable
source commit directly and does not require the mutable `ossign` branch to remain
at that commit forever.

The future corresponding-source ZIP is built from the exact commit above and is
augmented only with explicitly named redistribution metadata:

- GNU GPL version 2 license text;
- the preserved build workflow from
  `3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa`;
- a source-origin text record.

These additions do not replace or rewrite upstream source files; they make the
redistribution package self-describing.

`Build-ReleaseBundle.ps1` records SHA256 values for the wrapper source archive,
upstream corresponding-source archive, and preserved workflow in
`UPSTREAM_PROVENANCE.txt`, and `Verify-ReleaseBundle.ps1` checks them before a
release bundle is accepted.
