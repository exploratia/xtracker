import 'package:flutter/material.dart';

import '../../util/globals.dart';
import '../../widgets/administration/administration_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';

class AdministrationScreen extends StatelessWidget {
  static const routeName = '/administration_screen';
  static const icon = Icon(Icons.more_horiz);

  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar.build(
          context,
          title: SizedBox(
            width: 30,
            child: Image.asset(
              Globals.assetImgAppLogoWhite,
              fit: BoxFit.cover,
            ),
          ),
        ),
        body: const AdministrationView());
  }
}
