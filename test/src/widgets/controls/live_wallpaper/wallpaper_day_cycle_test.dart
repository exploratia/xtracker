import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/mountain_lake_theme.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/wallpaper_day_cycle.dart';

void main() {
  test('local clock time and accelerated previews wrap at midnight', () {
    expect(WallpaperDayCycle.fractionAt(DateTime(2026, 10, 25, 12)), 0.5);
    expect(WallpaperDayCycle.fractionAt(DateTime(2026, 3, 29, 6)), 0.25);
    expect(WallpaperDayCycle.fractionAt(DateTime(2026, 1, 1)), 0);
    expect(WallpaperDayCycle.fractionAt(DateTime(2026, 1, 1, 18), speedFactor: 2), 0.5);
    expect(WallpaperDayCycle.fractionAt(DateTime(2026, 1, 1, 23, 59, 59)), closeTo(1, 1 / 86400));
  });

  test('sun and moon alternate with a continuous night arc across midnight', () {
    const noon = WallpaperDayCycle(0.5);
    const midnight = WallpaperDayCycle(0);
    expect(noon.sunProgress, 0.5);
    expect(noon.sunOpacity, 1);
    expect(noon.moonOpacity, 0);
    expect(noon.starOpacity, 0);
    expect(midnight.moonProgress, 0.5);
    expect(midnight.moonOpacity, 1);
    expect(midnight.sunOpacity, 0);
    expect(midnight.starOpacity, 1);
    expect(const WallpaperDayCycle(1 - 1 / 86400).moonProgress, closeTo(midnight.moonProgress, 0.0001));
    expect(const WallpaperDayCycle(1 / 86400).moonProgress, closeTo(midnight.moonProgress, 0.0001));
    expect(noon.elevation(0), 0);
    expect(noon.elevation(0.5), 1);
    expect(noon.elevation(1), closeTo(0, 0.00001));
  });

  test('celestial visibility and stars stay bounded throughout the day', () {
    for (var minute = 0; minute <= 1440; minute++) {
      final cycle = WallpaperDayCycle(minute / 1440);
      for (final value in [cycle.sunOpacity, cycle.moonOpacity, cycle.starOpacity, cycle.sunProgress, cycle.moonProgress]) {
        expect(value, inInclusiveRange(0, 1), reason: 'Minute $minute');
      }
      expect(cycle.sunOpacity * cycle.moonOpacity, 0);
    }
    expect(const WallpaperDayCycle(6 / 24).starOpacity, 0.5);
    expect(const WallpaperDayCycle(20 / 24).starOpacity, 0.5);
  });

  test('palette changes smoothly and returns to the same colors at midnight', () {
    const theme = MountainLakeTheme();
    expect(theme.paletteAt(0).skyTop, theme.paletteAt(1).skyTop);
    expect(theme.paletteAt(12 / 24).skyTop, theme.day.skyTop);
    expect(theme.paletteAt(6.5 / 24).horizon, theme.dawn.horizon);
    expect(theme.paletteAt(18 / 24).horizon, theme.dusk.horizon);
    expect(theme.paletteAt(0).skyTop, isNot(theme.paletteAt(0.5).skyTop));
    for (final hour in [5.0, 6.5, 9.0, 16.0, 18.0, 20.0, 24.0]) {
      final before = theme.paletteAt((hour - 0.0001) / 24);
      final after = theme.paletteAt((hour + 0.0001) / 24);
      expect(before.skyTop.r, closeTo(after.skyTop.r, 0.001));
      expect(before.horizon.b, closeTo(after.horizon.b, 0.001));
    }
  });
}
