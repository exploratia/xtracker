import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class ProgressOverlay {
  static OverlayEntry createAndShowProgressOverlay(BuildContext context) {
    // create
    final overlay = OverlayEntry(
      builder: (_) => AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: CircularProgressIndicator(color: ThemeUtils.primary),
        ),
      ),
    );

    //show
    Overlay.of(context, rootOverlay: true).insert(overlay);

    return overlay;
  }
}
