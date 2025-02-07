import 'package:flutter/material.dart';

class NavBackIconButton extends StatelessWidget {
  const NavBackIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
