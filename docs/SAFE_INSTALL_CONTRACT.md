# v0.1 Safe Install Contract — dev.4

dev.4 introduces the first write-capable path, but only for a clean
`not-installed` state.

## Current supported install states

- `current`:
  - return success
  - perform no driver-store write
- `not-installed`:
  - verify the exact upstream v2.0 payload
  - call Windows `pnputil /add-driver <INF> /install`
  - re-run the read-only driver-store probe
  - success only if the expected current package is then detected
- `older`:
  - stop; automatic upgrade is not implemented yet
- `newer`:
  - stop; never silently downgrade
- `multiple-packages`:
  - stop; automatic cleanup is not implemented yet

## Payload trust

`Prepare-DriverPayload.ps1` accepts only the official upstream v2.0 ZIP whose
SHA256 is:

`2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f`

It then checks:

- expected release file layout
- expected driver/provider/version text
- valid Authenticode status for the catalog and kernel driver
- generated per-file SHA256 manifest for later local integrity checks

The Microsoft-signed driver files are never edited or re-signed.

## Architecture

dev.4 installation is deliberately limited to AMD64 because that is the only
architecture currently validated on real hardware in this project.

ARM64 payload may be staged and verified, but install enablement is deferred
until an ARM64 Windows machine is available for real validation.

## Important

The current user's known-good machine should validate only the `current -> no-op`
path. Do not uninstall the working driver merely to test the clean-install path.

A real `not-installed -> installed` test should be performed later on a separate
clean Windows machine.
