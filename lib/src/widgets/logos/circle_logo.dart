import 'package:flutter/material.dart';

class CircleLogo extends StatelessWidget {
  const CircleLogo({
    super.key,
    required this.img,
    this.radius = 30,
    this.padding = 2,
    this.backgroundColor = Colors.transparent,
  });

  final Image img;
  final double radius;
  final double padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: radius,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: img,
        ),
      ),
    );
  }
}
