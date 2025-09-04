# Changelog xTracker

All notable changes to this project will be documented in this file.

## [1.1.1] - 2025-09-04

### Features

- device info view
- app support reminder
- series backup reminder
- store and display latest series export

### Fixes

- adjust app layout for larger text scales

## [1.1.0] - 2025-08-29

### Features

- save initial app start on device storage for coming improvements (backup
  reminder, ...) ([#49](https://github.com/exploratia/xtracker/issues/49))
- add display option for different table column profile with time
  column ([#36](https://github.com/exploratia/xtracker/issues/36))
- add new series type habit ([#43](https://github.com/exploratia/xtracker/issues/43))

### Fixes

- show tooltip in charts while touch dragging
- blood pressure chart gradient calculation
- build charts too often (on hover for tooltip)
- add date filter for views ([#47](https://github.com/exploratia/xtracker/issues/47))
- show always the latest value in series overview ([#45](https://github.com/exploratia/xtracker/issues/45))

## [1.0.4] - 2025-08-10

### Other

- set minimum SDK to 21 (Android 5) to support older devices.

## [1.0.3] - 2025-08-09

### Features

- add a tooltip showing date and time in the table view ([#36](https://github.com/exploratia/xtracker/issues/36))
- add tooltips showing date, time, and value in the dots view ([#35](https://github.com/exploratia/xtracker/issues/35))
- improve scroll performance in dots view
- add a small count number in dot overview (configurable per
  series) ([#35](https://github.com/exploratia/xtracker/issues/35))

### Fixes

- correct displayed message when no or no actual data is
  available ([#30](https://github.com/exploratia/xtracker/issues/30))

### Other

- set minimum SDK to 29 (Android 10) to support older devices.

## [1.0.2] - 2025-08-02

### Fixes

- prevent unreachable bottom navigation bar

## [1.0.1] - 2025-08-01

### Features

- add tooltips to all pressable icons (on long touch)

### Fixes

- display a message in series management if no series exists yet
- use app-specific email address in legals
- increase upper limit for blood pressure values

## [1.0.0] - 2025-07-26

First published version

### Features

- daily check series
- blood pressure series
- import, export and share series in JSON format
- series views: table, chart, dots
- dark and light theme support
