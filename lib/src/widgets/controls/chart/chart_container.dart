import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../util/date_time_utils.dart';

class ChartContainer extends StatelessWidget {
  const ChartContainer({
    super.key,
    this.title,
    this.showDateTooltip = false,
    required this.chartWidgetBuilder,
    this.dateFormatter,
    required this.maxVisibleHeight,
  });

  final Widget? title;
  final bool showDateTooltip;
  final Widget Function(Function(FlTouchEvent, LineTouchResponse?)? touchCallback) chartWidgetBuilder;
  final String Function(DateTime dateTime)? dateFormatter;
  final double maxVisibleHeight;

  final double _maxChartHeight = 300;
  final double _minChartHeight = 100;

  @override
  Widget build(BuildContext context) {
    double chartContainerHeight = math.min(math.max(maxVisibleHeight, _minChartHeight), _maxChartHeight);

    Widget chart;
    if (!showDateTooltip) {
      chart = chartWidgetBuilder(null);
    } else {
      chart = _ChartContainerWithDateTooltip(
        chartWidgetBuilder: chartWidgetBuilder,
        dateFormatter: dateFormatter ?? DateTimeUtils.formateDate,
      );
    }

    return Column(
      children: [
        if (title != null) title!,
        SizedBox(
          width: double.infinity,
          height: chartContainerHeight,
          child: chart,
          // child: AspectRatio(
          //   aspectRatio: isPortrait ? 3 / 2 : 3 / 1,
          //   child: child,
          // ),
        )
      ],
    );
  }
}

class _ChartContainerWithDateTooltip extends StatelessWidget {
  _ChartContainerWithDateTooltip({
    required this.chartWidgetBuilder,
    required this.dateFormatter,
  });

  final Widget Function(Function(FlTouchEvent, LineTouchResponse?)? touchCallback) chartWidgetBuilder;
  final String Function(DateTime dateTime) dateFormatter;
  final GlobalKey<_TooltipState> childKey = GlobalKey<_TooltipState>();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      chartWidgetBuilder((event, touchResponse) => childKey.currentState?.touchCallback(event, touchResponse)),
      _Tooltip(key: childKey, dateFormatter: dateFormatter),
    ]);
  }
}

class _Tooltip extends StatefulWidget {
  const _Tooltip({super.key, required this.dateFormatter});

  final String Function(DateTime dateTime) dateFormatter;

  @override
  State<_Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<_Tooltip> {
  double? _xValue;
  Offset? _tooltipPosition;

  void touchCallback(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (event is FlTapDownEvent || event is FlPointerHoverEvent || event is FlPanStartEvent || event is FlPanUpdateEvent) {
      setState(() {
        if (touchResponse != null) {
          if (touchResponse.lineBarSpots != null && touchResponse.lineBarSpots!.isNotEmpty) {
            _xValue = touchResponse.lineBarSpots!.first.x;
            _tooltipPosition = event.localPosition;
          } else {
            // if no lineBarSpots hide DateTooltip
            _xValue = null;
            _tooltipPosition = null;
          }
        }
      });
    } else if (event is FlPointerExitEvent || event is FlTapUpEvent || event is FlPanEndEvent) {
      setState(() {
        _xValue = null;
        _tooltipPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    if (_xValue != null) {
      return Positioned(
          left: _tooltipPosition!.dx, // - 40, // Adjust position
          bottom: 3,
          child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                color: themeData.chipTheme.backgroundColor?.withAlpha(220),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                child: Text(widget.dateFormatter(DateTime.fromMillisecondsSinceEpoch(_xValue!.truncate()))),
              )));
    }
    return Positioned(child: Container());
  }
}
