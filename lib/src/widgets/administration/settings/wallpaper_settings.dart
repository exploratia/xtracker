import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/wallpaper_style.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/table_utils.dart';
import '../../../util/theme_utils.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';
import '../../controls/live_wallpaper/wallpaper_day_cycle.dart';
import '../../controls/live_wallpaper/wallpaper_scene.dart';
import 'settings_controller.dart';

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

  Future<void> _selectStyle(WallpaperStyle? style) async {
    if (style == null || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.controller.updateWallpaperStyle(style);
    } catch (error, stackTrace) {
      SimpleLogging.e('Saving wallpaper selection failed.', error: error, stackTrace: stackTrace);
      if (mounted) Dialogs.showSnackBarWarning(LocaleKeys.settings_general_wallpaper_saveFailure.tr(), context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        LayoutBuilder(
          builder: (context, constraints) => Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
            children: [
              TableUtils.tableRow([
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.45),
                  child: Text(LocaleKeys.settings_general_wallpaper_label.tr()),
                ),
                DropdownButton<WallpaperStyle>(
                  key: const Key('settingsWallpaperSelect'),
                  value: widget.controller.wallpaperStyle,
                  isExpanded: true,
                  borderRadius: ThemeUtils.cardBorderRadius,
                  onChanged: _saving ? null : _selectStyle,
                  items: WallpaperStyle.values
                      .map(
                        (style) => DropdownMenuItem(
                          value: style,
                          child: DropDownMenuItemChild(
                            selected: widget.controller.wallpaperStyle == style,
                            child: Text(switch (style) {
                              WallpaperStyle.hills => LocaleKeys.settings_general_wallpaper_hills.tr(),
                              WallpaperStyle.mountainLake => LocaleKeys.settings_general_wallpaper_mountainLake.tr(),
                              WallpaperStyle.riverValley => LocaleKeys.settings_general_wallpaper_riverValley.tr(),
                            }, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: ThemeUtils.verticalSpacing),
        ClipRRect(
          borderRadius: ThemeUtils.borderRadiusCircularLarge,
          child: SizedBox(
            height: 220,
            child: WallpaperScene(style: widget.controller.wallpaperStyle, percentOfDay: _previewTime),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: ThemeUtils.verticalSpacingSmall, left: ThemeUtils.defaultPadding),
          child: Text(LocaleKeys.settings_general_wallpaper_previewTime.tr(args: [timeLabel])),
        ),
        Slider(
          value: _previewTime,
          divisions: 96,
          label: timeLabel,
          semanticFormatterCallback: (_) => timeLabel,
          onChanged: (value) => setState(() => _previewTime = value),
        ),
      ],
    );
  }
}
