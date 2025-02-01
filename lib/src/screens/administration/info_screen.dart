import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/administration/info_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';

class InfoScreen extends StatelessWidget {
  static const routeName = '/info';

  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(t!.infoTitle),
      ),
      body: const InfoView(),
    );
  }
}
