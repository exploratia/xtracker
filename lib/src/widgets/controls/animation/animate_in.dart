import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../util/motion_utils.dart';

class AnimateIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool fade;
  final Offset? slideOffset;

  const AnimateIn({
    super.key,
    required this.child,
    this.duration = MotionUtils.standard,
    this.delay = Duration.zero,
    this.fade = true,
    this.slideOffset,
  });

  @override
  State<AnimateIn> createState() => _AnimateInState();
}

class _AnimateInState extends State<AnimateIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: widget.slideOffset ?? const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  Timer? _delayTimer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = MotionUtils.resolve(context, widget.duration);
    if (MotionUtils.animationsDisabled(context)) {
      _delayTimer?.cancel();
      _controller.value = 1;
      _started = true;
      return;
    }
    if (_started) {
      return;
    }
    _started = true;
    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }

    _delayTimer = Timer(
      widget.delay,
      _controller.forward,
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget w = widget.child;

    if (widget.fade) {
      w = FadeTransition(
        opacity: _animation,
        child: w,
      );
    }

    if (widget.slideOffset != null) {
      w = SlideTransition(
        position: _offsetAnimation,
        child: w,
      );
    }

    return w;
  }
}
