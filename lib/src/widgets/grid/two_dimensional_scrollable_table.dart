import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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
    required this.lineCount,
    this.useFixedFirstColumn = true,
  });

  final TableColumnProfile tableColumnProfile;
  final GridCell Function(BuildContext context, int yIndex, int xIndex) gridCellBuilder;
  final int lineHeight;
  final int lineCount;
  final bool useFixedFirstColumn;
  final String uniqueViewportSizeKeyId = const UuidV4().generate().toString();

  @override
  Widget build(BuildContext context) {
    return HideBottomNavigationBar(
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        final TableColumnProfile adjustedTableColumnProfile = tableColumnProfile.adjustToWidth(constraints.maxWidth);

        TableColumn? fixedFirstColumnTableColumn;
        final bool showFixedFirstColumn = useFixedFirstColumn && adjustedTableColumnProfile.minWidth() > constraints.maxWidth;
        if (showFixedFirstColumn) {
          fixedFirstColumnTableColumn = adjustedTableColumnProfile.columns.removeAt(0);
        }

        final viewportSizeKey = ValueKey('2d_grid_view_size_key_${constraints.maxWidth}_$uniqueViewportSizeKeyId');

        final twoDimensionalChildBuilderDelegate = TwoDimensionalChildBuilderDelegate(
            maxXIndex: adjustedTableColumnProfile.length() - 1,
            maxYIndex: lineCount - 1,
            builder: (BuildContext context, ChildVicinity vicinity) {
              // print('$vicinity');
              int yIndex = vicinity.yIndex;
              TableColumn tableColumn = adjustedTableColumnProfile.getColumnAt(vicinity.xIndex);
              final columnWidth = tableColumn.minWidth;

              if (tableColumn.isMarginColumn) {
                return SizedBox(width: columnWidth);
              }

              int tableDataXIndex = vicinity.xIndex;
              // if column profile has margin columns adjust data idx
              if (adjustedTableColumnProfile.hasHorizontalMarginColumns) {
                tableDataXIndex--;
              } // if column profile has fix first column adjust data idx
              else if (showFixedFirstColumn) {
                tableDataXIndex++;
              }

              final cellData = gridCellBuilder(context, yIndex, tableDataXIndex);

              return Container(
                color: cellData.backgroundColor,
                height: lineHeight.toDouble(),
                width: columnWidth,
                child: cellData.child,
              );
            });

        return _ScrollableGrid(
          lineHeight: lineHeight,
          lineCount: lineCount,
          fixedFirstColumnTableColumn: fixedFirstColumnTableColumn,
          tableColumnProfile: adjustedTableColumnProfile,
          viewportSizeKey: viewportSizeKey,
          twoDimensionalChildBuilderDelegate: twoDimensionalChildBuilderDelegate,
          gridCellBuilder: gridCellBuilder,
        );
      }),
    );
  }
}

class GridCell {
  final Color? backgroundColor;
  final Widget child;

  GridCell({this.backgroundColor, required this.child});
}

class _ScrollableGrid extends StatefulWidget {
  const _ScrollableGrid({
    required this.lineHeight,
    required this.lineCount,
    required this.tableColumnProfile,
    required this.fixedFirstColumnTableColumn,
    required this.viewportSizeKey,
    required this.twoDimensionalChildBuilderDelegate,
    required this.gridCellBuilder,
  });

  final int lineHeight;
  final int lineCount;

  final TableColumnProfile tableColumnProfile;
  final TableColumn? fixedFirstColumnTableColumn;

  final double tableHeadHeight = 40;

  final ValueKey<String> viewportSizeKey;
  final TwoDimensionalChildBuilderDelegate twoDimensionalChildBuilderDelegate;
  final GridCell Function(BuildContext context, int yIndex, int xIndex) gridCellBuilder;

  @override
  State<_ScrollableGrid> createState() => _ScrollableGridState();
}

class _ScrollableGridState extends State<_ScrollableGrid> {
  late LinkedScrollControllerGroup _verticalScrollControllersGroup;
  late ScrollController _verticalScrollControllerGrid;

