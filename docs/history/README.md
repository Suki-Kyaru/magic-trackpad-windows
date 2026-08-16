# Development History Archive

This directory preserves raw development notes and retired project artifacts.

The archive exists for:

- debugging historical regressions;
- understanding why compatibility/safety rules exist;
- helping maintainers and coding agents avoid repeating already-solved failures;
- preserving pre-public-release engineering context.

## `patch-notes/`

Contains the former repository-root `PATCH_NOTES*.md` files.

These are chronological implementation notes, not current user documentation.

When a patch note conflicts with a later validation or contract document, the
later maintained contract/validation document wins.

## `legacy/`

Contains retired but historically useful files that are no longer referenced
by the active build/install pipeline.

Do not move a file into `legacy/` unless active references have first been
verified absent.
