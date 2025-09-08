import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/forecast/weekday_probability_forecaster.dart';

void main() {
  group('Weekday Probability Forecaster', () {
    test('test', () {
      final exampleEvents = <DateTime>[
        DateTime(2025, 6, 2), // Mon / Mo
        DateTime(2025, 6, 9), // Mon / Mo
        DateTime(2025, 6, 16), // Mon / Mo
        DateTime(2025, 6, 18), // Wed / Mi
        DateTime(2025, 6, 25), // Wed / Mi
        DateTime(2025, 7, 5), // Sat / Sa
        DateTime(2025, 7, 12), // Sat / Sa
        DateTime(2025, 8, 1), // Fri / Fr
        DateTime(2025, 8, 15), // Fri / Fr
        DateTime(2025, 8, 29), // Fri / Fr
      ];

      // with smoothing
      // ============
      if (kDebugMode) print("With smoothing");

      var forecaster = WeekdayProbabilityForecaster(
        eventDates: exampleEvents,
        // recommended explicit start / empfohlen explizit
        observationStart: DateTime(2025, 6, 1),
        // "today" / „heute“
        observationEnd: DateTime(2025, 9, 8),
        // Laplace smoothing / Laplace-Glättung
        alpha: 1.0,
        beta: 1.0,
        // newer data weigh more / neuere Daten zählen stärker
        halfLifeDays: 60.0,
      );

      var weekdayPost = forecaster.weekdayPosteriors();

      expect("18.6", (weekdayPost.weekdayPosterior(1) * 100).toStringAsFixed(1));
      expect("9.9", (weekdayPost.weekdayPosterior(2) * 100).toStringAsFixed(1));
      expect("17.7", (weekdayPost.weekdayPosterior(3) * 100).toStringAsFixed(1));
      expect("9.7", (weekdayPost.weekdayPosterior(4) * 100).toStringAsFixed(1));
      expect("31.6", (weekdayPost.weekdayPosterior(5) * 100).toStringAsFixed(1));
      expect("18.8", (weekdayPost.weekdayPosterior(6) * 100).toStringAsFixed(1));
      expect("9.1", (weekdayPost.weekdayPosterior(7) * 100).toStringAsFixed(1));

      // no smoothing
      // ============
      if (kDebugMode) print("\nNo smoothing");

      forecaster = WeekdayProbabilityForecaster(
        eventDates: exampleEvents,
        // recommended explicit start / empfohlen explizit
        observationStart: DateTime(2025, 6, 1),
        // "today" / „heute“
        observationEnd: DateTime(2025, 9, 8),
        // Laplace smoothing / Laplace-Glättung
        alpha: 0.0,
        beta: 0.0,
        // newer data weigh more / neuere Daten zählen stärker
        halfLifeDays: 60.0,
      );

      weekdayPost = forecaster.weekdayPosteriors();

      expect("11.6", (weekdayPost.weekdayPosterior(1) * 100).toStringAsFixed(1));
      expect("0.0", (weekdayPost.weekdayPosterior(2) * 100).toStringAsFixed(1));
      expect("9.8", (weekdayPost.weekdayPosterior(3) * 100).toStringAsFixed(1));
      expect("0.0", (weekdayPost.weekdayPosterior(4) * 100).toStringAsFixed(1));
      expect("27.2", (weekdayPost.weekdayPosterior(5) * 100).toStringAsFixed(1));
      expect("11.5", (weekdayPost.weekdayPosterior(6) * 100).toStringAsFixed(1));
      expect("0.0", (weekdayPost.weekdayPosterior(7) * 100).toStringAsFixed(1));
    });
  });
}
