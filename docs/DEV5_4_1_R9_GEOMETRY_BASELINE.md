# dev.5.4.1 R9 - installer geometry baseline

## Goal

Stop adjusting individual controls by visual trial-and-error.

The installer now has one shared geometry rule for standard content pages.

## Header group

```text
Title
8 px
Subtitle
16 px
Content
```

All values use Inno's DPI scaling helpers.

The subtitle and title share the same left anchor.

Do not calculate content position from an untouched default
`PageDescriptionLabel.Height`; normalize the active caption height first.

## Destination first row

Use a system stock folder icon rather than relying on the default bitmap
geometry.

The icon and main destination explanation form one vertically centered row.

## Lower content

```text
first row
16 px
instruction
8 px
path field + Browse button
```

Do not move the disk-space line or bottom navigation strip.

## DPI rule

Use scaled geometry and DPI-aware icon candidates. Avoid fixed raw-pixel
coordinates for page reflow.
