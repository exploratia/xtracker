import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/series_type.dart';
import '../../../../../util/date_time_utils.dart';
import '../../view/blood_pressure/table/blood_pressure_value_renderer.dart';

class BloodPressureQuickInput extends StatefulWidget {
  const BloodPressureQuickInput({super.key, this.bloodPressureValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final BloodPressureValue? bloodPressureValue;

  static Future<BloodPressureValue?> showInputDlg(BuildContext context, SeriesDef seriesDef, {BloodPressureValue? bloodPressureValue}) async {
    final t = AppLocalizations.of(context)!;

    return await showDialog<BloodPressureValue>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (bloodPressureValue != null) const Icon(Icons.edit_outlined),
            if (bloodPressureValue == null) const Icon(Icons.add_circle_outline),
            const SizedBox(width: 10),
            Text(SeriesType.displayNameOf(seriesDef.seriesType, t)),
          ],
        ),
        content: BloodPressureQuickInput(bloodPressureValue: bloodPressureValue, seriesDef: seriesDef),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, null);
            },
            child: Text(t.commonsDialogBtnCancel),
          ),
        ],
      ),
    );
  }

  @override
  State<BloodPressureQuickInput> createState() => _BloodPressureQuickInputState();
}

class _BloodPressureQuickInputState extends State<BloodPressureQuickInput> {
  late DateTime dateTime;

  int _high = 120;
  int _highRough = 120;
  int _low = 80;
  int _lowRough = 80;
  _DialogStep _dialogStep = _DialogStep.highRough;

  @override
  initState() {
    dateTime = widget.bloodPressureValue?.dateTime ?? DateTime.now();
    super.initState();
  }

  _setStep(_DialogStep step) {
    setState(() {
      _dialogStep = step;
    });
  }

  _setHigh(int value) {
    setState(() {
      _high = _highRough + value;
      _dialogStep = _DialogStep.lowRough;
    });
  }

  _setHighRough(int value) {
    setState(() {
      _highRough = value * 10;
      _dialogStep = _DialogStep.highFine;
    });
  }

  _setLow(int value) {
    setState(() {
      _low = _lowRough + value;
      BloodPressureValue val;
      if (widget.bloodPressureValue != null) {
        val = widget.bloodPressureValue!.cloneWith(_high, _low);
      } else {
        val = BloodPressureValue(const Uuid().v4(), dateTime, _high, _low);
      }
      Navigator.pop(context, val);
    });
  }

  _setLowRough(int value) {
    setState(() {
      _lowRough = value * 10;
      _dialogStep = _DialogStep.lowFine;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_dialogStep == _DialogStep.highRough) {
      return IntrinsicHeight(
        child: Column(
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DateTimeHeader(dateTime: dateTime),
                if (widget.bloodPressureValue != null) BloodPressureValueRenderer(bloodPressureValue: widget.bloodPressureValue!, seriesDef: widget.seriesDef),
              ],
            ),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => Navigator.pop(context, null), icon: const Icon(Icons.arrow_back_outlined)),
                Text(_DialogStep.displayNameOf(_dialogStep, t)),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 3),
            _ValBtnRow(values: [14, 15, 16], setValue: _setHighRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [11, 12, 13], setValue: _setHighRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [8, 9, 10], setValue: _setHighRough, dialogStep: _dialogStep),
            const SizedBox(height: 40),
          ],
        ),
      );
    } else if (_dialogStep == _DialogStep.highFine) {
      return IntrinsicHeight(
        child: Column(
          spacing: 10,
          children: [
            _DateTimeHeader(dateTime: dateTime),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => _setStep(_DialogStep.highRough), icon: const Icon(Icons.arrow_back_outlined)),
                Text(_DialogStep.displayNameOf(_dialogStep, t)),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 3),
            _ValBtnRow(values: [7, 8, 9], setValue: _setHigh, roughVal: _highRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [4, 5, 6], setValue: _setHigh, roughVal: _highRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [1, 2, 3], setValue: _setHigh, roughVal: _highRough, dialogStep: _dialogStep),
            _ValBtn(setValue: _setHigh, val: 0, roughVal: _highRough, dialogStep: _dialogStep)
          ],
        ),
      );
    } else if (_dialogStep == _DialogStep.lowRough) {
      return IntrinsicHeight(
        child: Column(
          spacing: 10,
          children: [
            _DateTimeHeader(dateTime: dateTime),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => _setStep(_DialogStep.highFine), icon: const Icon(Icons.arrow_back_outlined)),
                Text(_DialogStep.displayNameOf(_dialogStep, t)),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 3),
            _ValBtnRow(values: [10, 11, 12], setValue: _setLowRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [7, 8, 9], setValue: _setLowRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [4, 5, 6], setValue: _setLowRough, dialogStep: _dialogStep),
            const SizedBox(height: 40),
          ],
        ),
      );
    } else if (_dialogStep == _DialogStep.lowFine) {
      return IntrinsicHeight(
        child: Column(
          spacing: 10,
          children: [
            _DateTimeHeader(dateTime: dateTime),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => _setStep(_DialogStep.lowRough), icon: const Icon(Icons.arrow_back_outlined)),
                Text(_DialogStep.displayNameOf(_dialogStep, t)),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 3),
            _ValBtnRow(values: [7, 8, 9], setValue: _setLow, roughVal: _lowRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [4, 5, 6], setValue: _setLow, roughVal: _lowRough, dialogStep: _dialogStep),
            _ValBtnRow(values: [1, 2, 3], setValue: _setLow, roughVal: _lowRough, dialogStep: _dialogStep),
            _ValBtn(setValue: _setLow, val: 0, roughVal: _lowRough, dialogStep: _dialogStep)
          ],
        ),
      );
    }

    return const Placeholder();
  }
}

