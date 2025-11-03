import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../util/chart/chart_utils.dart';
import '../../util/media_query_utils.dart';
import '../../util/theme_utils.dart';
import '../../widgets/controls/text/overflow_text.dart';
import '../series/series_def.dart';
import '../series/series_type.dart';
import 'column_type.dart';

class ColumnProfile {
  late final List<ColumnDef> columns;
  late final bool hasHorizontalMarginColumns;

  ColumnProfile({
    required this.columns,
    this.hasHorizontalMarginColumns = false,
  });

  ColumnProfile.fromSeriesItems(SeriesDef seriesDef) {
    hasHorizontalMarginColumns = false;
    columns = [];
    var msgId = seriesDef.seriesType == SeriesType.monthly ? LocaleKeys.commons_date_date : LocaleKeys.commons_date_dateTime;
    columns.add(ColumnDef(
      minWidth: seriesDef.seriesType == SeriesType.monthly ? 80 : 160,
      title: '-',
      msgId: msgId,
      columnType: ColumnType.dateTime,
    ));
    // series items
    columns.addAll(seriesDef.seriesItems
        .map((e) => ColumnDef(
              minWidth: 80,
              title: e.name,
              // title: '${e.name}${e.unitInBrackets(emptyStringIfNullOrEmpty: true)}',
              siid: e.siid,
              color: e.color,
              columnType: ColumnType.number,
            ))
        .toList());
  }

  double minWidth() {
    return columns.fold(0, (previousValue, element) => previousValue + element.minWidth);
  }

  double minWidthScaled() {
    return columns.fold(0, (previousValue, element) => previousValue + element.minWidthScaled);
  }

  int length() {
    return columns.length;
  }

  ColumnDef getColumnAt(int index) {
    if (index >= 0 && index < columns.length) {
      return columns[index];
    }

    // fallback - should never happen
    return ColumnDef(minWidth: 200, title: '-?-', columnType: ColumnType.text);
  }

  /// stretch to given width
  ColumnProfile adjustToWidth(double width) {
    double minWScaled = minWidthScaled();
    // is column profile wider then available width - return clone
    if (minWScaled >= width) {
      return ColumnProfile(columns: [...columns]);
    }

    // otherwise adjust
    bool addMargin = false;
    double horizontalMargin = -1000;

    double widthFactor = (width / MediaQueryUtils.textScaleFactor) / minWidth();
    // if too wide limit and add margin columns
    if (widthFactor > 2) {
      widthFactor = 2;
      addMargin = true;
    }
    List<ColumnDef> adjustedColumns = columns.map((e) => e.copyWithWidthFactor(widthFactor)).toList();

    if (addMargin) {
      double adjustedWidthScaled = adjustedColumns.fold(0.toDouble(), (previousValue, element) => previousValue + element.minWidthScaled);
      horizontalMargin = (width - adjustedWidthScaled) / 2;
      adjustedColumns = [
        ColumnDef(minWidth: horizontalMargin, columnType: ColumnType.margin, title: ''),
        ...adjustedColumns,
        ColumnDef(minWidth: horizontalMargin, columnType: ColumnType.margin, title: ''),
      ];
    }

    return ColumnProfile(columns: adjustedColumns, hasHorizontalMarginColumns: horizontalMargin >= 0);
  }

  @override
  String toString() {
    return 'TableColumnProfile{columns: $columns}';
  }
}

class ColumnDef {
  final ColumnType columnType;
  final double minWidth;
  final String? title;
  final String? msgId;
  final TextAlign? textAlign;
  final bool disablePadding;
  final Widget? titleWidget;

  /// optional in case of ColumnProfile from Series: seriesItemId
  final String? siid;

  /// optional in case of ColumnProfile from Series
  final Color? color;

  /// [disablePadding] could be set, if every second column has an empty title or column width is big enough.
  ColumnDef({
    required this.columnType,
    required this.minWidth,
    this.title,
    this.msgId,
    this.textAlign,
    this.disablePadding = false,
    this.titleWidget,
    this.siid,
    this.color,
  });

  ColumnDef copyWithWidthFactor(double widthFactor) {
    return ColumnDef(
      minWidth: (minWidth * widthFactor),
      title: title,
      msgId: msgId,
      textAlign: textAlign,
      titleWidget: titleWidget,
      disablePadding: disablePadding,
      columnType: columnType,
      siid: siid,
      color: color,
    );
  }

  double get minWidthScaled {
    // scale must only be applied to value columns - must not be applied to margin columns!
    if (isMarginColumn) return minWidth;
    return minWidth * MediaQueryUtils.textScaleFactor;
  }

  bool get isMarginColumn => columnType == ColumnType.margin;

  MainAxisAlignment determineMainAxisAlignmentFromTextAlign() {
    var mainAxisAlignment = MainAxisAlignment.center;
    if (textAlign != null) {
      if (textAlign == TextAlign.left || textAlign == TextAlign.start) {
        mainAxisAlignment = MainAxisAlignment.start;
      } else if (textAlign == TextAlign.right || textAlign == TextAlign.end) {
        mainAxisAlignment = MainAxisAlignment.end;
      }
    }
    return mainAxisAlignment;
  }

  @override
  String toString() {
    return 'TableColumn{minWidth: $minWidth (scaled: $minWidthScaled)}';
  }

  Widget getTableColumnHeadItemWidget() {
    if (titleWidget != null) {
      return titleWidget!;
    }
    var txt = msgId?.tr() ?? title ?? "";
    if (txt.isEmpty) return Container();

    if (disablePadding) {
      return Text(
        txt,
        overflow: TextOverflow.visible,
        softWrap: false,
        textAlign: textAlign ?? TextAlign.center,
      );
    }

    Widget widget = OverflowText(
      txt,
      expanded: false,
      textAlign: textAlign ?? TextAlign.center,
    );

    if (color != null) {
      widget = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 2),
          Expanded(child: Center(child: widget)),
          Container(
            height: 2,
            decoration: BoxDecoration(gradient: ChartUtils.createLeftToRightGradient([color!.withAlpha(0), color!, color!.withAlpha(0)])),
          ),
        ],
      );
    }

    widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.paddingSmall),
      child: widget,
    );
    return widget;
  }
}
