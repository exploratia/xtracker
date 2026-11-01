import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/wallpaper_style.dart';
import '../../../util/table_utils.dart';
import '../../../util/theme_utils.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';

/// Responsive motif selection shared by live and static backgrounds.
class WallpaperStyleSelect extends StatelessWidget {
  const WallpaperStyleSelect({super.key, required this.value, required this.onChanged});

  final WallpaperStyle value;
  final ValueChanged<WallpaperStyle?>? onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      children: [
        TableUtils.tableRow([
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.45),
            child: Text(LocaleKeys.settings_general_wallpaper_label.tr(), style: ThemeUtils.settingsLabelStyle(context)),
          ),
          DropdownButton<WallpaperStyle>(
            key: const Key('settingsWallpaperSelect'),
            value: value,
            isExpanded: true,
            borderRadius: ThemeUtils.cardBorderRadius,
            onChanged: onChanged,
            items: WallpaperStyle.values
                .map(
                  (style) => DropdownMenuItem(
                    value: style,
                    child: DropDownMenuItemChild(
                      selected: value == style,
                      child: Text(switch (style) {
                        WallpaperStyle.hills => LocaleKeys.settings_general_wallpaper_hills.tr(),
                        WallpaperStyle.mountainLake => LocaleKeys.settings_general_wallpaper_mountainLake.tr(),
                        WallpaperStyle.riverValley => LocaleKeys.settings_general_wallpaper_riverValley.tr(),
                        WallpaperStyle.moonlitHorizon => LocaleKeys.settings_general_wallpaper_moonlitHorizon.tr(),
                        WallpaperStyle.customImage => LocaleKeys.settings_general_wallpaper_customImage.tr(),
                      }, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                )
                .toList(),
          ),
        ]),
      ],
    ),
  );
}
