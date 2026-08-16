# OSS-1.7A dev.6.0 source-version transition

This phase starts the first public-binary prerelease line after repository
publication.

## Version identity

Current source version:

```text
0.1.0-dev.6.0
```

Last fully validated binary baseline:

```text
v0.1.0-dev.5.4.2
```

The dev.5.4.2 artifact remains immutable and retains its frozen Setup SHA256:

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

## Scope

This transition:

- bumps root `VERSION` and Inno `MyAppVersion` to `0.1.0-dev.6.0`;
- updates public status text to distinguish current source version from the last
  fully validated binary baseline;
- updates SECURITY and bug-report version guidance;
- updates the OSS roadmap for the first public prerelease;
- makes the public README verifier derive the active version from `VERSION`.

It intentionally does not:

- alter the pinned upstream driver or its SHA256;
- change install/uninstall/helper behavior;
- remove or weaken the dev.5.4.2 same-version rebuild guard;
- publish a binary Release;
- claim dev.6.0 validation before regression testing.

## Screenshot timing

The existing screenshot set remains temporarily in place.

English and Simplified Chinese screenshots will be captured from the actual
dev.6.0 candidate installer after the first candidate build, so repository
screenshots correspond to the release candidate rather than an earlier binary.
