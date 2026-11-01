import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/wallpaper_style.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/theme_utils.dart';
import '../../controls/layout/wallpaper_image.dart';
import '../../controls/live_wallpaper/wallpaper_day_cycle.dart';
import '../../controls/live_wallpaper/wallpaper_scene.dart';
import 'settings_controller.dart';
import 'wallpaper_style_select.dart';

/// Motif selection and an on-demand preview of every time of day.
class WallpaperSettings extends StatefulWidget {
  const WallpaperSettings({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<WallpaperSettings> createState() => _WallpaperSettingsState();
}

class _WallpaperSettingsState extends State<WallpaperSettings> {
  double _previewTime = WallpaperDayCycle.fractionAt(DateTime.now());
  bool _saving = false;
  bool _savingDataVisibility = false;

  Future<void> _updateDataVisibility(bool value) async {
    if (_savingDataVisibility) return;
    setState(() => _savingDataVisibility = true);
    try {
      await widget.controller.updateShowWallpaperOnDataScreens(value);
    } catch (error, stackTrace) {
      SimpleLogging.e('Saving data screen wallpaper visibility failed.', error: error, stackTrace: stackTrace);
      if (mounted) Dialogs.showSnackBarWarning(LocaleKeys.settings_general_wallpaper_saveFailure.tr(), context);
    } finally {
      if (mounted) setState(() => _savingDataVisibility = false);
    }
  }

  Future<void> _selectStyle(WallpaperStyle? style) async {
    if (style == null || _saving) return;
    setState(() => _saving = true);
    try {
      if (style == WallpaperStyle.customImage && widget.controller.wallpaperImage == null) {
        await widget.controller.selectWallpaperImage();
      } else {
        await widget.controller.updateWallpaperStyle(style);
      }
    } catch (error, stackTrace) {
      SimpleLogging.e('Saving wallpaper selection failed.', error: error, stackTrace: stackTrace);
      if (mounted) {
        final message = style == WallpaperStyle.customImage
            ? LocaleKeys.settings_general_wallpaper_imageFailure
            : LocaleKeys.settings_general_wallpaper_saveFailure;
        Dialogs.showSnackBarWarning(message.tr(), context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectImage() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.controller.selectWallpaperImage();
    } catch (error, stackTrace) {
      SimpleLogging.e('Selecting a custom wallpaper failed.', error: error, stackTrace: stackTrace);
      if (mounted) Dialogs.showSnackBarWarning(LocaleKeys.settings_general_wallpaper_imageFailure.tr(), context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.controller.showWallpaper;
    final customImage = widget.controller.wallpaperStyle == WallpaperStyle.customImage;
    final timeLabel = DateFormat.Hm(context.locale.toString()).format(DateTime(2026, 1, 1, 0, (_previewTime * 1440).round()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding),
          value: widget.controller.hideWallpaper,
          onChanged: widget.controller.updateHideWallpaper,
          title: Text(LocaleKeys.settings_general_label_hideWallpaper.tr()),
        ),
        Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                key: const Key('settingsShowWallpaperOnDataScreens'),
                contentPadding: const EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding),
                value: widget.controller.showWallpaperOnDataScreens,
                onChanged: !enabled || _savingDataVisibility ? null : _updateDataVisibility,
                title: Text(LocaleKeys.settings_general_label_showWallpaperOnDataScreens.tr()),
              ),
              WallpaperStyleSelect(
                value: widget.controller.wallpaperStyle,
                onChanged: !enabled || _saving ? null : _selectStyle,
              ),
              const SizedBox(height: ThemeUtils.verticalSpacing),
              if (widget.controller.wallpaperImageLoadFailed)
                Text(LocaleKeys.settings_general_wallpaper_imageFailure.tr(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ClipRRect(
                borderRadius: ThemeUtils.borderRadiusCircularLarge,
                child: SizedBox(
                  height: 220,
                  child: customImage && widget.controller.wallpaperImage != null
                      ? WallpaperImage(bytes: widget.controller.wallpaperImage!)
                      : WallpaperScene(style: widget.controller.wallpaperStyle, percentOfDay: _previewTime),
                ),
              ),
              if (customImage)
                Padding(
                  padding: const EdgeInsets.only(top: ThemeUtils.verticalSpacingSmall),
                  child: OutlinedButton.icon(
                    key: const Key('settingsWallpaperChangeImage'),
                    onPressed: enabled && !_saving ? _selectImage : null,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(LocaleKeys.settings_general_wallpaper_changeImage.tr()),
                  ),
                ),
              if (!customImage)
                Padding(
                  padding: const EdgeInsets.only(top: ThemeUtils.verticalSpacingSmall, left: ThemeUtils.defaultPadding),
                  child: Text(LocaleKeys.settings_general_wallpaper_previewTime.tr(args: [timeLabel])),
                ),
              if (!customImage)
                Slider(
                  value: _previewTime,
                  divisions: 96,
                  label: timeLabel,
                  semanticFormatterCallback: (_) => timeLabel,
                  onChanged: enabled ? (value) => setState(() => _previewTime = value) : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
