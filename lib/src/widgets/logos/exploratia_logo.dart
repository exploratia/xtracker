import 'package:flutter/material.dart';

import '../../util/globals.dart';

class ExploratiaLogo extends StatelessWidget {
  const ExploratiaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black26,
      radius: 30,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            Globals.assetImgExploratiaLogo,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
