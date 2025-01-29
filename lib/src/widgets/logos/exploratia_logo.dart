import 'package:flutter/material.dart';

import '../../util/globals.dart';
import 'circle_logo.dart';

class ExploratiaLogo extends StatelessWidget {
  const ExploratiaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleLogo(Globals.assetImgExploratiaLogo);
  }
}
