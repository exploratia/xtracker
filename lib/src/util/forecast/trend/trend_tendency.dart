import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';

enum TrendTendency {
  none(Icons.trending_neutral, LocaleKeys.seriesDataAnalytics_trend_tendency_none),
  up(Icons.trending_up, LocaleKeys.seriesDataAnalytics_trend_tendency_up),
  down(Icons.trending_down, LocaleKeys.seriesDataAnalytics_trend_tendency_down);

  final IconData arrow;

  final String tooltipMsg;

  const TrendTendency(this.arrow, this.tooltipMsg);

  String get tooltip {
    return tooltipMsg.tr();
  }
}
