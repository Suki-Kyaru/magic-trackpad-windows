# OSS-1.7B.2 bilingual screenshot contract

The first public-binary prerelease line now has a language-matched README
screenshot set captured from the dev.6.0 Candidate 1 UI.

## Assets

English:

- `installer-information-en.png`
- `installer-destination-en.png`
- `uninstall-connected-guard-en.png`

Simplified Chinese:

- `installer-information-zh-cn.png`
- `installer-destination-zh-cn.png`
- `uninstall-connected-guard-zh-cn.png`

The English README references only English screenshots. The Simplified Chinese
README references only Simplified Chinese screenshots.

`Verify-PublicReadme.ps1` now requires all six assets, verifies they are non-empty,
and rejects cross-language README screenshot references.

## Candidate 1 evidence already observed

The dev.6.0 Candidate 1 installer was built successfully with wrapper Setup
SHA256:

```text
b8a3d937e2aaed436697573843a0e3d21294f312cbff9e202c5c6c5f198bbe6a
```

Basic smoke validation observed:

- clean-VM install from `not-installed` to `current`;
- application-only uninstall kept the driver;
- reinstall with the current exact driver used the NO-OP Driver Store path;
- the exact target Driver Store package count remained one;
- real-host connected-device removal request failed closed and kept the driver;
- both English and Simplified Chinese connected-device guard dialogs were
  captured without allowing real driver removal to proceed.

These observations do not replace the remaining complete release regression.
