import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/v4.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../../providers/series_provider.dart';
import '../../../util/dialogs.dart';
import '../../layout/scrollable_centered_form_wrapper.dart';
import '../../layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import '../../select/color_picker.dart';
import '../../select/icon_map.dart';
import '../../select/icon_picker.dart';
import 'blood_pressure/blood_pressure_series_edit.dart';

class SeriesEdit extends StatefulWidget {
  const SeriesEdit({super.key, required this.seriesDef});

  final SeriesDef? seriesDef;

  @override
  State<SeriesEdit> createState() => _SeriesEditState();
}

class _SeriesEditState extends State<SeriesEdit> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  late SeriesDef? _seriesDef;
  late final bool _isNew;

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  @override
  void initState() {
    _seriesDef = widget.seriesDef?.clone();
    _isNew = _seriesDef == null;
    if (!_isNew) {
      _isValid = true;
      _autoValidate = true;
    }
    super.initState();
  }

  void _resetSeriesDef() {
    _seriesDef = null;
    setState(() {});
  }

  void _updateState() {
    setState(() {});
  }

  void _createSeriesDef(SeriesType seriesType) {
    _seriesDef = SeriesDef(
      uuid: const UuidV4().generate().toString(),
      seriesType: seriesType,
      seriesItems: [],
    );
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
    if (_seriesDef == null) return;
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;

    setState(() => _isLoading = true);

    try {
      var seriesProvider = context.read<SeriesProvider>();
      await seriesProvider.save(_seriesDef!);
      if (mounted) Dialogs.showSnackBar(LocaleKeys.commons_msg_saved.tr(), context);
    } catch (err) {
      if (mounted) {
        await Dialogs.simpleErrOkDialog(err.toString(), context);
      }
    }

    setState(() => _isLoading = false);

    if (mounted) Navigator.of(context).pop(_seriesDef);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget body;

    if (_isLoading) {
      body = const LinearProgressIndicator();
    } else if (_seriesDef == null) {
      body = VCenteredSingleChildScrollViewWithScrollbar(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(LocaleKeys.series_edit_labels_selectSeriesType.tr()),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...SeriesType.values.map((st) => Row(mainAxisSize: MainAxisSize.min, children: [
                    _SeriesTypeInfoBtn(st),
                    ElevatedButton.icon(
                      icon: IconMap.icon(st.iconName),
                      label: Text(SeriesType.displayNameOf(st)),
                      onPressed: () => _createSeriesDef(st),
                    )
                  ])),
            ],
          )
        ],
      ));
    } else {
      body = _SeriesEditor(
        formKey: _formKey,
        autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        seriesDef: _seriesDef!,
        goBack: _isNew ? _resetSeriesDef : null,
        updateState: _updateState,
        validate: _validate,
      );
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: themeData.colorScheme.secondary,
          title: Text(LocaleKeys.series_edit_title.tr()),
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_outlined)),
          actions: [
            if (_seriesDef != null) IconButton(onPressed: _saveHandler, icon: const Icon(Icons.save_outlined)),
          ]),
      body: body,
    );
  }
}

class _SeriesTypeInfoBtn extends StatelessWidget {
  const _SeriesTypeInfoBtn(this.st);

  final SeriesType st;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => Dialogs.simpleOkDialog(
              SeriesType.infoOf(st),
              context,
              title: Row(spacing: 10, children: [IconMap.icon(st.iconName), Text(SeriesType.displayNameOf(st))]),
            ),
        icon: const Icon(Icons.info_outline));
  }
}

class _SeriesEditor extends StatefulWidget {
  const _SeriesEditor(
      {required this.formKey,
      required this.seriesDef,
      required this.goBack,
      required this.updateState,
      required this.autovalidateMode,
      required this.validate});

  final GlobalKey<FormState> formKey;
  final SeriesDef seriesDef;
  final Function()? goBack;
  final Function() updateState;
  final Function() validate;
  final AutovalidateMode autovalidateMode;

  @override
  State<_SeriesEditor> createState() => _SeriesEditorState();
}

class _SeriesEditorState extends State<_SeriesEditor> {
  final _nameController = TextEditingController();

  @override
  initState() {
    _nameController.addListener(widget.validate);
    _nameController.text = widget.seriesDef.name.toString();

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ScrollableCenteredFormWrapper(
      formKey: widget.formKey,
      autovalidateMode: widget.autovalidateMode,
      children: [
        // is new - then go back is allowed
        if (widget.goBack != null)
          Row(
            children: [IconButton(onPressed: widget.goBack, icon: const Icon(Icons.arrow_back_outlined))],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconMap.icon(widget.seriesDef.iconName),
            const SizedBox(width: 10),
            Text(
              SeriesType.displayNameOf(widget.seriesDef.seriesType),
              style: themeData.textTheme.headlineSmall,
            ),
          ],
        ),
        const Divider(),
        TextFormField(
          autofocus: true,
          controller: _nameController,
          decoration: InputDecoration(labelText: LocaleKeys.series_edit_labels_seriesName.tr()),
          textInputAction: TextInputAction.next,
          // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.commons_validator_msg_emptyValue.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          spacing: 20,
          children: [
            Row(
              spacing: 10,
              children: [
                Text(LocaleKeys.series_edit_labels_seriesIcon.tr()),
                IconPicker(
                  icoName: widget.seriesDef.iconName,
                  icoSelected: (icoName) => widget.seriesDef.iconName = icoName,
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                Text(LocaleKeys.series_edit_labels_seriesColor.tr()),
                ColorPicker(
                  color: widget.seriesDef.color,
                  colorSelected: (color) => widget.seriesDef.color = color,
                ),
              ],
            ),
          ],
        ),
        switch (widget.seriesDef.seriesType) {
          SeriesType.bloodPressure => BloodPressureSeriesEdit(widget.seriesDef, widget.updateState),
          SeriesType.dailyCheck => Container(),
          // TODO: Handle this case.
          SeriesType.monthly => throw UnimplementedError(),
          // TODO: Handle this case.
          SeriesType.free => throw UnimplementedError(),
        }
      ],
    );
  }
}
