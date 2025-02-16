import 'package:flutter/material.dart';

class Globals {
  static const assetImgEagleLogo = 'assets/images/logos/eagle_logo.png';
  static const assetImgCaLogo = 'assets/images/logos/ca_logo.png';
  static const assetImgExploratiaLogo = 'assets/images/logos/exploratia_logo.png';
  static const assetImgBackground = 'assets/images/logos/app_logo.png';
  static const assetImgAppLogoWhite = 'assets/images/logos/app_logo_white.png';

  static const invalid = 'INVALID';

  static void goToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
