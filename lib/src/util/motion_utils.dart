import 'package:flutter/widgets.dart';

/// Central motion durations and accessibility-aware duration resolution.
abstract final class MotionUtils {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration stagger = Duration(milliseconds: 40);
  static const Duration maxStagger = Duration(milliseconds: 160);
  static const Duration viewTransition = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasized = Duration(milliseconds: 250);
  static const Duration complex = Duration(milliseconds: 300);
  static const Duration feedbackRetention = Duration(milliseconds: 400);
  static const Duration routeTransition = Duration(milliseconds: 500);
  static const Duration highlight = Duration(milliseconds: 600);
  static const Duration ambient = Duration(milliseconds: 1200);

  /// Whether the current media settings request motion to be disabled.
  static bool animationsDisabled(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
  }

  /// Returns [Duration.zero] when animations are disabled.
  static Duration resolve(BuildContext context, Duration duration) {
    return animationsDisabled(context) ? Duration.zero : duration;
  }
}
