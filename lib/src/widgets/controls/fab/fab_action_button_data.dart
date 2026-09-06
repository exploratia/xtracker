import 'package:material_ui/material_ui.dart';

class FabActionButtonData {
  final IconData iconData;
  final Function() onPressed;
  final bool autoClose;

  FabActionButtonData(this.iconData, this.onPressed, {this.autoClose = true});
}
