import 'package:flutter/material.dart';

import '../../util/globals.dart';
import 'circle_logo.dart';

class EagleLogo extends StatelessWidget {
  const EagleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleLogo(Globals.assetImgEagleLogo);
  }
}
