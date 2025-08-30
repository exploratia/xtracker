import 'package:flutter/material.dart';

import '../../util/i18n.dart';
import '../../util/theme_utils.dart';
import '../../widgets/controls/text/overflow_text.dart';

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
    double minW = minWidth().toDouble();
    // is column profile wider then available width - return clone
    if (minW >= width) {
      return ColumnProfile(columns: [...columns]);
    }

    // otherwise adjust
    bool addMargin = false;
    double horizontalMargin = -1000;

    double widthFactor = width / minW;
    // if too wide limit and add margin to first (=date) column
    if (widthFactor > 2) {
      widthFactor = 2;
      addMargin = true;
    }
    List<ColumnDef> adjustedColumns = columns.map((e) => e.copyWithWidthFactor(widthFactor)).toList();

    if (addMargin) {
      var adjustedWidth = adjustedColumns.fold(0.toDouble(), (previousValue, element) => previousValue + element.minWidth);
      horizontalMargin = (width - adjustedWidth) / 2;
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
    return 'TableColumn{minWidth: $minWidth}';
  }

  Widget getTableColumnHeadItemWidget() {
    if (titleWidget != null) {
      return titleWidget!;
    }
    var txt = I18N.compose(msgId) ?? title ?? "";
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
