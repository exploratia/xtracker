import 'dart:async';
import 'dart:ui';

class Defer {
  static const Duration defaultDuration = Duration(milliseconds: 300);

  final Duration delay;
  Timer? _timer;

  Defer({this.delay = defaultDuration});

  void call(VoidCallback action) {
    _timer?.cancel(); // vorherigen Timer abbrechen
    _timer = Timer(delay, action); // neuen Timer starten
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

class StaticDefer {
  static Timer? _timer;

  static void call(VoidCallback action, Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
