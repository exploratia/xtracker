import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../model/column_profile/column_profile.dart';
import '../../../../model/series/seriesItem/series_item.dart';
import '../../../../util/theme_utils.dart';
import '../../../../util/motion_utils.dart';
import '../../../controls/card/glowing_border_container.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/text/overflow_text.dart';
import '../../../controls/tooltip/lazy_tooltip.dart';

class SeriesItemsTableSettings extends StatefulWidget {
  const SeriesItemsTableSettings({
    super.key,
    required this.seriesItems,
  });

  final List<SeriesItem> seriesItems;

  static Future<List<SeriesItem>?> showInputDlg(BuildContext context, {required List<SeriesItem> seriesItems}) async {
    return await showDialog<List<SeriesItem>?>(
      context: context,
      builder: (_) => SeriesItemsTableSettings(
        seriesItems: seriesItems,
      ),
    );
  }

  @override
  State<SeriesItemsTableSettings> createState() => _SeriesItemsTableSettingsState();
}

class _SeriesItemsTableSettingsState extends State<SeriesItemsTableSettings> {
  final _formKey = GlobalKey<FormState>();
  final List<_SeriesItemData> _seriesItemsData = [];

  bool _isValid = true;

  @override
  initState() {
    for (var seriesItem in widget.seriesItems) {
      var seriesItemData = _SeriesItemData(seriesItem);
      seriesItemData.textEditingController.addListener(_validate);
      _seriesItemsData.add(seriesItemData);
    }

    super.initState();
  }

  @override
  void dispose() {
    for (var e in _seriesItemsData) {
      e.dispose();
    }
    super.dispose();
  }

  void _validate() {
    bool valid = _formKey.currentState?.validate() ?? false;
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  int? _determineTableColumnWidth(TextEditingController textController) {
    var value = textController.text;
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  void _saveHandler() {
    _validate();
    if (!_isValid) return;
    var result = _seriesItemsData.map((e) => e.seriesItem.withTableSettings(e.hide, _determineTableColumnWidth(e.textEditingController))).toList();
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
                    tooltipBuilder: (BuildContext p1) => Text(
                      e.hide
                          ? LocaleKeys.seriesEdit_seriesSettings_seriesItems_tableSettingsDlg_tooltip_showColumn.tr()
                          : LocaleKeys.seriesEdit_seriesSettings_seriesItems_tableSettingsDlg_tooltip_hideColumn.tr(),
                    ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.horizontalSpacingLarge),
                    child: TextFormField(
                      controller: e.textEditingController,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.seriesEdit_seriesSettings_seriesItems_tableSettingsDlg_label_columnWidth.tr(),
                        hintText: ColumnProfile.defaultColumnWidth.toString(),
                      ),
                      // Only numbers can be entered:
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // no value is allowed
                          // return LocaleKeys.commons_validator_emptyValue.tr();
                        }
                        var iVal = int.tryParse(value);
                        if (iVal == null) {
                          return LocaleKeys.commons_validator_emptyValue.tr();
                        }

                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeUtils.horizontalSpacingLarge,
                      vertical: ThemeUtils.verticalSpacingSmall,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AnimatedContainer(
                        duration: MotionUtils.resolve(context, MotionUtils.complex),
                        color: e.seriesItem.color,
                        height: 2,
                        width: min(244, double.tryParse(e.textEditingController.text) ?? ColumnProfile.defaultColumnWidth.toDouble()),
                      ),
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
            Icon(Icons.view_column_outlined, size: iconSize),
            OverflowText(LocaleKeys.seriesEdit_seriesSettings_seriesItems_tableSettingsDlg_title.tr()),
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
  late final TextEditingController textEditingController;
  late bool hide;

  _SeriesItemData(this.seriesItem) {
    textEditingController = TextEditingController();
    textEditingController.text = "${seriesItem.tableColumnWidth ?? ''}";
    hide = seriesItem.hideInTable;
  }

  void dispose() {
    textEditingController.dispose();
  }
}
