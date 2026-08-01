import 'package:flutter/material.dart';

class Globals {
  static const invalid = 'INVALID';

  /// Shows the app-bar button for creating pending-action test messages.
  static const debugShowPendingActionTestButton = false;

  static const backgroundColorSaturday = Color.fromRGBO(128, 128, 128, 0.1);
  static const backgroundColorSunday = Color.fromRGBO(128, 128, 128, 0.2);

  static final Uri urlCoffeeExploratia = Uri.parse('https://coff.ee/exploratia');
  static final Uri urlPaypalMe = Uri.parse('https://paypal.me/adlerchristian1');
  static final Uri urlExploratia = Uri.parse('https://www.exploratia.de');
  static final Uri urlExploratiaXTracker = Uri.parse('https://www.exploratia.de/xtracker.php');
  static final Uri urlPlaystore = Uri.parse('https://play.google.com/store/apps/details?id=de.exploratia.xtracker');
  static final Uri urlEmailFeedback = Uri(scheme: 'mailto', path: 'info@exploratia.de', queryParameters: {'subject': 'Feedback-xTracker'});
  static final Uri urlGithubXtrackerIssues = Uri.parse('https://github.com/exploratia/xtracker/issues');
  static final Uri urlGithubXtracker = Uri.parse('https://github.com/exploratia/xtracker');

  static void goToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
