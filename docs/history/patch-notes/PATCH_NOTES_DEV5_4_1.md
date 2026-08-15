# v0.1.0-dev.5.4.1

Added:

- Inno Setup built-in `modern dynamic windows11` wizard style;
- Windows UI-language based installer selection;
- Simplified Chinese + English in one Setup executable;
- English-first fallback for unsupported languages;
- no language-selection dialog;
- localized InfoBefore/README content;
- localized Start-menu entries;
- localized install error/status text;
- localized uninstall decision preview;
- read-only driver-removal preview through `Get-UninstallPlan.ps1`;
- preview decision log.

Not added:

- real user-facing driver deletion;
- `/force`;
- changes to the frozen dev.5.3 Driver Store lifecycle;
- Traditional Chinese translation;
- Japanese/Korean/German translations.

The driver always remains installed after dev.5.4.1 application uninstall.
