import 'package:material_ui/material_ui.dart';

import 'fade_transition_builder.dart';
import 'no_transition_builder.dart';
import '../motion_utils.dart';

class NavigatorTransitionBuilder {
  /// usage:
  /// Navigator.of(context).push(
  ///             NavigatorTransitionBuilder.buildSlideHTransition(context, SomeScreen()),
  ///           );
  static PageRouteBuilder buildSlideHTransition(BuildContext context, Widget screen) {
    return PageRouteBuilder(
      transitionDuration: MotionUtils.resolve(context, MotionUtils.routeTransition),
      reverseTransitionDuration: MotionUtils.resolve(context, MotionUtils.complex),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      // transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      //     const FadeTransitionsBuilder().buildTransitions(null, context, animation, secondaryAnimation, child),
    );
  }

  static PageRouteBuilder buildFadeTransition(BuildContext context, Widget screen) {
    return PageRouteBuilder(
      transitionDuration: MotionUtils.resolve(context, MotionUtils.routeTransition),
      reverseTransitionDuration: MotionUtils.resolve(context, MotionUtils.complex),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          const FadeTransitionsBuilder().buildTransitions(null, context, animation, secondaryAnimation, child),
    );
  }

  static PageRouteBuilder buildNoTransition(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 0),
      reverseTransitionDuration: const Duration(milliseconds: 0),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          const NoTransitionsBuilder().buildTransitions(null, context, animation, secondaryAnimation, child),
    );
  }
}
