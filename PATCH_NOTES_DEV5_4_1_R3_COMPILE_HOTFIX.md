# dev.5.4.1 R3 - Inno Pascal Script compile hotfix

R2 successfully reached Inno Setup's [Code] compilation stage, proving that:

- `WizardStyle=modern dynamic windows11` was accepted;
- English and Simplified Chinese language resources were accepted;
- dynamic dark wizard resources were accepted.

Compilation then stopped in a multiline nested `FmtMessage(...)` expression.

R3 keeps all UI/language behavior unchanged and only simplifies Pascal Script:

- flatten nested `FmtMessage` calls;
- use intermediate variables for formatted strings;
- replace the non-documented `BoolToStr` call with a local
  `BoolToLowerString` helper;
- add verifier guards so these forms do not regress.

No driver install/remove core behavior is changed.
dev.5.4.1 remains preview-only and never deletes a driver.
