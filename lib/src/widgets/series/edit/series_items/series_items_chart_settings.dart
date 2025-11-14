import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/seriesItem/series_item.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/card/glowing_border_container.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/text/overflow_text.dart';
import '../../../controls/tooltip/lazy_tooltip.dart';

class SeriesItemsChartSettings extends StatefulWidget {
  const SeriesItemsChartSettings({
    super.key,
    required this.seriesItems,
  });

  final List<SeriesItem> seriesItems;

  static Future<List<SeriesItem>?> showInputDlg(BuildContext context, {required List<SeriesItem> seriesItems}) async {
    return await showDialog<List<SeriesItem>?>(
      context: context,
      builder: (_) => SeriesItemsChartSettings(
        seriesItems: seriesItems,
      ),
    );
  }

  @override
  State<SeriesItemsChartSettings> createState() => _SeriesItemsChartSettingsState();
}

class _SeriesItemsChartSettingsState extends State<SeriesItemsChartSettings> {
  final _formKey = GlobalKey<FormState>();
  final List<_SeriesItemData> _seriesItemsData = [];

  bool _isValid = true;

  @override
  initState() {
    for (var seriesItem in widget.seriesItems) {
      var seriesItemData = _SeriesItemData(seriesItem);
      _seriesItemsData.add(seriesItemData);
    }

    super.initState();
  }

  void _validate() {
    bool valid = _formKey.currentState?.validate() ?? false;
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  void _saveHandler() {
    _validate();
    if (!_isValid) return;
    var result = _seriesItemsData.map((e) => e.seriesItem.withHideInChart(e.hide)).toList();
    Navigator.pop<List<SeriesItem>>(context, result);
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = ThemeUtils.iconSizeScaled;
    final themeData = Theme.of(context);

    var edit = Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ThemeUtils.verticalSpacingSmall,
        children: [
          ..._seriesItemsData.map(
            (e) => GlowingBorderContainer(
              glowColor: e.seriesItem.color,
              backgroundColor: themeData.dialogTheme.backgroundColor,
              child: Column(
                spacing: 0,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LazyTooltip(
                    tooltipBuilder: (BuildContext p1) => Text(e.hide
                        ? LocaleKeys.seriesEdit_seriesSettings_seriesItems_chartSettingsDlg_tooltip_showChart.tr()
                        : LocaleKeys.seriesEdit_seriesSettings_seriesItems_chartSettingsDlg_tooltip_hideChart.tr()),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: ThemeUtils.defaultPadding),
                      value: !e.hide,
                      onChanged: (bool value) {
                        setState(() {
                          e.hide = !value;
                        });
                      },
                      title: Text(e.seriesItem.name),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return AlertDialog(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: Row(
          spacing: ThemeUtils.horizontalSpacing,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.line_axis_outlined, size: iconSize),
            OverflowText(LocaleKeys.seriesEdit_seriesSettings_seriesItems_chartSettingsDlg_title.tr()),
          ],
        ),
      ),
      content: SingleChildScrollViewWithScrollbar(
        child: edit,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
        ),
        TextButton(
          onPressed: _saveHandler,
          child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
        ),
      ],
    );
  }
}

class _SeriesItemData {
  final SeriesItem seriesItem;
  late bool hide;

  _SeriesItemData(this.seriesItem) {
    hide = seriesItem.hideInChart;
  }
}
