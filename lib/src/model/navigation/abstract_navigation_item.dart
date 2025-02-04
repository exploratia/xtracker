import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class AbstractNavigationItem {
  final Icon icon;
  final String routeName;
  final String Function(AppLocalizations t) titleBuilder;
  final Widget Function() screenBuilder;

  AbstractNavigationItem({
    required this.icon,
    required this.routeName,
    required this.titleBuilder,
    required this.screenBuilder,
  });
}
