import 'package:flutter/material.dart';

import 'theme_utils.dart';

class TableUtils {
  static TableRow tableHeadline(
    List<dynamic> values, {
    Decoration? decoration,
    EdgeInsets? cellPadding,
  }) {
    return TableRow(decoration: decoration, children: [
      ...values.map(
        (value) {
          EdgeInsets cellPad = cellPadding ?? const EdgeInsets.all(ThemeUtils.paddingSmall);

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
          edgeInsets: cellPadding,
        );
      }),
    ]);
  }
}

class _TableCellPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? edgeInsets;

  const _TableCellPadding(this.child, {this.edgeInsets});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: edgeInsets ?? const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: child,
      ),
    );
  }
}
