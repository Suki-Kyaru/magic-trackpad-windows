# dev.5.4.1 R4 - ReviewMessage local-scope compile hotfix

R3 compiled successfully through the earlier Pascal Script fixes and then
stopped at `ReviewMessage` inside `InitializeUninstall`.

Root cause:

- R3 intended to declare `ReviewMessage` in `InitializeUninstall`;
- the patch operation matched the first `Started: Boolean;` declaration in the
  script, which belongs to `PrepareToInstall`;
- therefore `ReviewMessage` was out of scope when referenced by the uninstaller.

R4:

- removes `ReviewMessage` from `PrepareToInstall`;
- declares it in `InitializeUninstall`;
- adds a verifier contract that inspects both function-local `var` blocks.

No version bump is required because dev.5.4.1 has not produced a successful
installer build yet.

No changes are made to:

- `modern dynamic windows11`;
- language auto detection;
- Simplified Chinese / English resources;
- uninstall preview behavior;
- Driver Store install/remove core;
- real driver deletion (still not wired in dev.5.4.1).
