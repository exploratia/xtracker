import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/administration/logging/log_settings_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';

class LogSettingsScreen extends StatelessWidget {
  static const routeName = '/log_settings_screen';

  const LogSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(t!.logSettingsTitle),
      ),
      body: const LogSettingsView(),
    );
  }
}
