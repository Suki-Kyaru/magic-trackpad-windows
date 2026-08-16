# Release Compliance

Status: IMPLEMENTED IN OSS-1.3C; NO PUBLIC BINARY RELEASE YET

This document defines the controlled release/source-distribution process for
Magic Trackpad for Windows.

It is an engineering/open-source compliance process, not legal advice.

## Frozen dev.5.4.2 boundary

`v0.1.0-dev.5.4.2` is already a validated artifact.

Frozen Setup SHA256:

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

OSS productization changes occur **after** that tag. Rebuilding the post-tag
source under the same version would create a different binary with the same
identity, so the current build scripts deliberately reject
`VERSION=0.1.0-dev.5.4.2`.

OSS-1.3C does not modify `installer/setup.iss`.

The next actual installer build must first use a new version, with root `VERSION`
and Inno `#define MyAppVersion` updated together.

## Publishable binary unit

A naked `Setup.exe` is not the publishable binary asset produced by this release
flow.

The release builder creates:

```text
MagicTrackpad-for-Windows-<version>-x64-binary.zip
```

The binary ZIP contains:

```text
MagicTrackpad-for-Windows-Setup-<version>-x64.exe
LICENSE
GPL-2.0.txt
THIRD_PARTY_NOTICES.md
UPSTREAM_PROVENANCE.txt
SOURCE_AVAILABILITY.txt
```

This keeps license/notice/provenance material with the distributed binary while
leaving the already-frozen dev.5.4.2 Setup untouched.

Do not upload the raw `out/installer/*.exe` as a standalone public release asset.

## Public release directory

After a future version bump and clean committed source state,
`Build-ReleaseBundle.ps1` creates:

```text
MagicTrackpad-for-Windows-<version>-x64-binary.zip
MagicTrackpad-for-Windows-source-<version>.zip
MagicTrackpad2ForWindows-corresponding-source-8874eaa3994f.zip
UPSTREAM_BUILD_WORKFLOW-3611b8c6f4fa.yml
UPSTREAM_PROVENANCE.txt
SHA256SUMS.txt
```

Upload the verified files from that release directory together.

## Build flow

### 1. Stage the pinned signed driver payload

```powershell
.\scripts\Prepare-DriverPayload.ps1 `
    -SourceZip "C:\path\to\MT2FW11-20260223-MSSigned.zip"

.\scripts\Verify-DriverPayload.ps1
```

### 2. Use a new wrapper version

Before any post-dev.5.4.2 installer build:

- update root `VERSION`;
- update `#define MyAppVersion` in `installer/setup.iss` to exactly the same
  version;
- commit the intended source state;
- keep the working tree clean.

### 3. Build the controlled release assets

```powershell
.\scripts\Build-ReleaseBundle.ps1
```

The release builder runs `Build-Installer.ps1` itself.

It then:

1. requires a clean committed wrapper working tree;
2. archives the wrapper's committed source;
3. fetches/uses exact upstream source commit
   `8874eaa3994f0e7e40fa40312250bbc5f13cc928`;
4. preserves the build-workflow snapshot from
   `3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa`;
5. augments the upstream corresponding-source ZIP with clearly named GPL/build
   provenance files without modifying upstream source files;
6. creates machine-readable `UPSTREAM_PROVENANCE.txt`;
7. packages Setup with MIT/GPL/third-party/provenance/source-availability
   material into the binary ZIP;
8. creates `SHA256SUMS.txt`;
9. runs `Verify-ReleaseBundle.ps1`.

## Upstream evidence

Frozen roles:

```text
signed-build source checkout:
8874eaa3994f0e7e40fa40312250bbc5f13cc928

workflow revision:
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa

later v2.0 tag:
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3

Actions run:
22308909844
```

The release tooling archives immutable commits directly. It does not require the
mutable `ossign` branch to remain forever at the historical source commit.

## Upstream repository cache

Default cache:

```text
out/release-cache/MagicTrackpad2ForWindows/
```

A known upstream checkout can instead be supplied:

```powershell
.\scripts\Build-ReleaseBundle.ps1 `
    -UpstreamRepoPath "D:\Dev\MagicTrackpad2ForWindows-upstream"
```

The repository origin and required immutable commits are verified.

## Verification

A release directory is publishable only if:

```powershell
.\scripts\Verify-ReleaseBundle.ps1 `
    -ReleaseDir "<release directory>"
```

passes.

Among other checks, the verifier ensures:

- no naked Setup executable exists at release root;
- every public release file is covered exactly once by SHA256SUMS;
- binary ZIP carries MIT/GPL/third-party/provenance/source-availability files;
- source/provenance hashes close;
- wrapper source excludes local `build/`, `out/`, and staged upstream binaries;
- exact upstream source contains expected driver/build inputs;
- upstream package declarations preserve Windows SDK/WDK
  `10.0.26100.6584`.

## Current expected behavior

Immediately after OSS-1.3C, running `Build-Installer.ps1` or
`Build-ReleaseBundle.ps1` while `VERSION` is still `0.1.0-dev.5.4.2` should
**fail deliberately before rebuilding**.

That failure is a safety gate, not a regression.
