import 'package:easy_localization/easy_localization.dart';

import '../../../../generated/locale_keys.g.dart';

enum TrendTendency {
  none("-", LocaleKeys.seriesDataAnalytics_trend_tendency_none),
  up("↗", LocaleKeys.seriesDataAnalytics_trend_tendency_up),
  down("↘", LocaleKeys.seriesDataAnalytics_trend_tendency_down);

  final String arrow;

  final String tooltipMsg;

  const TrendTendency(this.arrow, this.tooltipMsg);

  String get tooltip {
    return tooltipMsg.tr();
  }
}
