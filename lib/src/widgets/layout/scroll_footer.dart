import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';

/// Footer vor scroll views in order to have enough space when bottom nav bar is not visible
class ScrollFooter extends StatelessWidget {
  final double marginTop;
  final double marginBottom;

  const ScrollFooter({
    super.key,
    this.marginTop = 20,
    this.marginBottom = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: marginTop,
        ),
        SizedBox(
          height: 64,
          child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
        ),
        SizedBox(
          height: marginBottom,
        ),
      ],
    );
  }
}
