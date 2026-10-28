import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/chart/chart_delta_filter.dart';
import 'package:xtracker/src/util/chart/chart_utils_simple_value.dart';

void main() {
  test('preserves negative, positive and zero deltas without modifying readings', () {
    final readings = _readings([80, 79, 79, 81]);
    final result = ChartDeltaFilter.buildDeltas(readings, filterOutliers: true);
    expect(result.map((value) => value.value), [-1, 0, 2]);
    expect(readings.map((value) => value.value), [80, 79, 79, 81]);
    expect(result.first.dateTime, readings[1].dateTime);
  });

  for (final spike in [-12000.0, 12000.0]) {
    test('filters a $spike transition and uses its reading as the next baseline', () {
      final readings = _fromDeltas([250, 260, 240, spike, 250, 245, 255]);
      final result = ChartDeltaFilter.buildDeltas(readings, filterOutliers: true);
      expect(result[3].isGap, isTrue);
      expect(result[3].dateTime, readings[4].dateTime);
      expect(result.where((value) => !value.isGap).map((value) => value.value), [250, 260, 240, 250, 245, 255]);
      expect(ChartDeltaFilter.buildDeltas(readings, filterOutliers: false)[3].value, spike);
    });
  }

  test('handles zero MAD and preserves ordinary variation and negative changes', () {
    final result = ChartDeltaFilter.buildDeltas(_fromDeltas([10, 10, 10, -1, 11, 1000, 10]), filterOutliers: true);
    expect(result.map((value) => value.isGap), [false, false, false, false, false, true, false]);
  });

  test('keeps ordinary changes around zero and within a variable series', () {
    for (final deltas in [
      <double>[-2, 1, 0, 2, -1, 0],
      <double>[100, 180, -60, 80, 30, 220],
    ]) {
      final result = ChartDeltaFilter.buildDeltas(_fromDeltas(deltas), filterOutliers: true);
      expect(result.map((value) => value.value), deltas);
    }
  });

  test('does not infer outliers from a tiny sample or a zero reference scale', () {
    for (final deltas in [
      <double>[1, 1, -12000, 1],
      <double>[0, 0, 0, 0, 2, 0],
    ]) {
      expect(ChartDeltaFilter.buildDeltas(_fromDeltas(deltas), filterOutliers: true).map((value) => value.value), deltas);
    }
    expect(ChartDeltaFilter.buildDeltas([], filterOutliers: true), isEmpty);
    expect(ChartDeltaFilter.buildDeltas(_readings([80]), filterOutliers: true), isEmpty);
  });

  test('processes a large series without losing points or subsequent baselines', () {
    final readings = _fromDeltas([for (var i = 0; i < 100000; i++) i == 50000 ? -1000000 : 10]);
    final result = ChartDeltaFilter.buildDeltas(readings, filterOutliers: true);
    expect(result, hasLength(100000));
    expect(result.where((value) => value.isGap), hasLength(1));
    expect(result[50001].value, 10);
  });
}

List<TimedValue> _readings(List<double> values) => [
  for (var i = 0; i < values.length; i++) TimedValue.value(DateTime(2026, 1, 1).add(Duration(days: i)), values[i]),
];

List<TimedValue> _fromDeltas(List<double> deltas) {
  var value = 20000.0;
  return _readings([value, for (final delta in deltas) value += delta]);
}
