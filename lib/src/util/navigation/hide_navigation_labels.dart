import 'package:flutter/material.dart';

class HideNavigationLabels {
  static final ValueNotifier<bool> visible = ValueNotifier<bool>(true);

  static void setVisible(bool value) {
    if (visible.value != value) {
      visible.value = value;
    }
  }
}
