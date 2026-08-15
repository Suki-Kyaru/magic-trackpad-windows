# dev.5.4.1 R10 - coordinate-system rule

Never use a control on `MainPanel` to calculate the Top position of a control
on an inner wizard page.

Treat these as separate layout surfaces:

- MainPanel header
- InfoBefore page content
- SelectDir page content

Only compare or derive coordinates among controls that share the same layout
surface.

Current rhythm:

Header:
- title -> subtitle: 8 scaled px

InfoBefore local page:
- body top: 12 scaled px

SelectDir local page:
- first row top: 12 scaled px
- first row -> instruction: 16 scaled px
- instruction -> path: 8 scaled px

Bottom disk-space and navigation areas remain untouched.
