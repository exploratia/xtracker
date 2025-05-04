import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../model/chart/chart_meta_data.dart';
import '../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../model/series/data/series_data.dart';
import '../date_time_utils.dart';
import 'chart_utils.dart';

class ChartUtilsBloodPressure {
  static LineChartData buildLineChartData(
      SeriesData<BloodPressureValue> seriesData, ThemeData themeData, Function(FlTouchEvent, LineTouchResponse?)? touchCallback) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = false;

    List<FlSpot> lowValues = [];
    List<FlSpot> highValues = [];

    int highMin = 200;
    int highMax = 0;
    int lowMin = 200;
    int lowMax = 0;

    for (var item in seriesData.data) {
      var lowVal = item.low;
      var highVal = item.high;
      var t = item.dateTime.millisecondsSinceEpoch;

      if (lowVal < lowMin) {
        lowMin = lowVal;
      } else if (lowVal > lowMax) {
        lowMax = lowVal;
      }
      if (highVal < highMin) {
        highMin = highVal;
      } else if (highVal > highMax) {
        highMax = highVal;
      }

      chartMetaData.evaluateMetaData(t, [lowVal, highVal]);

      lowValues.add(FlSpot(t.toDouble(), lowVal.toDouble()));
      highValues.add(FlSpot(t.toDouble(), highVal.toDouble()));
    }

    lineBarsData.add(LineChartBarData(
      spots: highValues,
      isCurved: false,
      preventCurveOverShooting: true,
      barWidth: 2,
      gradient: ChartUtils.createTopToBottomGradient([BloodPressureValue.colorHigh(highMax), BloodPressureValue.colorHigh(highMin)]),
      dotData: ChartUtils.createDotData(chartMetaData),
      isStrokeCapRound: true,
      // dashArray: [5, 5],
    ));
    lineBarsData.add(LineChartBarData(
      spots: lowValues,
      isCurved: false,
      preventCurveOverShooting: true,
      // curveSmoothness: 0.02, // only makes sense if no BetweenBarsData
      barWidth: 2,
      gradient: ChartUtils.createTopToBottomGradient([BloodPressureValue.colorLow(lowMax), BloodPressureValue.colorLow(lowMin)]),
      dotData: ChartUtils.createDotData(chartMetaData),
      isStrokeCapRound: true,
    ));

    chartMetaData.calcPadding();

    return LineChartData(
      minY: chartMetaData.yMinPadded,
      maxY: chartMetaData.yMaxPadded,
      minX: chartMetaData.xMinPadded,
      maxX: chartMetaData.xMaxPadded,
      clipData: const FlClipData.all(),
      lineBarsData: lineBarsData,
      betweenBarsData: [
        BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          gradient: ChartUtils.createTopToBottomGradient([
            BloodPressureValue.colorHigh(chartMetaData.yMax.truncate()).withAlpha(64),
            BloodPressureValue.colorLow(chartMetaData.yMin.truncate()).withAlpha(64),
          ]),
        )
      ],
      borderData: ChartUtils.borderData,
      gridData: ChartUtils.noGridData,
      lineTouchData: ChartUtils.createLineTouchData(
        fractionDigits: 0,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => (barIdx == 0) ? BloodPressureValue.colorHigh(y.truncate()) : BloodPressureValue.colorLow(y.truncate()),
      ),
      titlesData: FlTitlesData(
        rightTitles: ChartUtils.axisTitlesNoTitles,
        topTitles: ChartUtils.axisTitlesNoTitles,
        leftTitles: const AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: false,
            minIncluded: false,
            reservedSize: 40,
            getTitlesWidget: ChartUtils.createTitlesLeft,
          ),
        ),
        bottomTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: true,
            minIncluded: true,
            // https://www.reddit.com/r/flutterhelp/comments/rhb7iu/fl_chart_set_time_series_interval_in_linechart/?rdt=36768
            // interval: (chartMetaData.xMax - chartMetaData.xMin),
            interval: math.max(1, lowValues.last.x - lowValues.first.x),
            getTitlesWidget: (value, meta) {
              if (value == meta.min) {
                // use chartMetaData min/max - not the value which has padding!
                return TitlesWidgetBottomAxis(alignment: Alignment.topLeft, value: chartMetaData.xMin);
              } else if (value == meta.max) {
                return TitlesWidgetBottomAxis(alignment: Alignment.topRight, value: chartMetaData.xMax);
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class TitlesWidgetBottomAxis extends StatelessWidget {
  const TitlesWidgetBottomAxis({
    super.key,
    required this.alignment,
    required this.value,
  });

  final Alignment alignment;
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      // height: 22,
      child: OverflowBox(
        alignment: alignment,
        maxWidth: 180,
        // maxHeight: 22,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(DateTimeUtils.formateDate(DateTime.fromMillisecondsSinceEpoch(value.truncate()))),
        ),
      ),
    );
  }
}
