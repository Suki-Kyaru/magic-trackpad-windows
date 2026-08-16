# OSS-1.3C License / Source Distribution Implementation

OSS-1.3C implements the licensing and controlled release/source-distribution
policy decided in OSS-1.3B.

Added:

- root MIT `LICENSE` for project-authored wrapper code/docs;
- `licenses/GPL-2.0.txt` and license map;
- final `THIRD_PARTY_NOTICES.md`;
- updated third-party staging documentation;
- `docs/oss/RELEASE_COMPLIANCE.md`;
- release bundle builder and verifier;
- static license-distribution verifier;
- release/source provenance closure.

Frozen upstream identities:

```text
upstream source:
8874eaa3994f0e7e40fa40312250bbc5f13cc928

upstream workflow:
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa

v2.0 tag:
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3

Actions run:
22308909844

pinned binary SHA256:
2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

## Frozen dev.5.4.2 protection

OSS-1.3C deliberately does **not** modify `installer/setup.iss`.

The validated `v0.1.0-dev.5.4.2` Setup remains identified by:

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

Because the OSS branch now contains post-tag files such as updated notices and
release tooling, rebuilding under the old version could create a different
binary with the same version identity.

`Build-Installer.ps1` and `Build-ReleaseBundle.ps1` therefore fail closed while
root `VERSION` remains `0.1.0-dev.5.4.2`.

The next real installer build must use a new version and keep root `VERSION` and
Inno `MyAppVersion` synchronized.

## Binary publication model

The controlled release flow publishes a binary ZIP rather than a naked Setup
asset.

That ZIP contains Setup plus MIT/GPL/third-party/provenance/source-availability
material. Exact wrapper source and upstream corresponding source are published
alongside it.

No Driver Store, device-state, safe-install, safe-uninstall, or accepted Win11
installer-layout algorithm is changed by OSS-1.3C.

OSS-1.3C implements tooling only; it does not publish a public release.
