import 'dart:math' as math;

import 'chart_utils_simple_value.dart';

/// Calculates signed deltas and optionally marks extreme changes as gaps.
abstract final class ChartDeltaFilter {
  /// Keeps the first reading as the baseline, never as an absolute delta.
  ///
  /// Invalid readings must be removed by the caller. Each reading remains the
  /// baseline for the next delta, including readings whose delta is filtered.
  static List<TimedValue> buildDeltas(List<TimedValue> readings, {required bool filterOutliers}) {
    if (readings.length < 2) return [];
    final deltas = <TimedValue>[
      for (var i = 1; i < readings.length; i++) TimedValue.value(readings[i].dateTime, readings[i].value - readings[i - 1].value),
    ];
    if (!filterOutliers) return deltas;

    final sorted = deltas.map((delta) => delta.value).where((value) => value.isFinite).toList()..sort();
    // A tiny sample cannot reliably distinguish a reset from a real change.
    if (sorted.length < 5) return deltas;
    final median = _median(sorted);
    final deviations = sorted.map((value) => (value - median).abs()).toList()..sort();
    final magnitudes = sorted.map((value) => value.abs()).toList()..sort();
    // MAD is robust against isolated resets. The magnitude floor also handles
    // constant deltas (MAD = 0) without hiding ordinary variation around them.
    final threshold = math.max(6 * 1.4826 * _median(deviations), 5 * _median(magnitudes));
    // With an otherwise constant absolute series there is no useful scale.
    if (threshold == 0 || !threshold.isFinite) return deltas;
    return [
      for (final delta in deltas)
        if ((delta.value - median).abs() > threshold) TimedValue.gap(delta.dateTime) else delta,
    ];
  }

  static double _median(List<double> sorted) {
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[middle] : sorted[middle - 1] / 2 + sorted[middle] / 2;
  }
}
