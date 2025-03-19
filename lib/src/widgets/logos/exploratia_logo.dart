import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import 'circle_logo.dart';

class ExploratiaLogo extends CircleLogo {
  ExploratiaLogo({super.key, super.radius, super.padding, super.backgroundColor}) : super(img: Assets.images.logos.exploratiaLogo.image(fit: BoxFit.cover));
}
