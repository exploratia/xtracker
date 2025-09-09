import 'dart:math';

import 'trend/trend_data_values_datetime.dart';

/// Calculates the probability of an event occurring on the next 7 calendar days
/// based on historical event data.
///
/// - Empirical estimation per weekday
/// - Optionally with Bayesian smoothing (alpha/beta)
/// - Optionally with recency weighting (halfLifeDays)
///
/// Expectation: [eventDates] contains all calendar days where at least one event occurred.
///
/// Tip: Set [observationStart] explicitly, otherwise min(eventDates) is used.
/// [observationEnd] default: today.
///
/// ---
/// Berechnet für die nächsten 7 Kalendertage die Eintrittswahrscheinlichkeit
/// eines Ereignisses basierend auf historischen Ereignis-Daten.
///
/// - Empirische Schätzung je Wochentag
/// - Optionale Bayes-Glättung (alpha/beta)
/// - Optionale Recency-Gewichtung (halfLifeDays)
///
/// Erwartung: Tage ohne Ereignis stehen nicht in der Liste.
///
/// Tipp: Setze [observationStart] explizit, sonst wird min(eventDates) verwendet.
/// [observationEnd] default: heute.
///
class WeekdayProbabilityForecaster {
  final Set<DateTime> _eventDays; // only date part (local), no time / nur Datumsteil (lokal) ohne Zeit
  final DateTime observationStart;
  final DateTime observationEnd;
  final double alpha; // Beta prior alpha (Laplace: 0.0) / Beta-Prior alpha (Laplace: 0.0)
  final double beta; // Beta prior beta  (Laplace: 0.0) / Beta-Prior beta  (Laplace: 0.0)
  final double? halfLifeDays; // e.g. 60.0 => newer days weigh more / z.B. 60.0 => neuere Tage wiegen mehr

  WeekdayProbabilityForecaster({
    required List<DateTime> eventDates,
    DateTime? observationStart,
    DateTime? observationEnd,
    this.alpha = 0.0,
    this.beta = 0.0,
    this.halfLifeDays,
  })  : _eventDays = _normalizeToLocalDateSet(eventDates),
        observationStart = (observationStart ??
            _normalizeToLocalDate(
              eventDates.isEmpty ? DateTime.now() : _minDate(eventDates),
            )),
        observationEnd = _normalizeToLocalDate(observationEnd ?? DateTime.now());

  /// Returns posterior probabilities p(Event | Weekday) for Mon..Sun (index 1..7)
  /// according to DateTime.weekday (1=Mon,...,7=Sun).
  /// index 0 is invalid
  ///
  /// ---
  /// Liefert die posterioren p(Ereignis | Wochentag) für Mo..So (index 1..7)
  /// gemäß DateTime.weekday (1=Mo,...,7=So).
  /// Index 0 ist ungültig
  ///
  List<double> weekdayPosteriorsAsList() {
    final events = List<double>.filled(8, 0.0); // index 0 unused / 0 ungenutzt
    final exposures = List<double>.filled(8, 0.0);

    final totalDays = observationEnd.difference(observationStart).inDays + 1;
    for (int i = 0; i < totalDays; i++) {
      final day = _normalizeToLocalDate(observationStart.add(Duration(days: i)));
      final wd = day.weekday; // 1..7
      final w = _weightFor(day); // recency weighting / Recency-Gewichtung
      exposures[wd] += w;
      if (_eventDays.contains(day)) {
        events[wd] += w;
      }
    }

    final probabilities = List<double>.filled(8, 0.0);
    probabilities[0] = -1;
    for (int wd = 1; wd <= 7; wd++) {
      // if there is no smoothing check division by 0!
      var divisor = (exposures[wd] + alpha + beta);
      if (divisor != 0) {
        probabilities[wd] = (events[wd] + alpha) / divisor;
      }
    }
    return probabilities;
  }

  WeekdayPosteriors weekdayPosteriors() => WeekdayPosteriors(weekdayPosteriorsAsList());

  double _weightFor(DateTime day) {
    if (halfLifeDays == null) return 1.0;
    final ageDays = observationEnd.difference(day).inDays.toDouble();
    // Weight = 0.5^(age/halfLife) => half-life weighting
    // Gewicht = 0.5^(age/halfLife) => Halbwertszeit
    return pow(0.5, ageDays / halfLifeDays!).toDouble();
  }

  static Set<DateTime> _normalizeToLocalDateSet(List<DateTime> dates) {
    return dates.map(_normalizeToLocalDate).toSet();
  }

  static DateTime _normalizeToLocalDate(DateTime dt) {
    // Cut off time part, use local timezone
    // Schneidet Zeitanteil ab und nutzt lokale Zeitzone.
    return DateTime(dt.year, dt.month, dt.day);
  }

  static DateTime _minDate(List<DateTime> dates) {
    var m = dates.first;
    for (final d in dates) {
      if (d.isBefore(m)) m = d;
    }
    return m;
  }

  /// Returns posterior probabilities p(Event | Weekday) for Mon..Sun (index 1..7)
  /// according to DateTime.weekday (1=Mon,...,7=Sun).
  ///
  /// ---
  /// Liefert die posterioren p(Ereignis | Wochentag) für Mo..So (index 1..7)
  /// gemäß DateTime.weekday (1=Mo,...,7=So).
  ///
  static WeekdayPosteriors calcWeekDayProbability(TrendDataValuesDateTime trendDataValuesDateTime, {bool ignoreZeroValues = false}) {
    var filtered = trendDataValuesDateTime.values.where((element) => ignoreZeroValues ? element.y != 0 : true);
    final forecaster = WeekdayProbabilityForecaster(
      eventDates: filtered.map((e) => e.x).toList(),
      halfLifeDays: 21,
    );
    return forecaster.weekdayPosteriors();
  }
}

class WeekdayPosteriors {
  final List<double> weekdayPosteriors;

  WeekdayPosteriors(this.weekdayPosteriors);

  /// returns the probability for the given week day
  double weekdayPosterior(int wd) {
    if (wd < 1 || wd > 7) return 0;
    return weekdayPosteriors[wd];
  }
}
