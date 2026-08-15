# OSS Productization Roadmap After dev.5.4.2

The driver lifecycle and first user-facing installer/uninstaller are now
validated.

The next phase should improve the repository as a public-maintenance project
without changing the frozen low-level lifecycle unless a real defect requires
it.

## OSS-1 Repository foundation

- Review and rewrite README for public users and contributors.
- Clearly state supported hardware and Windows versions.
- Add architecture overview.
- Add quick install and manual troubleshooting paths.
- Add screenshots of the accepted Windows 11 installer.
- Explain the relationship to MagicTrackpad2ForWindows upstream.
- Document what is original wrapper/helper work versus upstream driver work.

## OSS-2 Licensing and redistribution

- Confirm repository license expression.
- Include the applicable GPL-2.0 license text.
- Review THIRD_PARTY_NOTICES.
- Document upstream source location and corresponding-source availability.
- Ensure redistributed binaries satisfy upstream license obligations.
- Keep Microsoft-signed driver payload byte-for-byte unchanged.

## OSS-3 Contributor workflow

Add:

- CONTRIBUTING.md
- SECURITY.md
- issue templates
- pull request template
- development environment instructions
- validation matrix
- coding/PowerShell/Inno conventions
- "do not weaken" safety contracts for contributors and coding agents

## OSS-4 CI and reproducibility

Automate:

- C++ configure/build
- static verifier scripts
- Windows PowerShell 5.1 compatibility checks where available
- installer compilation
- payload hash/signature validation
- artifact SHA256 generation
- clean-source / no-runtime-log gates

CI should not invent or silently replace the pinned upstream driver payload.

## OSS-5 Release engineering

Produce a reproducible release bundle containing:

- Setup executable
- SHA256SUMS
- release notes
- license / notices
- source/reference information

Later:

- wrapper code signing
- GitHub Releases
- public beta support process

## Deferred

Do not mix into the immediate OSS phase:

- ARM64 support without real hardware validation
- driver upgrade/downgrade automation
- MI_00 hacks
- custom kernel-driver rewrites
- unrelated control-panel redesign

The strongest value of the project is currently safe packaging, diagnostics,
lifecycle management, and maintainable Windows integration around a validated
upstream driver.
