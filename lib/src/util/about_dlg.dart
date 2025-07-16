import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.gen.dart';
import '../../generated/locale_keys.g.dart';
import 'app_info.dart';

class AboutDlg {
  static void showAboutDlg(BuildContext context) {
    showAboutDialog(
        context: context,
        applicationVersion: AppInfo.version,
        applicationIcon: SizedBox(
          height: 64,
          width: 64,
          child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
        ),
        applicationName: /*AppInfo.appName*/ LocaleKeys.appTitle.tr(),
        applicationLegalese: '${DateFormat('yyyy').format(DateTime.now())} \u00a9 Christian Adler');
  }
}
