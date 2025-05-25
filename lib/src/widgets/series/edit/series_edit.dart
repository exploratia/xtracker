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
  late SeriesDef? _seriesDef;
  late final bool _isNew;

  @override
  void initState() {
    _seriesDef = widget.seriesDef?.clone();
    _isNew = _seriesDef == null;
    super.initState();
  }

  void _resetSeriesDef() {
    _seriesDef = null;
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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    if (_seriesDef == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: themeData.colorScheme.secondary,
          title: Text(LocaleKeys.series_edit_title.tr()),
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_outlined)),
        ),
        body: _SeriesTypeSelector(createSeriesDef: _createSeriesDef),
      );
    }
    return _SeriesEditor(
      seriesDef: _seriesDef!,
      goBack: _isNew ? _resetSeriesDef : null,
    );
  }
}

class _SeriesTypeSelector extends StatelessWidget {
  const _SeriesTypeSelector({required this.createSeriesDef});

  final Function(SeriesType seriesType) createSeriesDef;

  @override
  Widget build(BuildContext context) {
    return VCenteredSingleChildScrollViewWithScrollbar(
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
                      onPressed: () => createSeriesDef(st),
                    )
                  ])),
            ],
          )
        ],
      ),
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
  const _SeriesEditor({required this.seriesDef, required this.goBack});

  final SeriesDef seriesDef;
  final Function()? goBack;

  @override
  State<_SeriesEditor> createState() => _SeriesEditorState();
}

class _SeriesEditorState extends State<_SeriesEditor> {
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: themeData.colorScheme.secondary,
          title: Text(LocaleKeys.series_edit_title.tr()),
        ),
        body: const LinearProgressIndicator(),
      );
    }

    var formWrapper = ScrollableCenteredFormWrapper(
      formKey: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      children: [
        // is new - then go back is allowed
        if (widget.goBack != null)
          Row(
            children: [IconButton(onPressed: widget.goBack, icon: const Icon(Icons.arrow_back_outlined))],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconMap.icon(_seriesDef.iconName),
            const SizedBox(width: 10),
            Text(
              SeriesType.displayNameOf(_seriesDef.seriesType),
              style: themeData.textTheme.headlineSmall,
            ),
          ],
        ),
        const Divider(),
        TextFormField(
          autofocus: true,
          controller: _nameController,
          decoration: InputDecoration(
            labelText: LocaleKeys.series_edit_labels_seriesName.tr(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          spacing: 20,
          children: [
            Row(
              spacing: 10,
              children: [
                Text(LocaleKeys.series_edit_labels_seriesIcon.tr()),
                IconPicker(
                  icoName: _seriesDef.iconName,
                  icoSelected: (icoName) => _seriesDef.iconName = icoName,
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                Text(LocaleKeys.series_edit_labels_seriesColor.tr()),
                ColorPicker(
                  color: _seriesDef.color,
                  colorSelected: (color) => _seriesDef.color = color,
                ),
              ],
            ),
          ],
        ),
        switch (_seriesDef.seriesType) {
          SeriesType.bloodPressure => BloodPressureSeriesEdit(_seriesDef, _updateState),
          SeriesType.dailyCheck => Container(),
          // TODO: Handle this case.
          SeriesType.monthly => throw UnimplementedError(),
          // TODO: Handle this case.
          SeriesType.free => throw UnimplementedError(),
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
