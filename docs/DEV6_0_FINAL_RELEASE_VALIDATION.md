# dev.6.0 Final Public Prerelease Validation

## Status

Final public prerelease: **PASS / PUBLISHED**

GitHub Release:

```text
v0.1.0-dev.6.0
```

Published:

```text
2026-08-16T08:56:26Z
2026-08-16 16:56:26 +08:00
```

This document records the final published artifact identity and focused
final-binary validation. Candidate 1 remains the wider lifecycle and behavioral
reference and is preserved separately in
`DEV6_0_CANDIDATE1_RELEASE_VALIDATION.md`.

## Final source and tag identity

Final wrapper source commit and tag target:

```text
4ea2db6dc7ba1f7998f735d56ce1158c9b2be420
```

Annotated tag:

```text
v0.1.0-dev.6.0
```

Annotated tag object:

```text
c9c308d9eeb0e24718297c45d53db73640e01170
```

GitHub Release ID:

```text
371276646
```

The published Release is public (`draft=false`) and remains marked as a
prerelease (`prerelease=true`).

## Final Setup identity

Final Setup:

```text
MagicTrackpad-for-Windows-Setup-0.1.0-dev.6.0-x64.exe
```

Final Setup SHA256:

```text
f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791
```

The outer Setup wrapper is currently not code-signed (`NotSigned`).

The embedded upstream driver CAT/SYS payload remains the original
Microsoft-signed payload and is verified separately by the project tooling.

The final release bundle was built once from the final clean source state.
After the final Setup identity was locked, release verification was read-only;
the published dev.6.0 identity must not be rebuilt or reissued.

## Published controlled assets

| Asset | Size (bytes) | SHA256 |
| --- | ---: | --- |
| `MagicTrackpad-for-Windows-0.1.0-dev.6.0-x64-binary.zip` | 2393522 | `b8b8e3229f4d538f8882d79dd1610dd7788ccb09396516b15f5ab33f7b314d49` |
| `MagicTrackpad-for-Windows-source-0.1.0-dev.6.0.zip` | 508550 | `62bc66755389a01eacac424a4942a8a405199622ad19b0aae9ab10ec0d145982` |
| `MagicTrackpad2ForWindows-corresponding-source-8874eaa3994f.zip` | 263848 | `4ca3f026d357b454099659eef415405c78014ccecdae9e55e56e32e9526d94c6` |
| `SHA256SUMS.txt` | 569 | `95750f4de64c2b9b18f6a89d7053b57d4438ee3752c233fd45c8dd2e16e6a1a1` |
| `UPSTREAM_BUILD_WORKFLOW-3611b8c6f4fa.yml` | 4023 | `972d651479dfabf13a21b778aed795662831beecad2a8d46d4ac667c345960c3` |
| `UPSTREAM_PROVENANCE.txt` | 1257 | `adfbca7529c62dd588b9515d7c58a8f57220d1f6d537c20bd8e482dee8c277b9` |

`SHA256SUMS.txt` does not list its own hash; the value above is the GitHub
server-side SHA256 digest of the uploaded asset.

## Final exact-binary validation

The exact final Setup completed focused validation on a clean Windows 11 x64 VM:

- clean installation: **PASS**;
- expected driver installation and post-install verification: **PASS**;
- exact expected Driver Store package reached the current state: **PASS**;
- reinstall with the current driver already present: **PASS**;
- Driver Store NO-OP behavior: **PASS**.

The wider Candidate 1 validation already covered:

- application-only uninstall while preserving the driver;
- safe real driver removal in a VM;
- export-before-delete and four-file backup verification;
- real removal without `/force`;
- post-delete `not-installed` verification;
- reinstall after real removal;
- physical Windows 11 x64 + Apple USB-C Magic Trackpad A3120
  connected-device fail-closed behavior.

The final release source changes after the behavioral candidate did not alter
installer, helper, or driver-lifecycle behavior. The final exact binary therefore
received focused identity, clean-install, and current-driver NO-OP validation
without repeating destructive driver deletion.

## Publication audit

Before publication, the GitHub Release was created as a Draft prerelease and
audited remotely.

The pre-publication audit confirmed:

- correct tag and title;
- `draft=true` before publication;
- `prerelease=true`;
- exactly six controlled uploaded assets;
- expected asset names and sizes;
- GitHub server-side SHA256 digests matching the locked local identities;
- complete bilingual release notes.

After that audit, the Draft was published. A post-publication read-only audit
confirmed:

- `draft=false`;
- `prerelease=true`;
- published timestamp present;
- all six assets remained uploaded;
- asset sizes and SHA256 digests remained unchanged.

## Validated project scope

The wrapper project's validated release scope remains:

```text
Windows 11 x64
Apple USB-C Magic Trackpad A3120
```

ARM64 wrapper/install lifecycle is not yet validated.

Windows 10 wrapper/install lifecycle is not currently claimed as
project-validated support.

## Freeze and next source line

`v0.1.0-dev.6.0` is now a frozen published release identity.

Do not rebuild or republish a different binary under that version.

Post-release development moves to:

```text
0.1.0-dev.6.1
```

Any later public binary requires its own version, clean committed source,
controlled release bundle, validation evidence, and publication audit.