class _DateTimeHeader extends StatelessWidget {
  const _DateTimeHeader({
    required this.dateTime,
  });

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        Text(DateTimeUtils.formateDate(dateTime)),
        Text(DateTimeUtils.formateTime(dateTime)),
      ],
    );
  }
}

class _ValBtnRow extends StatelessWidget {
  const _ValBtnRow({
    required this.values,
    this.roughVal,
    required this.setValue,
    required _DialogStep dialogStep,
  }) : _dialogStep = dialogStep;

  final List<int> values;
  final int? roughVal;
  final Function(int val) setValue;
  final _DialogStep _dialogStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ...values.map(
          (e) => _ValBtn(setValue: setValue, val: e, roughVal: roughVal, dialogStep: _dialogStep),
        )
      ],
    );
  }
}

class _ValBtn extends StatelessWidget {
  const _ValBtn({
    required this.setValue,
    required this.val,
    required this.roughVal,
    required this.dialogStep,
  });

  final int? roughVal;
  final int val;
  final _DialogStep dialogStep;
  final Function(int p1) setValue;

  @override
  Widget build(BuildContext context) {
    String text;
    if (roughVal == null) {
      text = '${val}x';
    } else {
      text = '${roughVal! + val}';
    }

    Color btnColor = switch (dialogStep) {
      _DialogStep.highRough => BloodPressureValue.colorHigh(val * 10),
      _DialogStep.highFine => BloodPressureValue.colorHigh(roughVal! + val),
      _DialogStep.lowRough => BloodPressureValue.colorLow(val * 10),
      _DialogStep.lowFine => BloodPressureValue.colorLow(roughVal! + val),
    };
    final themeData = Theme.of(context);
    return SizedBox(
      width: 60,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(side: BorderSide(color: btnColor, width: 3)),
        onPressed: () => setValue(val),
        child: Text(text, style: TextStyle(color: themeData.textTheme.bodyMedium?.color)),
      ),
    );
  }
}

enum _DialogStep {
  highRough(),
  highFine(),
  lowRough(),
  lowFine();

  const _DialogStep();

  static String displayNameOf(_DialogStep seriesType, AppLocalizations t) {
    return switch (seriesType) {
      _DialogStep.highRough => t.bloodPressureInputSystolicRoughTitle,
      _DialogStep.highFine => t.bloodPressureInputSystolicFineTitle,
      _DialogStep.lowRough => t.bloodPressureInputDiastolicRoughTitle,
      _DialogStep.lowFine => t.bloodPressureInputDiastolicFineTitle,
    };
  }
}
