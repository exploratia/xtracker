import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalInputFormatter({this.decimalRange = -1});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // only digits . ,
    final regex = RegExp(r'^[0-9]*[,.]?[0-9]*$');
    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    var split = text.split(RegExp(r'[,.]'));
    // only one separator
    if (split.length > 2) {
      return oldValue;
    }

    // limit decimals
    if (decimalRange > 0 && split.length == 2 && split.last.length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}
