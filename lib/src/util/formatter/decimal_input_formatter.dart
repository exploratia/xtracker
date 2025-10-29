import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // only digits . ,
    final regex = RegExp(r'^[0-9,.]*$');
    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }
}
