import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../../providers/series_provider.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../controls/layout/scrollable_centered_form_wrapper.dart';
import '../../controls/select/color_picker.dart';
import '../../controls/select/icon_map.dart';
import '../../controls/select/icon_picker.dart';
import 'blood_pressure/blood_pressure_series_edit.dart';

class SeriesEditor extends StatefulWidget {
  const SeriesEditor({super.key, required this.seriesDef, required this.goBack});

  final SeriesDef seriesDef;
  final Function()? goBack;

  @override
  State<SeriesEditor> createState() => _SeriesEditorState();
}

class _SeriesEditorState extends State<SeriesEditor> {
  late SeriesDef _seriesDef;
  var _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  @override
  void initState() {
    _seriesDef = widget.seriesDef.clone();

    _nameController.addListener(_validate);
    _nameController.text = _seriesDef.name.toString();

    if (widget.goBack == null) {
      _isValid = true;
      _autoValidate = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _updateState() {
    setState(() {});
  }

  void _validate() {
    if (!_autoValidate) return;
    bool valid = _formKey.currentState?.validate() ?? false;
    if (valid) _formKey.currentState?.save();
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  Future<void> _saveHandler() async {
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;

    _setLoading(true);

    try {
      var seriesProvider = context.read<SeriesProvider>();
      await seriesProvider.save(_seriesDef);
      if (mounted) Dialogs.showSnackBar(LocaleKeys.commons_msg_saved.tr(), context);
    } catch (err) {
      SimpleLogging.w('Failed to store series.', error: err);
      if (mounted) {
        await Dialogs.simpleErrOkDialog(err.toString(), context);
      }
    }

    _setLoading(false);

    if (mounted) Navigator.of(context).pop(_seriesDef);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    if (_isLoading) return const _Loading();

    var formWrapper = ScrollableCenteredFormWrapper(
      formKey: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      children: [
        // is new - then go back is allowed
        if (widget.goBack != null) Row(children: [IconButton(onPressed: widget.goBack, icon: const Icon(Icons.arrow_back_outlined))]),
        _SeriesTypeHeadline(seriesDef: _seriesDef),
        const Divider(),
        // series name:
        TextFormField(
          autofocus: true,
          controller: _nameController,
          decoration: InputDecoration(
            labelText: LocaleKeys.series_edit_common_labels_seriesName.tr(),
            hintText: SeriesType.displayNameOf(_seriesDef.seriesType),
          ),
          textInputAction: TextInputAction.next,
          // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.commons_validator_msg_emptyValue.tr();
            }
            return null;
          },
          onChanged: (value) {
            _seriesDef.name = value;
          },
        ),
        const SizedBox(height: 10),
        _SeriesSymbolAndColor(seriesDef: _seriesDef),
        switch (_seriesDef.seriesType) {
          SeriesType.bloodPressure => BloodPressureSeriesEdit(_seriesDef, _updateState),
          SeriesType.dailyCheck => Container(),
        }
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.secondary,
        title: Text(LocaleKeys.series_edit_title.tr()),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_outlined)),
        actions: [
          IconButton(onPressed: _saveHandler, icon: const Icon(Icons.save_outlined)),
        ],
      ),
      body: formWrapper,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.secondary,
        title: Text(LocaleKeys.series_edit_title.tr()),
      ),
      body: const LinearProgressIndicator(),
    );
  }
}

class _SeriesTypeHeadline extends StatelessWidget {
  const _SeriesTypeHeadline({required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconMap.icon(seriesDef.iconName),
        const SizedBox(width: 10),
        Text(
          SeriesType.displayNameOf(seriesDef.seriesType),
          style: themeData.textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _SeriesSymbolAndColor extends StatelessWidget {
  const _SeriesSymbolAndColor({required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      spacing: 20,
      children: [
        Row(
          spacing: 10,
          children: [
            Text(LocaleKeys.series_edit_common_labels_seriesIcon.tr()),
            IconPicker(
              icoName: seriesDef.iconName,
              icoSelected: (icoName) => seriesDef.iconName = icoName,
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Text(LocaleKeys.series_edit_common_labels_seriesColor.tr()),
            ColorPicker(
              color: seriesDef.color,
              colorSelected: (color) => seriesDef.color = color,
            ),
          ],
        ),
      ],
    );
  }
}
