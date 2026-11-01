import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

/// Full-width wallpaper preview with an optional frame matching the device ratio.
class WallpaperPreview extends StatelessWidget {
  const WallpaperPreview({super.key, required this.child, this.showFrame = false});

  final Widget child;

  /// Whether to outline the device viewport over a custom image.
  final bool showFrame;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: ThemeUtils.borderRadiusCircularLarge,
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (showFrame)
              IgnorePointer(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: MediaQuery.sizeOf(context).aspectRatio,
                    child: DecoratedBox(
                      key: const Key('settingsWallpaperPreviewFrame'),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.onSurface, width: 2),
                        borderRadius: ThemeUtils.borderRadiusCircular,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
