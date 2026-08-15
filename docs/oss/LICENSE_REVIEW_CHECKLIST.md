# License / Redistribution Review Checklist

Status: NOT YET FINALIZED

This document is an engineering/legal-review checklist, not a final license
decision.

## Verified upstream facts as of 2026-08-16

The upstream repository:

```text
vitoplantamura/MagicTrackpad2ForWindows
```

is publicly identified by GitHub as GPL-2.0 and contains a GNU GPL version 2
license file.

The currently pinned upstream release in this project is v2.0.

These facts do not, by themselves, settle every license-expression question for
this wrapper repository.

## Before creating the root LICENSE file

Review all of the following:

1. Upstream source-file license notices.
   - Determine whether relevant files specify GPL version 2 only, or version 2
     "or any later version".
   - Do not infer `GPL-2.0-only` versus `GPL-2.0-or-later` from GitHub's short
     repository label alone.

2. Upstream lineage.
   - Review inherited notices from the imbushuo project where applicable.
   - Preserve author/copyright/license notices.

3. Binary redistribution model.
   - This installer redistributes the upstream Microsoft-signed binaries.
   - Confirm the exact source-availability mechanism supplied to recipients.
   - Preserve the upstream signed payload byte-for-byte.

4. Wrapper/helper licensing.
   - Decide the license expression for the code authored in this repository
     only after compatibility/aggregation/derivative-work questions have been
     reviewed.
   - Do not imply that choosing a wrapper license can reduce obligations that
     apply to redistributed GPL-covered components.

5. Installer distribution contents.
   Before public release, verify the distributed package/source materials
   include or clearly provide:
   - applicable GPL v2 license text;
   - upstream attribution;
   - upstream source / corresponding-source access as required;
   - third-party notices;
   - clear separation between upstream driver authorship and wrapper authorship.

6. Release reproducibility.
   - Record exact upstream release/tag/asset.
   - Record SHA256.
   - Record corresponding source revision/tag.

## Current rule

Do not add a root `LICENSE` file merely to make the repository look complete.

OSS-1.3 will perform the license/source-distribution review and then make the
explicit repository license decision.
