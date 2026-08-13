# v0.1.0-dev.5 First Inno Setup Contract

This stage produces the first real `Setup.exe`.

Scope:

- Windows 11 x64 only.
- Requires administrator elevation.
- Uses the already-staged and verified upstream v2.0 driver payload.
- Runs the tested safe install gate before normal application file deployment.
- Current driver -> no-op.
- Not installed -> install the pinned Microsoft-signed package.
- Older/newer/multiple packages -> stop instead of guessing.
- Installs the upstream control panel.
- Creates Start Menu shortcuts.
- Uninstaller removes only the wrapper/control-panel files for now.

Explicitly deferred:

- ARM64 installer support.
- driver uninstall.
- automatic driver upgrade/cleanup.
- MI_00 workaround.
- Bluetooth pairing automation.
- gesture modification.
- custom modern control panel.
- wrapper Setup.exe code signing.

The public wrapper installer should not be released broadly until:

1. a clean Windows x64 machine validates `not-installed -> installed`;
2. the wrapper itself has a release/signing strategy;
3. GPL source-availability packaging is finalized.
