# Third-party notices

Magic Trackpad for Windows contains project-authored wrapper code and a separate
third-party driver/control-panel payload.

## MagicTrackpad2ForWindows

Upstream project:

```text
vitoplantamura/MagicTrackpad2ForWindows
```

Pinned redistributed release:

```text
Release: v2.0
Asset: MT2FW11-20260223-MSSigned.zip
SHA256: 2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

The upstream payload is redistributed **unmodified**. The Microsoft-signed
INF/CAT/SYS/DLL payload is not edited or re-signed by this wrapper project.

Upstream licensing is described conservatively here as **GPLv2**. A copy of GNU
GPL version 2 license text is provided at:

```text
licenses/GPL-2.0.txt
```

The upstream component is **not** relicensed under the MIT License by this
project. The MIT License covers project-authored Magic Trackpad for Windows
wrapper code and original documentation.

## Corresponding source / build provenance

Strongest preserved public evidence for the signed-build source checkout:

```text
source commit:
8874eaa3994f0e7e40fa40312250bbc5f13cc928

workflow commit:
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa

v2.0 tag commit:
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3

GitHub Actions run:
22308909844
```

Public binary releases produced by this project publish the exact corresponding
upstream source archive and preserved build-workflow snapshot alongside the
binary bundle.

See:

- `docs/oss/UPSTREAM_SOURCE_PROVENANCE.md`
- `docs/oss/RELEASE_COMPLIANCE.md`

## Lineage / credits

`MagicTrackpad2ForWindows` identifies itself as a fork/continuation of
`imbushuo/mac-precision-touchpad`. Upstream also credits additional contributors
and reverse-engineering work in its own README.

Do not represent upstream driver implementation or signing work as authored by
Magic Trackpad for Windows.

## License boundary

The root `LICENSE` applies to project-authored wrapper material. It does not
replace or supersede third-party license terms.

This notice is an engineering/open-source redistribution record, not legal
advice.
