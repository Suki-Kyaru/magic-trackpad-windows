# Documentation Index

This directory contains the maintained technical documentation for
Magic Trackpad for Windows.

The repository deliberately separates current contracts and validation evidence
from raw development history.

## Start here

For contributors and coding agents:

- `OSS_INSTALLER_UX_BASELINE.md`
  - frozen installer UX principles and safety boundaries
- `DEV5_4_2_USER_SAFE_UNINSTALL_CONTRACT.md`
  - current user-safe uninstall contract
- `DEV5_4_2_USER_SAFE_UNINSTALL_VALIDATION.md`
  - real VM + physical-host validation evidence
- `OSS_PRODUCTIZATION_ROADMAP.md`
  - public-repository productization roadmap
- `oss/REPOSITORY_STRUCTURE.md`
  - public repository information architecture
- `oss/README_PUBLIC_BLUEPRINT.md`
  - blueprint for the public-facing README
- `oss/LICENSE_REVIEW_CHECKLIST.md`
  - license/source-availability review before public redistribution

## Driver / device contracts

- `STATUS_PROBE_CONTRACT.md`
- `DRIVER_STORE_PROBE_CONTRACT.md`
- `SAFE_INSTALL_CONTRACT.md`
- `LOGGING_AND_UNINSTALL_DRY_RUN_CONTRACT.md`
- `VM_REAL_DRIVER_REMOVAL_CONTRACT.md`

## Validation baselines

- `VALIDATION_BASELINE.md`
- `VM_CLEAN_INSTALL_VALIDATION.md`
- `DEV5_3_DRIVER_LIFECYCLE_VALIDATION.md`
- `DEV5_4_1_INSTALLER_PREVIEW_VALIDATION.md`
- `DEV5_4_2_USER_SAFE_UNINSTALL_VALIDATION.md`

## Windows PowerShell / diagnostics

- `WINDOWS_POWERSHELL_51_COMPATIBILITY.md`
- `WINDOWS_POWERSHELL_51_SOURCE_ENCODING.md`
- `WINDOWS_POWERSHELL_51_EMPTY_LINES.md`
- `DIAGNOSTICS_ENCODING_PRIVACY.md`
- `INSTANCE_ID_REDACTION.md`
- `RUNTIME_LOG_SHARING_POLICY.md`

## Installer UX evolution

These documents explain design decisions that led to the currently frozen
installer layout:

- `DEV5_4_1_LANGUAGE_UNINSTALL_PREVIEW.md`
- `DEV5_4_1_R6_INSTALL_FLOW.md`
- `DEV5_4_1_R7_INSTALL_INFO_COPY.md`
- `DEV5_4_1_R8_SPACING_RHYTHM.md`
- `DEV5_4_1_R9_GEOMETRY_BASELINE.md`
- `DEV5_4_1_R10_LOCAL_COORDINATES.md`
- `DEV5_4_1_R10_1_CONTENT_TOP_TUNING.md`
- `DEV5_4_1_R10_2_INFOBEFORE_TUNING.md`
- `DEV5_4_1_R10_3_PREVIEW_AUDIT_LOG.md`

## History

- `DEVELOPMENT_HISTORY.md`
  - curated early development history
- `history/`
  - raw patch notes and legacy installer copy retained for traceability

Raw history is useful evidence, but it should not be treated as the current
product contract when a newer maintained document exists.

## Public repository entry points

- [`../README.md`](../README.md)
  - public English project overview
- [`../README.zh-CN.md`](../README.zh-CN.md)
  - Simplified Chinese project overview

## OSS licensing / redistribution

- `oss/UPSTREAM_SOURCE_PROVENANCE.md`
  - exact upstream signed-build/source provenance evidence
- `oss/LICENSE_REVIEW_CHECKLIST.md`
  - implemented license/source-distribution gates and remaining release work
- `oss/LICENSE_POLICY_DECISION.md`
  - MIT policy for project-authored wrapper content and explicit third-party
    GPL separation
- `oss/RELEASE_COMPLIANCE.md`
  - controlled binary/source bundle process and frozen dev.5.4.2 build guard
- `../licenses/README.md`
  - repository MIT versus third-party GPL license-file map
