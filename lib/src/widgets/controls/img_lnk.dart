import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImgLnk extends StatelessWidget {
  const ImgLnk({super.key, required this.url, required this.imageProvider, required this.height, required this.width, this.darkHover = true});

  final Uri url;
  final ImageProvider<Object> imageProvider;
  final double height;

  final double width;
  final bool darkHover;

  Future<void> _launchUrl() async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _launchUrl,
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
