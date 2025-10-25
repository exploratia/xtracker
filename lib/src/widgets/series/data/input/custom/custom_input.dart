import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/formatter/decimal_input_formatter.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/appbar/gradient_app_bar.dart';
import '../../../../controls/layout/scrollable_centered_form_wrapper.dart';
import '../../../../controls/navigation/hide_bottom_navigation_bar.dart';
import '../../../../controls/responsive/device_dependent_constrained_box.dart';
import '../../../../controls/text/overflow_text.dart';
import '../input_header.dart';
import '../input_result.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({
    super.key,
    this.customValue,
    required this.seriesDef,
  });

  final SeriesDef seriesDef;
  final CustomValue? customValue;

  static Future<InputResult<CustomValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {CustomValue? customValue}) async {
    return await showDialog<InputResult<CustomValue>>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: HideBottomNavigationBar(
          child: CustomInput(
            seriesDef: seriesDef,
            customValue: customValue,
          ),
        ),
      ),
    );
  }

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, SeriesItemData> _seriesItemsData = {};

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _uuid;
  DateTime _dateTime = DateTime.now();

  @override
  initState() {
    CustomValue? source = widget.customValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();

    for (var seriesItem in widget.seriesDef.seriesItems) {
      var seriesItemData = SeriesItemData(seriesItem);
      seriesItemData.textEditingController.addListener(_validate);
      _seriesItemsData[seriesItem.siid] = seriesItemData;
    }

    if (source != null) {
      _isValid = true;
      _autoValidate = true;
      for (var valueEntry in source.values.entries) {
        var siid = valueEntry.key;
        var seriesItemData = _seriesItemsData[siid];
        if (seriesItemData != null) {
          seriesItemData.textEditingController.text = valueEntry.value.toString();
        }
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    for (var e in _seriesItemsData.values) {
      e.dispose();
    }
    super.dispose();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _validate() {
    if (!_autoValidate) return;
    bool valid = _formKey.currentState?.validate() ?? false;
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  void _saveHandler() async {
    bool insert = widget.customValue == null;
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;
    Map<String, double> values = {};
    for (var seriesItemData in _seriesItemsData.values) {
      final normalized = seriesItemData.textEditingController.text.replaceAll(',', '.');
      var val = double.tryParse(normalized);
      if (val != null) {
        values[seriesItemData.seriesItem.siid] = val;
      }
    }
    var val = CustomValue(_uuid, _dateTime, values);
    // First dismiss keyboard to trigger series view rebuild (-> series view animation)
    // and after a small delay pop the dialog with the return value - which then triggers the current value animation
    Dialogs.dismissKeyboard(context);
    await Future.delayed(const Duration(milliseconds: 300), () {});
    if (mounted) {
      Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
    }
  }

  void _deleteHandler(CustomValue customValue) async {
    bool? res = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesValue_query_deleteValue.tr(),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (res == true && mounted) {
      Navigator.pop(context, InputResult(customValue, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = ThemeUtils.iconSizeScaled;

    List<Widget> formChildren = [
      Padding(
        padding: const EdgeInsets.only(bottom: ThemeUtils.verticalSpacing),
        child: InputHeader(dateTime: _dateTime, seriesDef: widget.seriesDef, setDateTime: _setDateTime),
      ),
      const Divider(height: 1),
      ...widget.seriesDef.seriesItems.map(
        (seriesItem) {
          var seriesItemData = _seriesItemsData[seriesItem.siid]!;
          return TextFormField(
            autofocus: seriesItem.siid == widget.seriesDef.seriesItems.first.siid,
            controller: seriesItemData.textEditingController,
            decoration: InputDecoration(
              labelText: seriesItemData.title + seriesItem.unitInBrackets(emptyStringIfNullOrEmpty: true),
            ),
            // Only numbers can be entered:
            inputFormatters: <TextInputFormatter>[DecimalInputFormatter()],
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null; // no value is allowed
                // return LocaleKeys.commons_validator_emptyValue.tr();
              }
              final normalized = value.replaceAll(',', '.');
              var val = double.tryParse(normalized);
              if (val == null) {
                return LocaleKeys.commons_validator_emptyValue.tr();
              }

              return null;
            },
          );
        },
      ),
    ];

    var edit = ScrollableCenteredFormWrapper(
      formKey: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      vCentered: true,
      spacing: ThemeUtils.verticalSpacingSmall,
      useSeriesDataInputDlgWidth: true,
      children: formChildren,
    );

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Row(
          spacing: ThemeUtils.horizontalSpacing,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.customValue == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            OverflowText(widget.seriesDef.name),
            if (widget.customValue != null)
              IconButton(
                tooltip: LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
                onPressed: () => _deleteHandler(widget.customValue!),
                color: ThemeUtils.onPrimary,
                // themeData.colorScheme.secondary,
                iconSize: iconSize,
                icon: const Icon(Icons.delete_outlined),
              ),
          ],
        ),
        leading: IconButton(
          iconSize: ThemeUtils.iconSizeScaled,
          tooltip: LocaleKeys.seriesEdit_action_abort_tooltip.tr(),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_outlined),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: edit,
          ),
          SizedBox(
            height: kBottomNavigationBarHeight,
            child: DeviceDependentWidthConstrainedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: ThemeUtils.horizontalSpacing,
                children: [
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
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SeriesItemData {
  final SeriesItem seriesItem;
  late final String title;
  late final String unit;
  late final TextEditingController textEditingController;

  SeriesItemData(this.seriesItem) {
    title = seriesItem.name;
    unit = seriesItem.unit ?? '';
    textEditingController = TextEditingController();
  }

  void dispose() {
    textEditingController.dispose();
  }
}
