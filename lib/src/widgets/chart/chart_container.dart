import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  const ChartContainer({super.key, required this.child});

  // TODO Name/Title
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // bool isPortrait = constraints.maxHeight > constraints.maxWidth;
        return SizedBox(
          width: double.infinity,
          height: 300,
          child: child,
          // child: AspectRatio(
          //   aspectRatio: isPortrait ? 3 / 2 : 3 / 1,
          //   child: child,
          // ),
        );
      },
    );
  }
}
