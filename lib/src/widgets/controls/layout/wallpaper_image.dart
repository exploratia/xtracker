import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/logging/flutter_simple_logging.dart';

/// Fills its available space without distorting the selected image.
class WallpaperImage extends StatelessWidget {
  const WallpaperImage({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) => Image(
    // Limit decoded memory for large gallery photos; keep the source unchanged.
    image: ResizeImage(MemoryImage(bytes), width: 2560, height: 2560, policy: ResizeImagePolicy.fit),
    width: double.infinity,
    height: double.infinity,
    fit: BoxFit.cover,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stackTrace) {
      SimpleLogging.e('Displaying the custom wallpaper failed.', error: error, stackTrace: stackTrace);
      return Center(child: Text(LocaleKeys.settings_general_wallpaper_imageFailure.tr()));
    },
  );
}
