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

class SeriesEdit extends StatefulWidget {
  const SeriesEdit({super.key, required this.seriesDef});

  final SeriesDef? seriesDef;

  @override
  State<SeriesEdit> createState() => _SeriesEditState();
}

class _SeriesEditState extends State<SeriesEdit> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  late SeriesDef? _seriesDef;
  late final bool _isNew;

  @override
  void initState() {
    _seriesDef = widget.seriesDef;
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

  Future<void> _saveHandler() async {
    if (_seriesDef == null) return;
    var currentState = _form.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

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
        form: _form,
        seriesDef: _seriesDef!,
        goBack: _isNew ? _resetSeriesDef : null,
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

class _SeriesEditor extends StatelessWidget {
  const _SeriesEditor({required this.form, required this.seriesDef, required this.goBack});

  final GlobalKey<FormState> form;
  final SeriesDef seriesDef;
  final Function()? goBack;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ScrollableCenteredFormWrapper(
      formKey: form,
      children: [
        // is new - then go back is allowed
        if (goBack != null)
          Row(
            children: [IconButton(onPressed: goBack, icon: const Icon(Icons.arrow_back_outlined))],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconMap.icon(seriesDef.seriesType.iconName),
            const SizedBox(width: 10),
            Text(
              SeriesType.displayNameOf(seriesDef.seriesType),
              style: themeData.textTheme.headlineSmall,
            ),
          ],
        ),
        const Divider(),
        Text(seriesDef.name),
        TextFormField(
          autofocus: true,
          decoration: InputDecoration(labelText: LocaleKeys.series_edit_labels_seriesName.tr()),
          textInputAction: TextInputAction.next,
          initialValue: seriesDef.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.commons_validator_msg_emptyValue.tr();
            }
            return null;
          },
          onSaved: (value) => seriesDef.name = value!,
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
                  icoName: seriesDef.iconName,
                  icoSelected: (icoName) => seriesDef.iconName = icoName,
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                Text(LocaleKeys.series_edit_labels_seriesColor.tr()),
                ColorPicker(
                  color: seriesDef.color,
                  colorSelected: (color) => seriesDef.color = color,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
