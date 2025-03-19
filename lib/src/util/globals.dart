import 'package:flutter/material.dart';

class Globals {
  static const invalid = 'INVALID';

  static const backgroundColorSaturday = Color.fromRGBO(128, 128, 128, 0.1);
  static const backgroundColorSunday = Color.fromRGBO(128, 128, 128, 0.2);

  static void goToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
