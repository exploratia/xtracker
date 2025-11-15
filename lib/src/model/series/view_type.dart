import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../util/logging/flutter_simple_logging.dart';

enum ViewType {
  lineChart(Icons.area_chart_outlined),
  barChart(Icons.bar_chart_outlined),
  table(Icons.grid_on_outlined),
  pixels(Icons.apps_rounded);

  final IconData iconData;

  const ViewType(this.iconData);

  String displayName() {
    return displayNameOf(this);
  }

  static String displayNameOf(ViewType seriesType) {
    return switch (seriesType) {
      ViewType.lineChart => LocaleKeys.enum_viewType_lineChart_title.tr(),
      ViewType.barChart => LocaleKeys.enum_viewType_barChart_title.tr(),
      ViewType.table => LocaleKeys.enum_viewType_table_title.tr(),
      ViewType.pixels => LocaleKeys.enum_viewType_pixels_title.tr(),
    };
  }

  static ViewType byName(String? name) {
    var vt = ViewType.values.where((e) => e.name == name).firstOrNull;
    if (vt == null) {
      SimpleLogging.i("No view type found for '$name'. Using table...");
      return ViewType.table;
    }
    return vt;
  }
}
