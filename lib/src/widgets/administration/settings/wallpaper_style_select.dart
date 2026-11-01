import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/wallpaper_style.dart';
import '../../../util/theme_utils.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';

/// Responsive motif selection shared by live and static backgrounds.
class WallpaperStyleSelect extends StatelessWidget {
  const WallpaperStyleSelect({super.key, required this.value, required this.onChanged});

  final WallpaperStyle value;
  final ValueChanged<WallpaperStyle?>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: ThemeUtils.paddingSmall / 2, horizontal: ThemeUtils.paddingSmall),
    child: LayoutBuilder(
      builder: (context, constraints) => OverflowBar(
        alignment: MainAxisAlignment.spaceBetween,
        spacing: ThemeUtils.horizontalSpacing,
        overflowSpacing: ThemeUtils.verticalSpacingSmall,
        overflowAlignment: OverflowBarAlignment.start,
        children: [
          Text(
            LocaleKeys.settings_general_wallpaper_label.tr(),
            style: ThemeUtils.settingsLabelStyle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            width: constraints.maxWidth * 0.55,
            child: DropdownButton<WallpaperStyle>(
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
          ),
        ],
      ),
    ),
  );
}
