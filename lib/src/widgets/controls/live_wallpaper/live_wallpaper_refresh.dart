import 'package:flutter/material.dart';

import '../../../util/date_time_utils.dart';
import 'live_wallpaper.dart';

class LiveWallpaperRefresh extends StatelessWidget {
  final int intervalInSeconds;
  final int speedFactor;

  const LiveWallpaperRefresh({
    super.key,
    this.intervalInSeconds = 60 * 5,
    this.speedFactor = 1,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(Duration(seconds: intervalInSeconds), (count) => count),
      builder: (context, snapshot) {
        var now = DateTime.now();
        double percentOfDay = (now.difference(DateTimeUtils.truncateToDay(now)).inSeconds * speedFactor).toDouble() / (60 * 60 * 24);
        while (percentOfDay > 1) {
          percentOfDay -= 1;
        }
        return LiveWallpaper(percentOfDay: percentOfDay);
      },
    );
  }
}
