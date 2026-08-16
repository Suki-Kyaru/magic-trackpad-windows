# OSS-1.7C Candidate 1 validation closure

This phase records the completed dev.6.0 Candidate 1 behavioral validation
without changing runtime code.

Evidence recorded:

- clean-VM install from `not-installed` to one exact current package;
- application-only uninstall kept the driver;
- reinstall with current driver used the Driver Store NO-OP path;
- VM real safe driver removal exported and verified INF/CAT/DLL/SYS before
  deleting the dynamically discovered package without `/force`;
- post-removal verification returned `not-installed`;
- reinstall after removal returned to one exact current package while preserving
  the safety backup;
- physical-host A3120 connected-device removal failed closed with
  `remove.executed=false`, `other_apple_drivers_touched=false`, and
  `result=connected`;
- English and Simplified Chinese candidate screenshots were captured.

Candidate 1 Setup SHA256:

```text
b8a3d937e2aaed436697573843a0e3d21294f312cbff9e202c5c6c5f198bbe6a
```

Raw machine/user/Bluetooth identifiers are not copied into repository
documentation.

The publishable dev.6.0 binary remains pending because repository documentation
and screenshot assets advanced after Candidate 1 was built. A final candidate
must be rebuilt from the final clean HEAD and verified through the controlled
release-bundle path.
