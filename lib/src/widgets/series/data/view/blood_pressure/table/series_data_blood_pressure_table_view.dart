import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/profile/table_column_profile.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/table_utils.dart';
import '../../../../../layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../../navigation/hide_bottom_navigation_bar.dart';
import '../../../../../responsive/device_dependent_constrained_box.dart';
import 'blood_pressure_values_renderer.dart';

class SeriesDataBloodPressureTableView extends StatelessWidget {
  const SeriesDataBloodPressureTableView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesData<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final TableColumnProfile tableColumnProfile = TableColumnProfile(columns: [
      TableColumn(minWidth: 80),
      TableColumn(minWidth: 80),
      TableColumn(minWidth: 80),
      TableColumn(minWidth: 80),
    ]);

    final themeData = Theme.of(context);
// TODO seriesViewMetaData.editMode => klick on Renderer
    final t = AppLocalizations.of(context)!;
    // TODO Anhand Breite (zu schmal) fesetlegen, ob Titel in AppBar oder hier in der View anzgeiezt werdne muss
    // TODO immer nur Diagrammsicht / Tabelle und immer Icon + Name als erstes in der View?
    return HideBottomNavigationBar(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // TEST 2D
          if (true) {
            // TODO scrollbars
            // TODO title - in Grid oder ausserhalb stehen bleibend -> scroll controller abfangen
            final TableColumnProfile adjustedTableColumnProfile = tableColumnProfile.adjustToWidth(constraints.maxWidth);
            List<_BloodPressureDayItem> data = _buildTableDataProvider(seriesData);
            // calc line height = single line height * max lines per day of all items
            var maxItemsPerDayPart = data.fold(
              1,
              (previousValue, item) {
                var maxItems = math.max(math.max(item.morning.length, item.midday.length), item.evening.length);
                return math.max(previousValue, maxItems);
              },
            );
            int lineHeight = 26 * maxItemsPerDayPart;

            // adjusted from https://dartpad.dev/?id=4424936c57ed13093eb389123383e894
            var viewportSizeKey = ValueKey('blood_pressure_2d_grid_view_size_key_${constraints.maxWidth}');
            var twoDimensionalChildBuilderDelegate = TwoDimensionalChildBuilderDelegate(
                maxXIndex: adjustedTableColumnProfile.length() - 1,
                maxYIndex: data.length - 1,
                builder: (BuildContext context, ChildVicinity vicinity) {
                  // print('$vicinity');
                  TableColumn tableColumn = adjustedTableColumnProfile.getColumnAt(vicinity.xIndex);
                  var columnWidth = tableColumn.minWidth.toDouble();

                  _BloodPressureDayItem bloodPressureDayItem = data[vicinity.yIndex];
                  Color? backgroundColor = bloodPressureDayItem.backgroundColor;
                  if (vicinity.xIndex == 0) {
                    return Padding(
                      padding: EdgeInsets.only(left: adjustedTableColumnProfile.marginLeft),
                      child: Container(
                        color: backgroundColor,
                        height: lineHeight.toDouble(),
                        width: columnWidth - adjustedTableColumnProfile.marginLeft,
                        child: Center(child: Text(bloodPressureDayItem.date)),
                      ),
                    );
                  }

                  List<BloodPressureValue> bloodPressureValues;
                  if (vicinity.xIndex == 1) {
                    bloodPressureValues = bloodPressureDayItem.morning;
                  } else if (vicinity.xIndex == 2) {
                    bloodPressureValues = bloodPressureDayItem.midday;
                  } else {
                    bloodPressureValues = bloodPressureDayItem.evening;
                  }

                  return Container(
                    color: backgroundColor,
                    height: lineHeight.toDouble(),
                    width: columnWidth,
                    child: BloodPressureValuesRenderer(bloodPressureValues: bloodPressureValues),
                  );
                });
            return TwoDimensionalGridViewWithScrollbar(
              lineHeight: lineHeight,
              tableColumnProfile: adjustedTableColumnProfile,
              viewportSizeKey: viewportSizeKey,
              twoDimensionalChildBuilderDelegate: twoDimensionalChildBuilderDelegate,

              // Hide bottom nav bar on scroll is not really possible because the hide forces the layout builder to rebuild
              // => the scroll breaks. => Hide bottom nav bar always in grid view
              // verticalScrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
            );
          }
          // TEST 2D

          if (constraints.maxWidth < 320) {
            return const Text("TODO 2d grid view");
          } else {
            return SingleChildScrollViewWithScrollbar(
              scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
              child: SizedBox(
                width: math.min(DeviceDependentWidthConstrainedBox.tabletMaxWidth, constraints.maxWidth),
                child: Table(
                  // https://api.flutter.dev/flutter/widgets/Table-class.html
                  columnWidths: const <int, TableColumnWidth>{
                    0: FixedColumnWidth(80),
                    // 0: IntrinsicColumnWidth(),
                    // 0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  border: const TableBorder.symmetric(
                    inside: BorderSide(width: 1, color: Colors.black12),
                  ),
                  children: _buildTableRows(t, themeData),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<TableRow> _buildTableRows(AppLocalizations t, ThemeData themeData) {
    var data = _buildTableDataProvider(seriesData);
    List<TableRow> rows = [
      TableUtils.tableHeadline(
        [
          const _TableHeadline(
            text: 'Datum',
            textAlign: TextAlign.left,
          ),
          _TableHeadline(text: 'Morgens ${t.seriesDataTitle}'),
          const _TableHeadline(text: 'Mittags'),
          const _TableHeadline(text: 'Abends'),
        ],
        cellPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeData.textTheme.bodyMedium?.color ?? Colors.grey,
              width: 1,
            ),
          ),
        ),
      ),
    ];
    rows.addAll(data.map((e) => e.toTableRow()));
    return rows;
  }

  List<_BloodPressureDayItem> _buildTableDataProvider(SeriesData<BloodPressureValue> seriesData) {
    List<_BloodPressureDayItem> list = [];
    const tableItemSaturdayColor = Color.fromRGBO(128, 128, 128, 0.1);
    const tableItemSundayColor = Color.fromRGBO(128, 128, 128, 0.2);

    _BloodPressureDayItem? actItem;

    for (var item in seriesData.seriesItems) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
      if (actItem == null || actItem.date != dateDay) {
        if (actItem != null) {
          list.add(actItem);
        }
        Color? backgroundColor;
        if (item.dateTime.weekday == DateTime.sunday) {
          backgroundColor = tableItemSundayColor;
        } else if (item.dateTime.weekday == DateTime.saturday) {
          backgroundColor = tableItemSaturdayColor;
        }
        actItem = _BloodPressureDayItem(dateDay, backgroundColor);
      }

      if (item.dateTime.hour < 10) {
        actItem.morning.add(item);
      } else if (item.dateTime.hour > 16) {
        actItem.evening.add(item);
      } else {
        actItem.midday.add(item);
      }
    }

    // add last item to list
    if (actItem != null) {
      list.add(actItem);
    }

    return list;
  }
}

class _BloodPressureDayItem {
  final String date;
  final Color? backgroundColor;
  List<BloodPressureValue> morning = [];
  List<BloodPressureValue> midday = [];
  List<BloodPressureValue> evening = [];

