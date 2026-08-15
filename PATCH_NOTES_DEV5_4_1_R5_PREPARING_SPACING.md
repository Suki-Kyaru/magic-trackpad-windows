# dev.5.4.1 R5 - Preparing-page spacing hotfix

Visual VM review of the built-in:

`WizardStyle=modern dynamic windows11`

was accepted overall.

One small issue remained on the "Preparing to Install" page: the secondary
description line sat slightly too close to the bold page heading.

R5 changes only that layout detail:

```text
WizardForm.PreparingLabel.Top += ScaleY(6)
```

The adjustment is applied once in `InitializeWizard`, so it cannot accumulate
if Setup revisits the Preparing page.

No changes are made to:

- Windows 11 wizard style;
- dark/light dynamic behavior;
- Simplified Chinese / English localization;
- language auto detection;
- install logic;
- uninstall preview logic;
- Driver Store lifecycle;
- real driver deletion.
