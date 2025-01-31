import 'package:flutter/material.dart';

class CircleLogo extends StatelessWidget {
  const CircleLogo({
    super.key,
    required this.imgAsset,
    this.radius = 30,
    this.padding = 2,
  });

  final String imgAsset;
  final double radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: radius,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            imgAsset,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
