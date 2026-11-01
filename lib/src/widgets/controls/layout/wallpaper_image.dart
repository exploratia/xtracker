import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/wallpaper/wallpaper_image_lighting.dart';

/// Fills its space with the selected image and adapts its lighting to the day.
class WallpaperImage extends StatelessWidget {
  const WallpaperImage({super.key, required this.bytes, required this.percentOfDay, required this.lighting});

  final Uint8List bytes;

  /// Fraction of the local day, shared by the clock and settings preview.
  final double percentOfDay;

  /// Analysis shared by all views of this image; rendering never samples pixels.
  final WallpaperImageLighting lighting;

  @override
  Widget build(BuildContext context) => ColorFiltered(
    colorFilter: lighting.filterAt(percentOfDay),
    child: _buildImage(),
  );

  Widget _buildImage() => Image(
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
