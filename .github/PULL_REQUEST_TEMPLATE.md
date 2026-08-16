## Summary

What changed, and why?

## Risk area

- [ ] Documentation / repository metadata
- [ ] Build / release tooling
- [ ] C++ helper / state contracts
- [ ] Installed PowerShell runtime
- [ ] Installer UI / flow
- [ ] Driver install/remove safety
- [ ] Licensing / third-party boundary

## Safety contract impact

- [ ] No frozen installer/driver safety behavior changed
- [ ] Dynamic `oemN.inf` discovery preserved
- [ ] No generic Apple-driver deletion introduced
- [ ] No `/force` introduced in normal removal
- [ ] Upstream signed payload remains unmodified
- [ ] If a safety contract changed, the PR explains why and updates validation

## Validation

### Validated

-

### Not run

-

### Reason not run

-

## Privacy / repository hygiene

- [ ] No raw machine-specific logs, driver backups, staged third-party binaries, secrets, or build artifacts are committed
- [ ] `git diff --check` passes
- [ ] Relevant verifier(s) pass

## Release/version note

- [ ] This change does not attempt to rebuild/reissue frozen `v0.1.0-dev.5.4.2` or `v0.1.0-dev.6.0`
- [ ] If an installer build is intended, `VERSION` and `installer/setup.iss` use the same new version
