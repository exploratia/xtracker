import 'package:flutter/material.dart';

import '../../util/globals.dart';
import 'circle_logo.dart';

class CaLogo extends StatelessWidget {
  const CaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleLogo(Globals.assetImgCaLogo);
  }
}
