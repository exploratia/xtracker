import 'package:flutter/material.dart';

class CenteredMessage extends StatelessWidget {
  const CenteredMessage({super.key, required this.message});

  final dynamic message;

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (message is Widget) {
      widget = message;
    } else {
      widget = Text(message.toString());
    }

    return Center(
      child: widget,
    );
  }
}
