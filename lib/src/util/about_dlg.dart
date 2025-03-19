import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gen/assets.gen.dart';
import 'app_info.dart';

class AboutDlg {
  static void showAboutDlg(BuildContext context) {
    showAboutDialog(
        context: context,
        applicationVersion: AppInfo.version,
        applicationIcon: SizedBox(
          height: 40,
          width: 40,
          child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
        ),
        applicationName: AppInfo.appName,
        applicationLegalese: '${DateFormat('yyyy').format(DateTime.now())} \u00a9 Christian Adler');
  }
}
