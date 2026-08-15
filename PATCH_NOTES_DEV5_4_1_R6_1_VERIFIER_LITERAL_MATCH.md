# dev.5.4.1 R6.1 - verifier literal-match hotfix

R6 itself was applied successfully, but its static verifier falsely reported:

`Missing streamlined install-flow contract: CurPageID in [wpSelectDir, wpReady]`

Root cause:

PowerShell `-like` treats square brackets as wildcard character-set syntax.
Therefore a literal Pascal Script fragment containing:

`[wpSelectDir, wpReady]`

cannot be safely searched using:

`$issText -like "*$fragment*"`

R6.1 changes verifier fragment checks to literal `.Contains(...)` matching.

Both fragment-list loops are fixed:

- installer localization / preview fragments;
- streamlined installation-flow fragments.

A regression guard rejects reintroduction of the wildcard-based form.

No installer source, UI behavior, localization, directory behavior, driver
logic, or uninstall behavior is changed.
