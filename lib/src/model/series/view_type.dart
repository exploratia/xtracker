import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ViewType {
  chart(Icons.area_chart_outlined),
  table(Icons.table_chart_outlined),
  dots(Icons.calendar_month_outlined);

  final IconData iconData;

  const ViewType(this.iconData);

  static String displayNameOf(ViewType seriesType, AppLocalizations t) {
    return switch (seriesType) {
      ViewType.chart => 'Chart',
      ViewType.table => 'Table',
      ViewType.dots => 'Dots',
    };
  }
}