  _BloodPressureDayItem(this.date, this.backgroundColor);

  TableRow toTableRow() {
    BoxDecoration? boxDecoration;
    if (backgroundColor != null) {
      boxDecoration = BoxDecoration(color: backgroundColor);
    }
    return TableUtils.tableRow(
      [
        date,
        BloodPressureValuesRenderer(bloodPressureValues: morning),
        BloodPressureValuesRenderer(bloodPressureValues: midday),
        BloodPressureValuesRenderer(bloodPressureValues: evening),
      ],
      decoration: boxDecoration,
    );
  }
}

class _TableHeadline extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const _TableHeadline({required this.text, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class TwoDimensionalGridViewWithScrollbar extends StatefulWidget {
  const TwoDimensionalGridViewWithScrollbar({
    super.key,
    required this.lineHeight,
    required this.tableColumnProfile,
    required this.viewportSizeKey,
    required this.twoDimensionalChildBuilderDelegate,
    this.verticalScrollPositionHandler,
    this.horizontalScrollPositionHandler,
  });

  final int lineHeight;
  final TableColumnProfile tableColumnProfile;
  final ValueKey<String> viewportSizeKey;
  final TwoDimensionalChildBuilderDelegate twoDimensionalChildBuilderDelegate;
  final void Function(ScrollPosition value)? verticalScrollPositionHandler;
  final void Function(ScrollPosition value)? horizontalScrollPositionHandler;

  @override
  State<TwoDimensionalGridViewWithScrollbar> createState() => _TwoDimensionalGridViewWithScrollbarState();
}

class _TwoDimensionalGridViewWithScrollbarState extends State<TwoDimensionalGridViewWithScrollbar> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verticalScrollPositionHandler = widget.verticalScrollPositionHandler;
    if (verticalScrollPositionHandler != null) {
      _verticalController.addListener(() {
        verticalScrollPositionHandler(_verticalController.position);
      });
      // Call callback once direct with initial scroll pos (Show Bottom NavBar if not visible)
      WidgetsBinding.instance.addPostFrameCallback((_) => verticalScrollPositionHandler(_verticalController.position));
    }

    final horizontalScrollPositionHandler = widget.horizontalScrollPositionHandler;
    if (horizontalScrollPositionHandler != null) {
      _horizontalController.addListener(() {
        horizontalScrollPositionHandler(_horizontalController.position);
      });
      // Call callback once direct with initial scroll pos
      WidgetsBinding.instance.addPostFrameCallback((_) => horizontalScrollPositionHandler(_horizontalController.position));
    }

    return Scrollbar(
      controller: _verticalController,
      child: Scrollbar(
        controller: _horizontalController,
        notificationPredicate: (notification) => notification.depth == 0, // Ensure it listens only for the main scroll view
        child: TwoDimensionalGridView(
          widget.lineHeight,
          widget.tableColumnProfile,
          // provide a key depending on maxWidth to the ViewPort to force a rebuild if size changes
          widget.viewportSizeKey,
          diagonalDragBehavior: DiagonalDragBehavior.free,
          delegate: widget.twoDimensionalChildBuilderDelegate,
          verticalController: _verticalController,
          horizontalController: _horizontalController,
        ),
      ),
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  final int lineHeight;
  final TableColumnProfile tableColumnProfile;
  final Key viewportSizeKey;

  TwoDimensionalGridView(
    this.lineHeight,
    this.tableColumnProfile,
    this.viewportSizeKey, {
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
    required ScrollController verticalController,
    required ScrollController horizontalController,
  }) : super(
          delegate: delegate,
          verticalDetails: ScrollableDetails.vertical(controller: verticalController),
          horizontalDetails: ScrollableDetails.horizontal(controller: horizontalController),
        );

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      lineHeight,
      tableColumnProfile,
      key: viewportSizeKey,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  final int lineHeight;
  final TableColumnProfile tableColumnProfile;

  const TwoDimensionalGridViewport(
    this.lineHeight,
    this.tableColumnProfile, {
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      lineHeight,
      tableColumnProfile,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  final int lineHeight;
  final TableColumnProfile tableColumnProfile;

  RenderTwoDimensionalGridViewport(
    this.lineHeight,
    this.tableColumnProfile, {
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate = delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    int leadingColumnIdx = 0;
    int trailingColumnIdx = maxColumnIndex;

    int summedColumnPixels = 0;
    for (var tableColumn in tableColumnProfile.columns) {
      if (summedColumnPixels < horizontalPixels + viewportWidth) {
        trailingColumnIdx++;
      }
      summedColumnPixels += tableColumn.minWidth;
      if (summedColumnPixels < horizontalPixels) {
        leadingColumnIdx++;
      }
    }
    trailingColumnIdx = math.min(maxColumnIndex, trailingColumnIdx);

    final int leadingRow = math.max((verticalPixels / lineHeight).floor(), 0);
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / lineHeight).ceil(),
      maxRowIndex,
    );

    int leadingColumnPixels = 0;
    for (var idx = 0; idx < leadingColumnIdx; ++idx) {
      leadingColumnPixels += tableColumnProfile.getColumnAt(idx).minWidth;
    }

    double xLayoutOffset = leadingColumnPixels - horizontalOffset.pixels;
    for (int columnIdx = leadingColumnIdx; columnIdx <= trailingColumnIdx; columnIdx++) {
      double yLayoutOffset = (leadingRow * lineHeight) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity = ChildVicinity(xIndex: columnIdx, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += lineHeight;
      }
      xLayoutOffset += tableColumnProfile.getColumnAt(columnIdx).minWidth;
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = lineHeight * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );

    final double horizontalExtent = tableColumnProfile.minWidth().toDouble();
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
