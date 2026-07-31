import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/theme_utils.dart';
import '../animation/fade_in.dart';

/// Blocking overlay shown while an automatic backup is running.
class AnimatedBackupOverlay extends StatefulWidget {
  const AnimatedBackupOverlay({super.key});

  static OverlayEntry show(BuildContext context) {
    final entry = OverlayEntry(builder: (_) => const AnimatedBackupOverlay());
    Overlay.of(context, rootOverlay: true).insert(entry);
    return entry;
  }

  @override
  State<AnimatedBackupOverlay> createState() => _AnimatedBackupOverlayState();
}

class _AnimatedBackupOverlayState extends State<AnimatedBackupOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1200),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _movement = Tween<double>(begin: -5, end: 5).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AbsorbPointer(
      absorbing: true,
      child: ColoredBox(
        color: colors.scrim.withValues(alpha: 0.65),
        child: Center(
          child: FadeIn(
            durationMS: ThemeUtils.animationDuration,
            child: Card(
              child: Padding(
                padding: ThemeUtils.cardPaddingAll,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: ThemeUtils.verticalSpacing,
                  children: [
                    AnimatedBuilder(
                      animation: _movement,
                      builder: (_, child) => Transform.translate(offset: Offset(0, _movement.value), child: child),
                      child: Icon(Icons.cloud_upload_outlined, size: 56, color: colors.primary),
                    ),
                    const CircularProgressIndicator(),
                    Text(LocaleKeys.autoBackup_overlay_label.tr()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
