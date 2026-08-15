# dev.5.4.2 User-Safe Uninstall Contract

Default and silent uninstall keep the driver.

Interactive "remove driver as well" uses a dedicated user-safe runtime, not the
dev.5.3 lab script.

Device policy:
- connected -> block real driver removal;
- paired but disconnected -> allow;
- no device -> allow;
- unknown -> fail closed.

Removal policy:
1. exact single current package;
2. dynamic published INF;
3. exact Original INF / Provider / Version;
4. export exact package;
5. verify INF, CAT, DLL, SYS backup files;
6. `pnputil /delete-driver <dynamic oemN.inf> /uninstall`;
7. never `/force`;
8. post-check must be `not-installed`.

Other Apple, iPhone, and Apple Mobile Device drivers are outside the target set.
