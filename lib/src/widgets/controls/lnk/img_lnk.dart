import 'package:flutter/material.dart';

import '../../../util/launch_uri.dart';

class ImgLnk extends StatelessWidget {
  const ImgLnk({super.key, required this.uri, required this.imageProvider, required this.height, required this.width, this.darkHover = true});

  final Uri uri;
  final ImageProvider<Object> imageProvider;
  final double height;

  final double width;
  final bool darkHover;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => LaunchUri.launchUri(uri),
        splashColor: darkHover ? Colors.black12 : Colors.white30,
        hoverColor: darkHover ? Colors.black12 : Colors.white10,
        child: Ink(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
