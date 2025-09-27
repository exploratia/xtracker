import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class NavBackIconButton extends StatelessWidget {
  const NavBackIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: ThemeUtils.iconSizeScaled,
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
