import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/administration/logging/log_settings_view.dart';

class LogSettingsScreen extends StatelessWidget {
  static const routeName = '/log_settings_screen';

  const LogSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t!.logSettingsTitle),
      ),
      body:
          Padding(padding: const EdgeInsets.all(16), child: LogSettingsView()),
    );
  }
}
