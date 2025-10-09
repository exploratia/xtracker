import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../util/media_query_utils.dart';
import '../../util/theme_utils.dart';
import '../../widgets/controls/text/overflow_text.dart';

// TODO for later series if column profiles have to be saved: Introduce new UIAdjustedColumnProfile which inherits ColumnProfile. In ColumnProfile toJson has one required info
class ColumnProfile {
  final List<ColumnDef> columns;
  final bool hasHorizontalMarginColumns;

  ColumnProfile({
    required this.columns,
    this.hasHorizontalMarginColumns = false,
  });

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
    return ColumnDef(minWidth: 200, title: '-?-');
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
        ColumnDef(minWidth: horizontalMargin, isMarginColumn: true, title: ''),
        ...adjustedColumns,
        ColumnDef(minWidth: horizontalMargin, isMarginColumn: true, title: ''),
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
  final bool isMarginColumn;
  final double minWidth;
  final String? title;
  final String? msgId;
  final TextAlign? textAlign;
  final bool disablePadding;
  final Widget? titleWidget;

  /// [disablePadding] could be set, if every second column has an empty title or column width is big enough.
  ColumnDef({required this.minWidth, this.isMarginColumn = false, this.title, this.msgId, this.textAlign, this.disablePadding = false, this.titleWidget});

  ColumnDef copyWithWidthFactor(double widthFactor) {
    return ColumnDef(
        minWidth: (minWidth * widthFactor), title: title, msgId: msgId, textAlign: textAlign, titleWidget: titleWidget, disablePadding: disablePadding);
  }

  double get minWidthScaled {
    // scale must only be applied to value columns - must not be applied to margin columns!
    if (isMarginColumn) return minWidth;
    return minWidth * MediaQueryUtils.textScaleFactor;
  }

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.paddingSmall),
      child: OverflowText(
        txt,
        expanded: false,
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }
}
