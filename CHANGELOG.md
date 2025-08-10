# Changelog xTracker

All notable changes to this project will be documented in this file.

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
