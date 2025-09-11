import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';
import '../input_header.dart';
import '../input_result.dart';

class BloodPressureQuickInput extends StatefulWidget {
  const BloodPressureQuickInput({
    super.key,
    this.bloodPressureValue,
    required this.seriesDef,
  });

  final SeriesDef seriesDef;
  final BloodPressureValue? bloodPressureValue;

  static Future<InputResult<BloodPressureValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {BloodPressureValue? bloodPressureValue}) async {
    return await showDialog<InputResult<BloodPressureValue>>(
      context: context,
      builder: (_) => BloodPressureQuickInput(
        seriesDef: seriesDef,
        bloodPressureValue: bloodPressureValue,
      ),
    );
  }

  @override
  State<BloodPressureQuickInput> createState() => _BloodPressureQuickInputState();
}

class _BloodPressureQuickInputState extends State<BloodPressureQuickInput> {
  final _formKey = GlobalKey<FormState>();
  final _highController = TextEditingController();
  final _lowController = TextEditingController();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _uuid;
  DateTime _dateTime = DateTime.now();
  bool _tablet = false;

  // only for showing gradient:
  int _high = -1;
  int _low = -1;

  @override
  initState() {
    var source = widget.bloodPressureValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();
    _tablet = source?.medication ?? false;

    _highController.addListener(_validate);
    _lowController.addListener(_validate);
    if (source != null) {
      _isValid = true;
      _autoValidate = true;
      _highController.text = source.high.toString();
      _lowController.text = source.low.toString();
      _high = source.high;
      _low = source.low;
    }

    super.initState();
  }

  @override
  void dispose() {
    _highController.dispose();
    _lowController.dispose();
    super.dispose();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _setHigh(int value) {
    setState(() {
      _high = value;
    });
  }

  void _setLow(int value) {
    setState(() {
      _low = value;
    });
  }

  void _setTablet(bool value) {
    setState(() {
      _tablet = value;
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

  void _saveHandler() {
    bool insert = widget.bloodPressureValue == null;
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;
    var val = BloodPressureValue(_uuid, _dateTime, int.parse(_highController.text), int.parse(_lowController.text), _tablet);
    Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
  }

  void _deleteHandler(BloodPressureValue bloodPressureValue) async {
    bool? res = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesValue_query_deleteValue.tr(),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (res == true && mounted) {
      Navigator.pop(context, InputResult(bloodPressureValue, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var iconSize = ThemeUtils.iconSizeScaled;
    final showMedicationInput = !widget.seriesDef.bloodPressureSettingsReadonly().hideMedicationInput;

    var edit = Form(
      key: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          InputHeader(dateTime: _dateTime, seriesDef: widget.seriesDef, setDateTime: _setDateTime),
          const Divider(height: 1),
          Row(
            spacing: ThemeUtils.horizontalSpacing,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: _highController,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.seriesValue_bloodPressure_label_systolic.tr(),
                        // hintText: "hint text",
                      ),
                      // Only numbers can be entered:
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                      textInputAction: TextInputAction.next,
                      // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleKeys.commons_validator_emptyValue.tr();
                        }
                        var val = int.tryParse(value);
                        if (val == null || val < BloodPressureValue.minValue || val > BloodPressureValue.maxValue) {
                          return LocaleKeys.seriesValue_bloodPressure_validation_invalidNumber.tr();
                        }
                        if (val < _low) {
                          return LocaleKeys.seriesValue_bloodPressure_validation_systolicTooLow.tr();
                        }
                        return null;
                      },
                      // onSaved: (value) => _setHigh(int.tryParse(value ?? "-1") ?? -1),
                      onChanged: (value) => _setHigh(int.tryParse(value) ?? -1),
                    ),
                    TextFormField(
                      controller: _lowController,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.seriesValue_bloodPressure_label_diastolic.tr(),
                        // hintText: "hint text",
                      ),
                      // Only numbers can be entered:
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                      textInputAction: TextInputAction.done,
                      // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleKeys.commons_validator_emptyValue.tr();
                        }
                        var val = int.tryParse(value);
                        if (val == null || val < BloodPressureValue.minValue || val > BloodPressureValue.maxValue) {
                          return LocaleKeys.seriesValue_bloodPressure_validation_invalidNumber.tr();
                        }
                        if (val > _high) {
                          return LocaleKeys.seriesValue_bloodPressure_validation_diastolicTooHigh.tr();
                        }
                        return null;
                      },
                      onChanged: (value) => _setLow(int.tryParse(value) ?? -1),
                    ),
                  ],
                ),
              ),
              Container(
                height: 96,
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const AlignmentDirectional(0, -1),
                    end: const AlignmentDirectional(0, 1),
                    colors: [
                      BloodPressureValue.colorHigh(_high),
                      BloodPressureValue.colorLow(_low),
                    ],
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ],
          ),
          if (showMedicationInput)
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: ThemeUtils.defaultPadding),
              title: Tooltip(
                message: LocaleKeys.seriesValue_bloodPressure_switch_medication_tooltip.tr(),
                child: Row(
                  spacing: ThemeUtils.horizontalSpacingSmall,
                  children: [
                    const Icon(Icons.medication_outlined),
                    OverflowText(
                      LocaleKeys.seriesValue_bloodPressure_switch_medication_label.tr(),
                    ),
                  ],
                ),
              ),
              value: _tablet,
              onChanged: _setTablet,
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
            widget.bloodPressureValue == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            OverflowText(widget.seriesDef.name),
            if (widget.bloodPressureValue != null)
              IconButton(
                tooltip: LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
                onPressed: () => _deleteHandler(widget.bloodPressureValue!),
                color: themeData.colorScheme.secondary,
                iconSize: iconSize,
                icon: const Icon(Icons.delete_outlined),
              ),
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
