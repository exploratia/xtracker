import 'package:flutter/material.dart';

class GenericRoute {
  /// route to given screen with default animation
  ///
  /// usage:
  /// `Navigator.push(context, GenericRoute.route( SomeScreen(... ) ));`
  static MaterialPageRoute route(Widget screen) {
    return MaterialPageRoute(
      builder: (BuildContext context) => screen,
    );
  }
}
