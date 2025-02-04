import 'package:flutter/material.dart';

class Globals {
  static const assetImgEagleLogo = 'assets/images/logos/eagle_logo.jpg';
  static const assetImgCaLogo = 'assets/images/logos/ca_logo.jpg';
  static const assetImgExploratiaLogo =
      'assets/images/logos/exploratia_logo.jpg';
  static const assetImgBackground = 'assets/images/logos/app_logo.png';
  static const assetImgAppLogoWhite = 'assets/images/logos/app_logo_white.png';

  static void goToHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  /// global scaffoldKey - to check the drawer state and close the drawer on back-tap
  static final GlobalKey<ScaffoldState> homeScaffoldKey =
      GlobalKey<ScaffoldState>();
}
