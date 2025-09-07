import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../generated/locale_keys.g.dart';
import 'theme_utils.dart';

class TableUtils {
  static TableRow tableHeadline(
    List<dynamic> values, {
    EdgeInsets? cellPadding,
    required ThemeData themeData,
  }) {
    Decoration decoration = BoxDecoration(
      color: themeData.canvasColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(ThemeUtils.borderRadius)),
    );
    EdgeInsets cellPad = cellPadding ??
        const EdgeInsets.only(top: ThemeUtils.defaultPadding, left: ThemeUtils.paddingSmall, right: ThemeUtils.paddingSmall, bottom: ThemeUtils.paddingSmall);

    return TableRow(decoration: decoration, children: [
      ...values.map(
        (value) {
          Widget child;
          if (value is Widget) {
            child = value;
          } else {
            child = Text(
              value.toString(),
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            );
          }
          return _TableCellPadding(
            child,
            edgeInsets: cellPad,
          );
        },
      ),
    ]);
  }

  static TableRow tableRow(
    List<dynamic> values, {
    Decoration? decoration,
    EdgeInsets? cellPadding,
  }) {
    var cPadding = cellPadding ?? const EdgeInsets.symmetric(vertical: ThemeUtils.paddingSmall / 2, horizontal: ThemeUtils.paddingSmall);

    return TableRow(decoration: decoration, children: [
      ...values.map((value) {
        Widget child;
        if (value is Widget) {
          child = value;
        } else {
          child = Text(
            value.toString(),
            textAlign: (value is num) ? TextAlign.right : TextAlign.left,
          );
        }
        return _TableCellPadding(
          child,
          edgeInsets: cPadding,
        );
      }),
    ]);
  }

  /// returns a TableRows list for a key value table. Headline row is already inserted.
  static List<TableRow> buildKeyValueTableRows(
    BuildContext context, {
    String? keyColumnTitle,
    String? valueColumnTitle,
  }) {
    final themeData = Theme.of(context);
    return [
      TableUtils.tableHeadline(
        [
          keyColumnTitle ?? LocaleKeys.commons_table_column_key.tr(),
          valueColumnTitle ?? LocaleKeys.commons_table_column_value.tr(),
        ],
        themeData: themeData,
      ),
    ];
  }
}

class _TableCellPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets edgeInsets;

  const _TableCellPadding(this.child, {required this.edgeInsets});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      // could be set per table by  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      // verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: edgeInsets,
        child: child,
      ),
    );
  }
}
