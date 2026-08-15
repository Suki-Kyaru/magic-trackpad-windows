# dev.5.4.1 R10.1 - page-local content top micro-adjustment

R10 fixed the coordinate-system bug and restored a stable layout.

VM screenshots showed that both main content groups still sat slightly lower
than desired, while all other geometry was acceptable.

R10.1 intentionally makes only one visual adjustment:

```text
InfoBefore local content top: 12 -> 8 scaled px
SelectDir local content top:  12 -> 8 scaled px
```

Everything else remains unchanged:

- title -> subtitle gap: 8 scaled px;
- first destination row -> secondary instruction: 16 scaled px;
- secondary instruction -> path field: 8 scaled px;
- Windows stock folder icon;
- bottom disk-space line;
- Back / Install / Cancel navigation strip;
- language behavior;
- uninstall preview;
- Driver Store lifecycle.

This is a micro-adjustment, not a new geometry model.
