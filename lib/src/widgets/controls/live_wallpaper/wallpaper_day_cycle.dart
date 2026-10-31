import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Immutable, clock-based lighting and celestial positions, independent of widgets.
@immutable
class WallpaperDayCycle {
  const WallpaperDayCycle(this.percentOfDay);

  /// Fraction of a local calendar day. Values wrap at midnight.
  final double percentOfDay;

  /// Uses clock components so daylight saving days still span 24 displayed hours.
  static double fractionAt(DateTime time, {int speedFactor = 1}) => ((time.hour * 3600 + time.minute * 60 + time.second) * speedFactor % 86400) / 86400;

  double get _hour => (percentOfDay % 1) * 24;

  /// Daylight arc from 06:00 to 18:00.
  double get sunProgress => ((_hour - 6) / 12).clamp(0.0, 1.0);

  /// Night arc from 18:00 to 06:00, continuous across midnight.
  double get moonProgress => ((_hour + 6) % 24 / 12).clamp(0.0, 1.0);

  double get sunOpacity => _visibility(sunProgress);
  double get moonOpacity => _visibility(moonProgress);

  /// Stars fade out at dawn and return after dusk.
  double get starOpacity {
    if (_hour < 5 || _hour >= 21) return 1;
    if (_hour < 7) return (7 - _hour) / 2;
    if (_hour < 19) return 0;
    return (_hour - 19) / 2;
  }

  /// Celestial elevation along a shallow arc above the mountain horizon.
  double elevation(double progress) => math.sin(progress * math.pi);

  double _visibility(double progress) => (math.min(progress, 1 - progress) * 12).clamp(0.0, 1.0);
}
