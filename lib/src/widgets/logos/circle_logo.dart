import 'package:flutter/material.dart';

class CircleLogo extends StatelessWidget {
  const CircleLogo(
    this.imgAsset, {
    super.key,
  });

  final String imgAsset;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black26,
      radius: 30,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            imgAsset,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
