import 'package:flutter/material.dart';

class NavigationItem {
  final Icon icon;
  final String routeName;
  final String Function() titleBuilder;

  NavigationItem({
    required this.icon,
    required this.routeName,
    required this.titleBuilder,
  });
}
