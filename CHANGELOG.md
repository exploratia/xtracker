# Changelog xTracker

All notable changes to this project will be documented in this file.

## [2.2.1] - 2026-08-22

### Fixes

- fix display of information about new app versions

## [2.2.0] - 2026-08-22

### Features

- implement DropBox auto backup
- implement series value actions (edit, duplicate - where applicable, delete)
- autofocus low input field after high value entered for blood pressure input

### Fixes

- upgrade flutter_secure_storage to v11.0.0
- update file_picker to stable release
- backup reminder only in internal messages
- improve notification handling
- improve animations (speed, common handling)

## [2.1.0] - 2026-07-05

### Features

- implement reminder notifications per series
- implement quick actions

### Fixes

- improve tags proportions view for small screens
- correct more actions popup menu positioning and direction

## [2.0.1] - 2026-05-16

### Fixes

- update dependencies

## [2.0.0] - 2026-05-15

### Features

- implement tags for custom/monthly value
- implement dynamic/calculated parameters for custom series
- implement new series: custom/monthly
- add csv import/export for series
- migrate attribute -> tag

### Fixes

- rounded corners pixels
- null pointer with file_picker 11.0.2 read in web
- breaking change file_picker
- possible "called after dispose"
- possible listener leaks
- import migration if already up to date
- correct log file date by rollover
- prevent reload and scrolling to top when adding values in start screen
- increase height in attribute input to prevent dialog height change
- prevent backup reminder dialog from showing multiple times

### Others

- improve import json parsing with better error messages in log
- shorten export file names

## [1.4.0] - 2025-11-01

First public release version

### Features

- implement rounded corners pixels
- unify dots to pixels view

## [1.3.1] - 2025-10-12

### Features

- add hourly distribution for daily life attributes in analysis
- implement single-row, multi-value-per-day table column profiles
- add hourly distribution chart in analysis
- add monthly distribution chart in habit analysis

## [1.3.0] - 2025-10-04

### Features

- add the possibility to change the standard view per series
- add the possibility to change column profile in series table view
- implement daily life series
- implement wallpaper behind (some) screens

### Fixes

- datetime slider date calculation

## [1.2.1] - 2025-09-11

### Fixes

- datetime slider date calculation
- silent save value abort

## [1.2.0] - 2025-09-10

### Features

- implement recorded days analysis for series
- implement trend analysis for blood pressure series
- implement trend analysis for habit series

### Fixes

- correct date filter end calculation
- correct series title height calculation

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

- save initial app start on device storage for coming improvements (backup reminder, ...)
  ([#49](https://github.com/exploratia/xtracker/issues/49))
- add display option for different table column profile with time column
  ([#36](https://github.com/exploratia/xtracker/issues/36))
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
- add a small count number in dot overview (configurable per series)
  ([#35](https://github.com/exploratia/xtracker/issues/35))

### Fixes

- correct displayed message when no or no actual data is available
  ([#30](https://github.com/exploratia/xtracker/issues/30))

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

First tested version

### Features

- daily check series
- blood pressure series
- import, export and share series in JSON format
- series views: table, chart, dots
- dark and light theme support
