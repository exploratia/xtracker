import 'package:flutter/material.dart';

class FullHeight extends StatelessWidget {
  const FullHeight({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        color: Colors.green,
        height: constraints.maxHeight,
        child: child,
      ),
    );
  }
}
