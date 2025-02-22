import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

import '../../model/series/profile/table_column_profile.dart';
import '../navigation/hide_bottom_navigation_bar.dart';
import '../text/overflow_text.dart';
import 'two_dimensional_grid_view_with_scrollbar.dart';

class TwoDimensionalScrollableTable extends StatelessWidget {
  TwoDimensionalScrollableTable({
    super.key,
    required this.tableColumnProfile,
    required this.gridCellBuilder,
    required this.lineHeight,
    required this.tableHead,
    required this.lineCount,
  });

  final TableColumnProfile tableColumnProfile;
  final GridCell Function(BuildContext context, int yIndex, int xIndex) gridCellBuilder;
  final int lineHeight;
  final int lineCount;
  final List<String> tableHead;
  final String uniqueViewportSizeKeyId = const UuidV4().generate().toString();

  @override
  Widget build(BuildContext context) {
    return HideBottomNavigationBar(
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        final TableColumnProfile adjustedTableColumnProfile = tableColumnProfile.adjustToWidth(constraints.maxWidth);

        var viewportSizeKey = ValueKey('2d_grid_view_size_key_${constraints.maxWidth}_$uniqueViewportSizeKeyId');

        var twoDimensionalChildBuilderDelegate = TwoDimensionalChildBuilderDelegate(
            maxXIndex: adjustedTableColumnProfile.length() - 1,
            maxYIndex: lineCount - 1,
            builder: (BuildContext context, ChildVicinity vicinity) {
              // print('$vicinity');
              int yIndex = vicinity.yIndex;
              TableColumn tableColumn = adjustedTableColumnProfile.getColumnAt(vicinity.xIndex);
              var columnWidth = tableColumn.minWidth;

              if (tableColumn.isMarginColumn) {
                return SizedBox(width: columnWidth);
              }

              int tableDataXIndex = vicinity.xIndex;
              // if column profile has margin columns adjust data idx
              if (adjustedTableColumnProfile.hasHorizontalMarginColumns) {
                tableDataXIndex--;
              }

              var cellData = gridCellBuilder(context, yIndex, tableDataXIndex);

              return Container(
                color: cellData.backgroundColor,
                height: lineHeight.toDouble(),
                width: columnWidth,
                child: cellData.child,
              );
            });

        return _ScrollableGrid(
            lineHeight: lineHeight,
            tableColumnProfile: adjustedTableColumnProfile,
            viewportSizeKey: viewportSizeKey,
            tableHead: tableHead,
            twoDimensionalChildBuilderDelegate: twoDimensionalChildBuilderDelegate);
      }),
    );
  }
}

class GridCell {
  final Color? backgroundColor;
  final Widget child;

  GridCell({required this.backgroundColor, required this.child});
}

class _ScrollableGrid extends StatefulWidget {
  const _ScrollableGrid({
    required this.lineHeight,
    required this.tableColumnProfile,
    required this.viewportSizeKey,
    required this.twoDimensionalChildBuilderDelegate,
    required this.tableHead,
  });

  final int lineHeight;
  final TableColumnProfile tableColumnProfile;
  final ValueKey<String> viewportSizeKey;
  final TwoDimensionalChildBuilderDelegate twoDimensionalChildBuilderDelegate;
  final List<dynamic> tableHead;

  @override
  State<_ScrollableGrid> createState() => _ScrollableGridState();
}

class _ScrollableGridState extends State<_ScrollableGrid> {
  final ScrollController _tableHeadScrollController = ScrollController();

  void _scrollToPosition(double position) {
    _tableHeadScrollController.jumpTo(position);
    //  .animateTo(
    //   position,
    //   duration: const Duration(milliseconds: 500),
    //   curve: Curves.easeInOut,
    // );
  }

  @override
  void dispose() {
    _tableHeadScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var columnProfile = widget.tableColumnProfile;

    List<Widget> tableHeader = [];
    int tableHeadItemIdx = -1;
    for (var tableColumn in columnProfile.columns) {
      if (tableColumn.isMarginColumn) {
        tableHeader.add(SizedBox(width: tableColumn.minWidth));
      } else {
        tableHeadItemIdx++;
        Widget tableHeaderItemWidget = SizedBox(
          width: tableColumn.minWidth.toDouble(),
          child: _getTableHeadItemWidget(tableHeadItemIdx),
        );
        tableHeader.add(tableHeaderItemWidget);
      }
    }
    return Column(
      children: [
        SingleChildScrollView(
          controller: _tableHeadScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 40,
            width: columnProfile.minWidth().toDouble(),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: tableHeader),
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: TwoDimensionalGridViewWithScrollbar(
            lineHeight: widget.lineHeight,
            tableColumnProfile: columnProfile,
            viewportSizeKey: widget.viewportSizeKey,
            twoDimensionalChildBuilderDelegate: widget.twoDimensionalChildBuilderDelegate,

            // Hide bottom nav bar on scroll is not really possible because the hide forces the layout builder to rebuild
            // => the scroll breaks. => Hide bottom nav bar always in grid view
            // verticalScrollPositionHandler: HideBottomNavigationBar.setScrollPosition,

            horizontalScrollPositionHandler: (hScrollPos) => _scrollToPosition(hScrollPos.pixels),
          ),
        ),
      ],
    );
  }

  Widget _getTableHeadItemWidget(int idx) {
    var tableHeadItem = widget.tableHead[idx];
    Widget tableHeadItemWidget;
    if (tableHeadItem is Widget) {
      tableHeadItemWidget = tableHeadItem;
    } else {
      tableHeadItemWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OverflowText(
          expanded: false,
          tableHeadItem.toString(),
          textAlign: TextAlign.center,
        ),
      );
    }
    return tableHeadItemWidget;
  }
}
