import 'package:material_ui/material_ui.dart';

import '../../../../generated/assets.gen.dart';
import 'circle_logo.dart';

class CaLogo extends CircleLogo {
  CaLogo({super.key, super.radius, super.padding, super.backgroundColor}) : super(img: Assets.images.logos.caLogo.image(fit: BoxFit.cover));
}