  late ScrollController _verticalScrollControllerFirstColumn;

  late LinkedScrollControllerGroup _horizontalScrollControllersGroup;
  late ScrollController _horizontalScrollControllerGrid;
  late ScrollController _horizontalScrollControllerTableHead;

  @override
  void initState() {
    super.initState();
    _verticalScrollControllersGroup = LinkedScrollControllerGroup();
    _verticalScrollControllerGrid = _verticalScrollControllersGroup.addAndGet();
    _verticalScrollControllerFirstColumn = _verticalScrollControllersGroup.addAndGet();
    _horizontalScrollControllersGroup = LinkedScrollControllerGroup();
    _horizontalScrollControllerGrid = _horizontalScrollControllersGroup.addAndGet();
    _horizontalScrollControllerTableHead = _horizontalScrollControllersGroup.addAndGet();
  }

  @override
  void dispose() {
    _verticalScrollControllerGrid.dispose();
    _verticalScrollControllerFirstColumn.dispose();
    _horizontalScrollControllerGrid.dispose();
    _horizontalScrollControllerTableHead.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var columnProfile = widget.tableColumnProfile;

    List<Widget> tableHeader = [];
    for (var tableColumn in columnProfile.columns) {
      if (tableColumn.isMarginColumn) {
        tableHeader.add(SizedBox(width: tableColumn.minWidth));
      } else {
        Widget tableHeaderItemWidget = SizedBox(
          width: tableColumn.minWidth.toDouble(),
          child: _getTableHeadItemWidget(tableColumn.getTitle()),
        );
        tableHeader.add(tableHeaderItemWidget);
      }
    }

    Widget? firstColumn;
    if (widget.fixedFirstColumnTableColumn != null) {
      var fixedFirstColumnTableColumn = widget.fixedFirstColumnTableColumn!;
      double firstColumnWidth = fixedFirstColumnTableColumn.minWidth;
      firstColumn = SizedBox(
        width: firstColumnWidth,
        child: Column(
          children: [
            SizedBox(
                height: widget.tableHeadHeight, width: firstColumnWidth, child: Center(child: _getTableHeadItemWidget(fixedFirstColumnTableColumn.getTitle()))),
            const _TextColoredDivider(),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  controller: _verticalScrollControllerFirstColumn,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.lineCount,
                  itemBuilder: (context, yIndex) {
                    final cellData = widget.gridCellBuilder(context, yIndex, 0);

                    return Container(
                      color: cellData.backgroundColor,
                      height: widget.lineHeight.toDouble(),
                      width: firstColumnWidth,
                      child: cellData.child,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        if (firstColumn != null) firstColumn,
        Expanded(
          child: Column(
            children: [
              SingleChildScrollView(
                controller: _horizontalScrollControllerTableHead,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: widget.tableHeadHeight,
                  width: columnProfile.minWidth().toDouble(),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: tableHeader),
                ),
              ),
              const _TextColoredDivider(),
              Expanded(
                child: TwoDimensionalGridViewWithScrollbar(
                  lineHeight: widget.lineHeight,
                  tableColumnProfile: columnProfile,
                  viewportSizeKey: widget.viewportSizeKey,
                  twoDimensionalChildBuilderDelegate: widget.twoDimensionalChildBuilderDelegate,

                  verticalScrollController: _verticalScrollControllerGrid,
                  horizontalScrollController: _horizontalScrollControllerGrid,

                  // Hide bottom nav bar on scroll is not really possible because the hide forces the layout builder to rebuild
                  // => the scroll breaks. => Hide bottom nav bar always in grid view
                  // verticalScrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getTableHeadItemWidget(String columnTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OverflowText(
        expanded: false,
        columnTitle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TextColoredDivider extends StatelessWidget {
  const _TextColoredDivider();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Divider(height: 0, color: themeData.textTheme.bodyLarge?.color?.withAlpha(64));
  }
}
