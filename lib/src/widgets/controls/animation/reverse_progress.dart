import 'package:flutter/material.dart';

class ReverseProgress extends StatefulWidget {
  final double maxWidth;
  final double height;
  final Color color;
  final Duration duration;
  final void Function()? onEndCallback;

  const ReverseProgress({
    super.key,
    required this.maxWidth,
    required this.height,
    required this.color,
    required this.duration,
    this.onEndCallback,
  });

  @override
  State<ReverseProgress> createState() => ReverseProgressState();
}

class ReverseProgressState extends State<ReverseProgress> {
  double _progress = 0.0; // 1.0 = full width, 0.0 = empty

  void restart() {
    setState(() {
      _progress = 1.0;
    });

    // back to 0 in order to start animation
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() {
          _progress = 0.0;
        });
      }
    });
  }

  void _onEnd() {
    if (_progress == 0 && widget.onEndCallback != null) {
      widget.onEndCallback!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          onEnd: _onEnd,
          duration: widget.duration,
          width: widget.maxWidth * _progress,
          height: widget.height,
          color: widget.color,
        ),
      ],
    );
  }
}
