# OSS-1.3B License Policy Decision

The project author approved:

```text
Project-authored wrapper code/docs:
MIT (SPDX: MIT)
Copyright (c) 2026 Suki-Kyaru

Third-party MagicTrackpad2ForWindows:
retain upstream GPLv2 terms
not relicensed by this repository
```

The current architecture is managed as separate works packaged together:
wrapper/helper/installer code does not link upstream driver source and deploys
the signed upstream driver as a distinct package.

This policy is informed by GNU GPL FAQ guidance on installers and aggregation
but is recorded as an engineering/open-source compliance policy, not legal
advice or a court determination.

OSS-1.3B deliberately does not add the root LICENSE yet.

OSS-1.3C will atomically implement the MIT LICENSE, separate GPLv2 text, final
THIRD_PARTY_NOTICES, exact corresponding-source packaging, provenance manifest,
SHA256 manifest, and release compliance verifier.

No driver/install/uninstall runtime behavior changed in OSS-1.3B.
