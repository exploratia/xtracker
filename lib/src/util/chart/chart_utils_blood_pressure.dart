import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../model/chart/chart_meta_data.dart';
import '../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../date_time_utils.dart';
import '../pair.dart';
import '../theme_utils.dart';
import 'chart_utils.dart';

class ChartUtilsBloodPressure {
  static LineChartData buildLineChartData(List<BloodPressureValue> seriesData, ThemeData themeData, Function(FlTouchEvent, LineTouchResponse?)? touchCallback) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = false;

    List<FlSpot> lowValues = [];
    List<FlSpot> highValues = [];

    int highMin = BloodPressureValue.maxValue;
    int highMax = BloodPressureValue.minValue;
    int lowMin = BloodPressureValue.maxValue;
    int lowMax = BloodPressureValue.minValue;

    for (var item in seriesData) {
      var lowVal = item.low;
      var highVal = item.high;
      var t = item.dateTime.millisecondsSinceEpoch;

      if (lowVal < lowMin) {
        lowMin = lowVal;
      }
      if (lowVal > lowMax) {
        lowMax = lowVal;
      }
      if (highVal < highMin) {
        highMin = highVal;
      }
      if (highVal > highMax) {
        highMax = highVal;
      }

      chartMetaData.evaluateMetaData(t, [lowVal, highVal]);

      lowValues.add(FlSpot(t.toDouble(), lowVal.toDouble()));
      highValues.add(FlSpot(t.toDouble(), highVal.toDouble()));
    }

    var gradientData = buildGradient(highMin.toDouble(), highMax.toDouble(), 120, BloodPressureValue.colorHigh);
    lineBarsData.add(LineChartBarData(
      spots: highValues,
      isCurved: false,
      preventCurveOverShooting: true,
      barWidth: 2,
      gradient: ChartUtils.createBottomToTopGradient(gradientData.k, stops: gradientData.v),
      dotData: ChartUtils.createDotData(chartMetaData),
      isStrokeCapRound: true,
      // dashArray: [5, 5],
    ));

    gradientData = buildGradient(lowMin.toDouble(), lowMax.toDouble(), 80, BloodPressureValue.colorLow);
    lineBarsData.add(LineChartBarData(
      spots: lowValues,
      isCurved: false,
      preventCurveOverShooting: true,
      // curveSmoothness: 0.02, // only makes sense if no BetweenBarsData
      barWidth: 2,
      gradient: ChartUtils.createBottomToTopGradient(gradientData.k, stops: gradientData.v),
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

  static Pair<List<Color>, List<double>> buildGradient(double startValue, double endValue, double optimum, Color Function(int val) colorBuilder) {
    final double mid = optimum;
    final double low = optimum - 40;
    final double high = optimum + 40;

    // helper: check for approximate equality (avoid floating-point issues)
    bool approxEq(double a, double b, [double eps = 1e-9]) => (a - b).abs() <= eps;

    // special case: identical values → use same color twice (valid gradient)
    if (approxEq(startValue, endValue)) {
      final c = colorBuilder(startValue.toInt());
      return Pair(
        [c, c],
        const [0.0, 1.0],
      );
    }

    // check if gradient direction is descendin
    final bool descending = endValue < startValue;

    // thresholds that lie *between* start and end
    final double minV = math.min(startValue, endValue);
    final double maxV = math.max(startValue, endValue);
    final thresholdsInRange = <double>[
      if (low > minV && low < maxV) low,
      if (mid > minV && mid < maxV) mid,
      if (high > minV && high < maxV) high,
    ]..sort((a, b) => descending ? b.compareTo(a) : a.compareTo(b));

    // build knots: start → possible thresholds → end (in direction order)
    final knots = <double>[startValue, ...thresholdsInRange, endValue];

    // normalize value to [0..1] relative to start/end
    double tOf(double v) => ((v - startValue) / (endValue - startValue)).clamp(0.0, 1.0);

    final colors = <Color>[];
    final stops = <double>[];

    for (final v in knots) {
      colors.add(colorBuilder(v.toInt()));
      stops.add(tOf(v));
    }

// enforce exact 0.0/1.0 at first/last stop
    stops[0] = 0.0;
    stops[stops.length - 1] = 1.0;

    return Pair(colors, stops);
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
          padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.paddingSmall, vertical: ThemeUtils.paddingSmall / 2),
          child: Text(DateTimeUtils.formateDate(DateTime.fromMillisecondsSinceEpoch(value.truncate()))),
        ),
      ),
    );
  }
}
