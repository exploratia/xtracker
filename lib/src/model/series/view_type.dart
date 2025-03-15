import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';

enum ViewType {
  chart(Icons.area_chart_outlined),
  table(Icons.grid_on_outlined),
  // table(Icons.table_chart_outlined),
  // dots(Icons.margin_outlined);
  // dots(Icons.drag_indicator_outlined);
  // dots(Icons.dataset_outlined);
  // dots(Icons.blur_linear_outlined);
  dots(Icons.apps_rounded);

  final IconData iconData;

  const ViewType(this.iconData);

  static String displayNameOf(ViewType seriesType) {
    return switch (seriesType) {
      ViewType.chart => LocaleKeys.series_viewType_chart.tr(),
      ViewType.table => LocaleKeys.series_viewType_table.tr(),
      ViewType.dots => LocaleKeys.series_viewType_dots.tr(),
    };
  }
}
