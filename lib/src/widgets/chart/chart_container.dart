import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../util/date_time_utils.dart';

class ChartContainer extends StatelessWidget {
  const ChartContainer({super.key, this.title, this.showDateTooltip = false, required this.chartWidgetBuilder, this.dateFormatter});

  final Widget? title;
  final bool showDateTooltip;
  final Widget Function(int maxWidth, Function(FlTouchEvent, LineTouchResponse?)? touchCallback) chartWidgetBuilder;
  final String Function(DateTime dateTime)? dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null) title!,
        LayoutBuilder(
          builder: (context, constraints) {
            // bool isPortrait = constraints.maxHeight > constraints.maxWidth;
            var maxWidth = constraints.maxWidth.truncate();
            Widget? chart;
            if (!showDateTooltip) {
              chart = chartWidgetBuilder(maxWidth, null);
            }
            return SizedBox(
              width: double.infinity,
              height: 300,
              child: chart ??
                  _ChartContainerWithDateTooltip(
                    maxWidth: maxWidth,
                    chartWidgetBuilder: chartWidgetBuilder,
                    dateFormatter: dateFormatter ?? DateTimeUtils.formateDate,
                  ),
              // child: AspectRatio(
              //   aspectRatio: isPortrait ? 3 / 2 : 3 / 1,
              //   child: child,
              // ),
            );
          },
        ),
      ],
    );
  }
}

class _ChartContainerWithDateTooltip extends StatefulWidget {
  const _ChartContainerWithDateTooltip({
    required this.chartWidgetBuilder,
    required this.maxWidth,
    required this.dateFormatter,
  });

  final int maxWidth;
  final Widget Function(int maxWidth, Function(FlTouchEvent, LineTouchResponse?)? touchCallback) chartWidgetBuilder;
  final String Function(DateTime dateTime) dateFormatter;

  @override
  State<_ChartContainerWithDateTooltip> createState() => _ChartContainerWithDateTooltipState();
}

class _ChartContainerWithDateTooltipState extends State<_ChartContainerWithDateTooltip> {
  double? _xValue;
  Offset? _tooltipPosition;

  @override
  void initState() {
    super.initState();
  }

  void touchCallback(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (event is FlTapDownEvent || event is FlPointerHoverEvent) {
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
    } else if (event is FlPointerExitEvent || event is FlTapUpEvent) {
      setState(() {
        _xValue = null;
        _tooltipPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Stack(children: [
      widget.chartWidgetBuilder(widget.maxWidth, touchCallback),
      if (_xValue != null)
        Positioned(
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
                ))),
    ]);
  }
}
