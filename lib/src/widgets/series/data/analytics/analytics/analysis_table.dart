import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../util/media_query_utils.dart';
import '../../../../controls/layout/h_centered_scroll_view.dart';

class AnalysisTable extends StatelessWidget {
  const AnalysisTable({super.key, required this.rows});

  final List<TableRow> rows;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var firstColumnWidth = (120 * MediaQueryUtils.textScaleWidthFactor).ceilToDouble();
        return HCenteredScrollView(
          children: [
            Table(
              columnWidths: <int, TableColumnWidth>{
                0: FixedColumnWidth(firstColumnWidth),
                1: FixedColumnWidth(math.max(firstColumnWidth, constraints.maxWidth - 120)),
              },
              border: TableBorder.symmetric(
                inside: BorderSide(width: 1, color: themeData.canvasColor),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: rows,
            ),
          ],
        );
      },
    );
  }
}
