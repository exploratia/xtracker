import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import 'circle_logo.dart';

class EagleLogo extends CircleLogo {
  EagleLogo({super.key, super.radius, super.padding, super.backgroundColor}) : super(img: Assets.images.logos.eagleLogo.image(fit: BoxFit.cover));
}
