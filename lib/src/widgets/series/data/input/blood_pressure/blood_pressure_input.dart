import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/text/overflow_text.dart';
import '../fullscreen_input.dart';
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
  final _lowFocusNode = FocusNode();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;
  bool _didAutoFocusLow = false;

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
    _lowFocusNode.dispose();
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

  void _handleHighChanged(String value) {
    _setHigh(int.tryParse(value) ?? -1);
    if (!_didAutoFocusLow && value.length >= 3) {
      _didAutoFocusLow = true;
      _lowFocusNode.requestFocus();
    }
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

  void _saveHandler() async {
    bool insert = widget.bloodPressureValue == null;
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;
    var val = BloodPressureValue(_uuid, _dateTime, int.parse(_highController.text), int.parse(_lowController.text), _tablet);
    // First dismiss keyboard to trigger series view rebuild (-> series view animation)
    // and after a small delay pop the dialog with the return value - which then triggers the current value animation
    Dialogs.dismissKeyboard(context);
    await Future.delayed(const Duration(milliseconds: 300), () {});
    if (mounted) {
      Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
    }
  }

  void _deleteHandler() {
    if (widget.bloodPressureValue != null && mounted) {
      Navigator.pop(context, InputResult(widget.bloodPressureValue!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMedicationInput = !widget.seriesDef.bloodPressureSettingsReadonly().hideMedicationInput;

    List<Widget> formChildren = [
      TextFormField(
        autofocus: true,
        controller: _highController,
        decoration: InputDecoration(
          labelText: LocaleKeys.seriesValue_bloodPressure_label_systolic.tr(),
          // hintText: "hint text",
          suffixIcon: const Icon(Icons.circle_outlined),
          suffixIconColor: BloodPressureValue.colorHigh(_high),
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
        onChanged: _handleHighChanged,
      ),
      TextFormField(
        focusNode: _lowFocusNode,
        controller: _lowController,
        decoration: InputDecoration(
          labelText: LocaleKeys.seriesValue_bloodPressure_label_diastolic.tr(),
          // hintText: "hint text",
          suffixIcon: const Icon(Icons.circle_outlined),
          suffixIconColor: BloodPressureValue.colorLow(_low),
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
    ];

    return FullscreenInput(
      formKey: _formKey,
      formChildren: formChildren,
      autoValidate: _autoValidate,
      isEdit: widget.bloodPressureValue != null,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
    );
  }
}
