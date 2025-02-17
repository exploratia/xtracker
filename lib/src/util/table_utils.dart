import 'package:flutter/material.dart';

class TableUtils {
  static TableRow tableHeadline(List<String> values) {
    return TableRow(children: [
      ...values.map(
        (value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]);
  }

  static TableRow tableRow(List<dynamic> values, {Decoration? decoration}) {
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
        return TableCellPadding(child);
      }),
    ]);
  }
}

class TableCellPadding extends StatelessWidget {
  final Widget child;

  const TableCellPadding(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: child,
    );
  }
}
