# Repository Structure

## Goal

Keep the repository root useful to a first-time user while preserving the
project's unusually detailed validation history.

## Root

The public root should contain only high-signal project entry points and build
metadata, such as:

```text
README.md
LICENSE                  MIT for project-authored wrapper material
THIRD_PARTY_NOTICES.md
CONTRIBUTING.md           (later OSS phase)
SECURITY.md               (later OSS phase)
CMakeLists.txt
VERSION
.gitattributes
.gitignore
```

Runtime/build source directories remain:

```text
helper/
installer/
scripts/
third_party/
licenses/
docs/
.github/                  (later OSS phase)
```

## Build artifacts

Local-only:

```text
build/
out/
.vs/
third_party/MagicTrackpad2ForWindows-v2.0/
```

These must not become tracked source files.

## Documentation

`docs/README.md` is the documentation navigation entry point.

Current technical contracts and validation evidence stay directly under
`docs/` for now.

Raw implementation history belongs under:

```text
docs/history/
```

OSS planning/review material belongs under:

```text
docs/oss/
```

## Historical patch notes

All former repository-root:

```text
PATCH_NOTES*.md
```

move to:

```text
docs/history/patch-notes/
```

Git history remains authoritative for the move.

## Retired installer copy

The old unreferenced:

```text
installer/INFO_BEFORE.txt
```

moves to:

```text
docs/history/legacy/INFO_BEFORE.dev5.1.txt
```

Current localized installer resources remain:

```text
installer/INFO_BEFORE.en.txt
installer/INFO_BEFORE.zh-CN.txt
```

## Rule for coding agents

Do not create new `PATCH_NOTES_*.md` files in the repository root.

For future development history, prefer:

- a focused maintained document in `docs/`, or
- `docs/history/patch-notes/` for raw phase notes.

Do not delete safety/validation history merely to make the repository look
smaller.


## License / release assets

Repository licensing is implemented as:

```text
LICENSE
licenses/GPL-2.0.txt
THIRD_PARTY_NOTICES.md
docs/oss/UPSTREAM_SOURCE_PROVENANCE.md
docs/oss/RELEASE_COMPLIANCE.md
```

The root MIT license does not relicense the locally staged upstream driver
payload.

Publishable binary/source bundles are generated only under ignored `out/`
paths. A naked Setup executable is not the public release unit defined by the
release-compliance flow.

The frozen dev.5.4.2 artifact must not be rebuilt from post-tag source under the
same version number.
