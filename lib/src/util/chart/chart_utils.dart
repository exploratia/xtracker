import 'dart:core';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../model/chart/chart_meta_data.dart';
import '../color_utils.dart';

class ChartUtils {
  static const AxisTitles axisTitlesNoTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));
  static const FlGridData noGridData = FlGridData(show: false);
  static final FlBorderData borderData = FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(color: Colors.grey.withAlpha(64), width: 1),
      left: BorderSide(color: Colors.grey.withAlpha(64), width: 1),
      // left: const BorderSide(color: Colors.transparent),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );

  static Widget createTitlesLeft(double value, TitleMeta meta) {
    // if (value % 1 != 0) { // nur ganzzahlig anzeigen
    //   return Container();
    // }
    if (value % 2 != 0) {
      return Container();
    }
    return SideTitleWidget(
      space: 10,
      meta: meta,
      child: Text(meta.formattedValue),
    );
  }

  static Shadow createLineShadow() {
    return const Shadow(color: Colors.black26, offset: Offset(5, 5));
  }

  static LinearGradient? createTopToBottomGradient(List<Color>? gradientColors, {List<double>? stops}) {
    if (gradientColors == null) return null;
    return LinearGradient(
      colors: gradientColors,
      // stops:  [0.0, 1.0], // ohne angabe dyn. verteilt
      stops: (stops == null || stops.length != gradientColors.length) ? null : stops,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient? createBottomToTopGradient(List<Color>? gradientColors, {List<double>? stops}) {
    if (gradientColors == null) return null;
    return LinearGradient(
      colors: gradientColors,
      // stops:  [0.0, 1.0], // ohne angabe dyn. verteilt
      stops: (stops == null || stops.length != gradientColors.length) ? null : stops,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  static FlDotData createDotData(ChartMetaData? chartMetaData) {
    return FlDotData(
      show: chartMetaData?.showDots ?? false,
      getDotPainter: (spot, xPercentage, lineChartBardata, index) {
        var color = lineChartBardata.gradient?.colors.first ?? lineChartBardata.color ?? Colors.blueGrey;
        return FlDotCirclePainter(
          color: color,
          radius: 3,
          strokeWidth: 1,
          strokeColor: ColorUtils.hue(color, 30), // Colors.white,
        );
      },
    );
  }

  static LineTouchData createLineTouchData(
      {int fractionDigits = 2,
      required ThemeData themeData,
      bool showToucheLine = true,
      List<TextSpan> Function(double, double, int)? provideTooltipExt,
      Color Function(double, double, int)? provideTooltipTextColor,
      void Function(FlTouchEvent, LineTouchResponse?)? touchCallback}) {
    return LineTouchData(
      enabled: true,
      touchSpotThreshold: 30,
      handleBuiltInTouches: true,
      touchCallback: touchCallback,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (touchedSpot) => themeData.chipTheme.backgroundColor?.withAlpha(220) ?? Colors.white70,
        tooltipBorder: const BorderSide(
          color: Colors.black26,
          width: 2,
        ),
        getTooltipItems: (touchedSpots) {
          // alles wie default, nur y-Wert gerundet auf <fractionDigits> Stellen
          return touchedSpots.map((touchedSpot) {
            final textStyle = TextStyle(
              color: provideTooltipTextColor?.call(touchedSpot.x, touchedSpot.y, touchedSpot.barIndex) ??
                  touchedSpot.bar.gradient?.colors.first ??
                  touchedSpot.bar.color ??
                  Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: const [Shadow(color: Colors.black, blurRadius: 0, offset: Offset(1, 1))],
            );
            return LineTooltipItem(touchedSpot.y.toStringAsFixed(fractionDigits), textStyle,
                children: provideTooltipExt?.call(touchedSpot.x, touchedSpot.y, touchedSpot.barIndex));
          }).toList();
        },
      ),
      getTouchedSpotIndicator: showToucheLine ? _createTouchedSpotIndicators : _createTouchedSpotIndicatorsWithoutLine,
    );
  }

  static List<TouchedSpotIndicatorData?> _createTouchedSpotIndicators(LineChartBarData barData, List<int> spotIndexes) {
    var flLine = const FlLine(
      color: Colors.grey,
      strokeWidth: 2,
      dashArray: [2, 4],
    );
    var flDotData = FlDotData(
      getDotPainter: (spot, percent, barData, index) {
        return FlDotCirclePainter(
          radius: 4,
          color: Colors.white70,
          strokeWidth: 2,
          strokeColor: Colors.grey,
        );
      },
    );

    List<TouchedSpotIndicatorData?> result = [];
    for (var _ in spotIndexes) {
      result.add(TouchedSpotIndicatorData(
        flLine,
        flDotData,
      ));
    }
    return result;
  }

  static List<TouchedSpotIndicatorData?> _createTouchedSpotIndicatorsWithoutLine(LineChartBarData barData, List<int> spotIndexes) {
    var flLine = const FlLine(
      color: Colors.transparent,
      strokeWidth: 0,
    );
    var flDotData = FlDotData(
      getDotPainter: (spot, percent, barData, index) {
        return FlDotCirclePainter(
          radius: 4,
          color: Colors.white70,
          strokeWidth: 2,
          strokeColor: Colors.grey,
        );
      },
    );

    List<TouchedSpotIndicatorData?> result = [];
    for (var _ in spotIndexes) {
      result.add(TouchedSpotIndicatorData(
        flLine,
        flDotData,
      ));
    }
    return result;
  }
}
