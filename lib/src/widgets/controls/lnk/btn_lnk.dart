import 'package:flutter/material.dart';

import '../../../util/launch_uri.dart';

class BtnLnk extends StatelessWidget {
  const BtnLnk({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () => LaunchUri.launchUri(uri), child: Text(uri.toString()));
  }
}
