import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../../util/dialogs.dart';
import '../../../util/theme_utils.dart';
import '../../controls/card/expandable.dart';
import '../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import 'pixel_view_preview.dart';

class SeriesEditDisplaySettings extends StatelessWidget {
  static final List<SeriesType> _allowedSeriesTypes = [SeriesType.bloodPressure, SeriesType.dailyCheck, SeriesType.habit];

  static bool applicableOn(SeriesDef seriesDef) {
    return _allowedSeriesTypes.contains(seriesDef.seriesType);
  }

  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const SeriesEditDisplaySettings(this.seriesDef, this.updateStateCB, {super.key});

  @override
  Widget build(BuildContext context) {
    var settings = seriesDef.displaySettingsEditable(updateStateCB);
    var seriesType = seriesDef.seriesType;

    return Expandable(
      icon: const Icon(Icons.settings_outlined),
      title: LocaleKeys.seriesEdit_common_displaySettings_title.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: ThemeUtils.verticalSpacing,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Table use Date|Time|Value Column profile
          if (seriesType == SeriesType.dailyCheck || seriesType == SeriesType.habit || seriesType == SeriesType.bloodPressure)
            SwitchListTile(
              title: Text(
                LocaleKeys.seriesEdit_displaySettings_tableView_switch_useColumnProfileDateTimeValue_label.tr(),
              ),
              value: settings.tableViewUseColumnProfileDateTimeValue,
              onChanged: (value) => settings.tableViewUseColumnProfileDateTimeValue = value,
              secondary: const Icon(Icons.view_column_outlined),
            ),
          // Dots show count
          if (seriesType == SeriesType.dailyCheck || seriesType == SeriesType.bloodPressure)
            SwitchListTile(
              title: Text(
                LocaleKeys.seriesEdit_displaySettings_dotsView_switch_dotsViewShowCount_label.tr(),
              ),
              value: settings.dotsViewShowCount,
              onChanged: (value) => settings.dotsViewShowCount = value,
              secondary: const Icon(Icons.numbers_outlined),
            ),
          // Pixel Preview
          if (PixelViewPreview.applicableOn(seriesDef)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.cardPadding),
              child: Wrap(
                spacing: ThemeUtils.horizontalSpacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(LocaleKeys.seriesEdit_displaySettings_pixelsView_preview_title.tr()),
                  IconButton(
                      tooltip: LocaleKeys.seriesEdit_displaySettings_pixelsView_preview_pixelViewSettingsInfo_tooltip.tr(),
                      onPressed: () => Dialogs.simpleOkDialog(
                            SingleChildScrollViewWithScrollbar(
                              child: Text(LocaleKeys.seriesEdit_displaySettings_pixelsView_preview_pixelViewSettingsInfo_text.tr()),
                            ),
                            context,
                            title: Text(LocaleKeys.seriesEdit_displaySettings_pixelsView_preview_pixelViewSettingsInfo_title.tr()),
                          ),
                      icon: const Icon(Icons.info_outline)),
                  PixelViewPreview(
                    color: seriesDef.color,
                    invertHueDirection: settings.pixelsViewInvertHueDirection,
                    hueFactor: settings.pixelsViewHueFactor,
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: Text(LocaleKeys.seriesEdit_displaySettings_pixelsView_switch_invertHueDirection_label.tr()),
              value: settings.pixelsViewInvertHueDirection,
              onChanged: (value) => settings.pixelsViewInvertHueDirection = value,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.cardPadding),
              child: Wrap(
                spacing: ThemeUtils.horizontalSpacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(LocaleKeys.seriesEdit_displaySettings_pixelsView_slider_hueFactor_label.tr()),
                  Slider(
                    min: 0,
                    max: 360,
                    divisions: 36,
                    label: "${settings.pixelsViewHueFactor.toInt()}",
                    value: settings.pixelsViewHueFactor,
                    onChanged: (value) => settings.pixelsViewHueFactor = value,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
