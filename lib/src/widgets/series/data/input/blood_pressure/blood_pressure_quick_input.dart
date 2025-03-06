import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/series_type.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/dialogs.dart';
import '../../../../layout/single_child_scroll_view_with_scrollbar.dart';
import '../../view/blood_pressure/table/blood_pressure_value_renderer.dart';

class BloodPressureQuickInput extends StatefulWidget {
  const BloodPressureQuickInput({super.key, this.bloodPressureValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final BloodPressureValue? bloodPressureValue;

  static Future<BloodPressureValue?> showInputDlg(BuildContext context, SeriesDef seriesDef, {BloodPressureValue? bloodPressureValue}) async {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);

    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        t.seriesDataInputDialogMsgQueryDeleteValue,
        context,
        title: t.commonsDialogTitleAreYouSure,
      );
      if (res == true) {
        try {
          if (context.mounted) {
            await context.read<SeriesDataProvider>().deleteValue(seriesDef, bloodPressureValue);
            if (context.mounted) Navigator.pop(context, null);
          }
        } catch (err) {
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('$err', context);
          }
        }
      }
    }

    return await showDialog<BloodPressureValue>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                if (bloodPressureValue != null) const Icon(Icons.edit_outlined),
                if (bloodPressureValue == null) const Icon(Icons.add_circle_outline),
                const SizedBox(width: 10),
                Text(SeriesType.displayNameOf(seriesDef.seriesType, t)),
              ],
            ),
            if (bloodPressureValue != null) IconButton(onPressed: deleteHandler, color: themeData.colorScheme.primary, icon: const Icon(Icons.delete_outlined)),
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
  late DateTime _dateTime;

  int _high = 120;
  int _highRough = 120;
  int _low = 80;
  int _lowRough = 80;
  _DialogStep _dialogStep = _DialogStep.highRough;

  @override
  initState() {
    _dateTime = widget.bloodPressureValue?.dateTime ?? DateTime.now();
    super.initState();
  }

  _setStep(_DialogStep step) {
    setState(() {
      _dialogStep = step;
    });
  }

  _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  _setHighRough(int value) {
    setState(() {
      _highRough = value * 10;
      _dialogStep = _DialogStep.highFine;
    });
  }

  _setHigh(int value) {
    setState(() {
      _high = _highRough + value;
      _dialogStep = _DialogStep.lowRough;
    });
  }

  _setLowRough(int value) {
    setState(() {
      _lowRough = value * 10;
      _dialogStep = _DialogStep.lowFine;
    });
  }

  _setLow(int value) {
    setState(() {
      _low = _lowRough + value;
      BloodPressureValue val;
      if (widget.bloodPressureValue != null) {
        val = widget.bloodPressureValue!.cloneWith(_dateTime, _high, _low);
      } else {
        val = BloodPressureValue(const Uuid().v4(), _dateTime, _high, _low);
      }
      Navigator.pop(context, val);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    Widget stepWidget;

    var header = _Header(dateTime: _dateTime, bloodPressureValue: widget.bloodPressureValue, seriesDef: widget.seriesDef, setDateTime: _setDateTime);
    if (_dialogStep == _DialogStep.highRough) {
      stepWidget = Column(
        spacing: 10,
        children: [
          header,
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
      );
    } else if (_dialogStep == _DialogStep.highFine) {
      stepWidget = Column(
        spacing: 10,
        children: [
          header,
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
      );
    } else if (_dialogStep == _DialogStep.lowRough) {
      stepWidget = Column(
        spacing: 10,
        children: [
          header,
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
      );
    } else if (_dialogStep == _DialogStep.lowFine) {
      stepWidget = Column(
        spacing: 10,
        children: [
          header,
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
      );
    } else {
      stepWidget = const Placeholder();
    }

    return SingleChildScrollViewWithScrollbar(useScreenPadding: false, child: IntrinsicHeight(child: stepWidget));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.dateTime,
    required this.setDateTime,
    this.bloodPressureValue,
    required this.seriesDef,
  });

  final DateTime dateTime;
  final BloodPressureValue? bloodPressureValue;
  final SeriesDef seriesDef;
  final Function(DateTime value) setDateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _DateTimeHeader(dateTime: dateTime, setDateTime: setDateTime),
        if (bloodPressureValue != null) BloodPressureValueRenderer(bloodPressureValue: bloodPressureValue!, seriesDef: seriesDef),
      ],
    );
  }
}

class _DateTimeHeader extends StatelessWidget {
  const _DateTimeHeader({
    required this.dateTime,
    required this.setDateTime,
  });

  final DateTime dateTime;
  final Function(DateTime value) setDateTime;

  Future<void> _selectDate(context, DateTime dateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366 * 10)),
    );

    if (pickedDate != null) setDateTime(pickedDate.copyWith(hour: dateTime.hour, minute: dateTime.minute));
  }

  Future<void> _selectTime(context, DateTime dateTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );

    if (pickedTime != null) setDateTime(dateTime.copyWith(hour: pickedTime.hour, minute: pickedTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        InkWell(
          onTap: () => _selectDate(context, dateTime),
          child: Text(DateTimeUtils.formateDate(dateTime)),
        ),
        InkWell(
          onTap: () => _selectTime(context, dateTime),
          child: Text(DateTimeUtils.formateTime(dateTime)),
        ),
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
