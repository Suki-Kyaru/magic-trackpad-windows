# VM clean-install validation documentation patch

This patch records the first successful clean Windows 11 x64 installer lifecycle validation for `v0.1.0-dev.5.1`.

Validated:

- no matching driver before install;
- `not-installed -> current`;
- one matching Driver Store package after install;
- dynamically assigned Published INF (`oem8.inf`);
- no physical Magic Trackpad required for Driver Store preinstallation;
- second Setup invocation remains idempotent;
- installed driver count remains exactly one.

Documentation only. No source, driver, installer, registry, device or VERSION changes are included.
