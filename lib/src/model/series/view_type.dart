import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';

enum ViewType {
  lineChart("lineChart", Icons.area_chart_outlined),
  barChart("barChart", Icons.bar_chart_outlined),
  table("table", Icons.grid_on_outlined),
  // table(Icons.table_chart_outlined),
  // dots(Icons.margin_outlined);
  // dots(Icons.drag_indicator_outlined);
  // dots(Icons.dataset_outlined);
  pixels("pixels", Icons.blur_linear_outlined),
  dots("dots", Icons.apps_rounded);

  final String typeName;
  final IconData iconData;

  const ViewType(this.typeName, this.iconData);

  String displayName() {
    return displayNameOf(this);
  }

  static String displayNameOf(ViewType seriesType) {
    return switch (seriesType) {
      ViewType.lineChart => LocaleKeys.enum_viewType_lineChart_title.tr(),
      ViewType.barChart => LocaleKeys.enum_viewType_barChart_title.tr(),
      ViewType.table => LocaleKeys.enum_viewType_table_title.tr(),
      ViewType.dots => LocaleKeys.enum_viewType_dots_title.tr(),
      ViewType.pixels => LocaleKeys.enum_viewType_pixels_title.tr(),
    };
  }

  static ViewType resolveByTypeName(String? typeName) {
    var vt = ViewType.values.where((element) => element.typeName == typeName).firstOrNull;
    if (vt == null) return ViewType.table;
    return vt;
  }
}
