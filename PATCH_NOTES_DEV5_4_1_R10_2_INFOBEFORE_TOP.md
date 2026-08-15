# dev.5.4.1 R10.2 - InfoBefore top micro-adjustment

R10 fixed the coordinate-system issue.
R10.1 moved both page-local content origins from 12 to 8 scaled pixels.

Final VM review showed:

- SelectDir at 8 scaled pixels is visually accepted.
- InfoBefore can move upward slightly for better visual balance.

R10.2 therefore changes only:

```text
InfoBefore local content top: 8 -> 4 scaled px
```

SelectDir remains:

```text
SelectDir local content top: 8 scaled px
```

Everything else is frozen:

- title -> subtitle gap: 8 scaled px;
- destination first row -> instruction: 16 scaled px;
- instruction -> path field: 8 scaled px;
- Windows stock folder icon;
- disk-space line;
- bottom navigation strip;
- Windows 11 dynamic style;
- Simplified Chinese / English localization;
- uninstall preview;
- Driver Store lifecycle.

If VM visual acceptance passes, this is the final installer-body geometry for
dev.5.4.1.
