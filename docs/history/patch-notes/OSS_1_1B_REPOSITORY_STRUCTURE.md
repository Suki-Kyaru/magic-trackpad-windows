# OSS-1.1B Repository Structure Governance

This phase performs information-architecture cleanup only.

Changes:

- move all repository-root `PATCH_NOTES*.md` into
  `docs/history/patch-notes/`;
- preserve the old unreferenced `installer/INFO_BEFORE.txt` as
  `docs/history/legacy/INFO_BEFORE.dev5.1.txt`;
- add `docs/README.md` as the documentation index;
- add history navigation;
- add OSS repository-structure rules;
- add public README blueprint;
- add license/redistribution review checklist;
- add a repository-layout verifier.

Not changed:

- C++ helper;
- driver lifecycle;
- installer runtime behavior;
- uninstall behavior;
- current localized InfoBefore resources;
- README public content (deferred to OSS-1.2);
- repository license decision (deferred to OSS-1.3).
