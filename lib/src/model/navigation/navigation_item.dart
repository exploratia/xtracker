import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavigationItem {
  final Icon icon;
  final String routeName;
  final String Function(AppLocalizations t) titleBuilder;

  NavigationItem({
    required this.icon,
    required this.routeName,
    required this.titleBuilder,
  });
}
