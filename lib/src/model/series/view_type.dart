import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ViewType {
  chart(Icons.area_chart_outlined),
  table(Icons.grid_on_outlined),
  // table(Icons.table_chart_outlined),
  dots(Icons.margin_outlined);
  // dots(Icons.drag_indicator_outlined);
  // dots(Icons.dataset_outlined);
  // dots(Icons.blur_linear_outlined);
  // dots(Icons.apps_rounded);

  final IconData iconData;

  const ViewType(this.iconData);

  static String displayNameOf(ViewType seriesType, AppLocalizations t) {
    return switch (seriesType) {
      ViewType.chart => t.seriesViewTypeChart,
      ViewType.table => t.seriesViewTypeTable,
      ViewType.dots => t.seriesViewTypeDots,
    };
  }
}
