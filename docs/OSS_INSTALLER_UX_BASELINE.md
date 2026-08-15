# OSS Maintenance Note: Installer UX Baseline

The dev.5.4.1 installer is intentionally treated as a contract, not a collection
of ad-hoc pixel tweaks.

Future contributors and coding agents should preserve these boundaries:

1. Driver lifecycle safety lives below the UI layer.
2. The installer UI localizes machine states; runtime scripts remain
   language-neutral where practical.
3. Published INF names are dynamic evidence, never constants.
4. The destination folder remains user-selectable.
5. Page-body geometry is calculated only within the page's own coordinate
   system.
6. User-facing preview actions must leave auditable machine-readable evidence.
7. Preview mode must never silently evolve into destructive mode.

If the installer visual design changes later, add or update verification
contracts rather than deleting the existing safety checks to make a build pass.
