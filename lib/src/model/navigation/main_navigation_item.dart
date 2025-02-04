import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainNavigationItem {
  final Icon icon;
  final String routeName;
  final String Function(AppLocalizations t) titleBuilder;
  final Widget Function() screenBuilder;

  MainNavigationItem({
    required this.icon,
    required this.routeName,
    required this.titleBuilder,
    required this.screenBuilder,
  });

  void onNav(BuildContext context) {
    print("TODO nav");
  }
}
