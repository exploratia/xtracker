import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../../util/dialogs.dart';
import '../../layout/scrollable_centered_form_wrapper.dart';
import '../../layout/v_centered_single_child_scroll_view_with_scrollbar.dart';

class SeriesEdit extends StatefulWidget {
  const SeriesEdit({super.key, required this.seriesDef});

  final SeriesDef? seriesDef;

  @override
  State<SeriesEdit> createState() => _SeriesEditState();
}

class _SeriesEditState extends State<SeriesEdit> {
  final _form = GlobalKey<FormState>();
  late SeriesDef? _seriesDef;

  @override
  void initState() {
    _seriesDef = widget.seriesDef;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    Widget body;

    if (_seriesDef == null) {
      body = VCenteredSingleChildScrollViewWithScrollbar(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(t.seriesEditSelectSeriesTypeLabel),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...SeriesType.values
                  .map((st) => Row(mainAxisSize: MainAxisSize.min, children: [
                        _SeriesTypeInfoBtn(st),
                        ElevatedButton.icon(
                          icon: st.icon,
                          label: Text(SeriesType.displayNameOf(st, t)),
                          onPressed: () {
                            _seriesDef = SeriesDef(seriesType: st);
                            setState(() {});
                          },
                        )
                      ])),
            ],
          )
        ],
      ));
    } else {
      body = SeriesEditor(form: _form, seriesDef: _seriesDef!);
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: themeData.colorScheme.secondary,
          title: Text(t.seriesEditTitle),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_outlined)),
          actions: [
            if (_seriesDef != null)
              IconButton(
                  onPressed: () => Navigator.pop(context, widget.seriesDef),
                  icon: const Icon(Icons.save_outlined)),
          ]),
      body: body,
    );
  }
}

class _SeriesTypeInfoBtn extends StatelessWidget {
  const _SeriesTypeInfoBtn(
    this.st, {
    super.key,
  });

  final SeriesType st;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return IconButton(
        onPressed: () => Dialogs.simpleOkDialog(
              SeriesType.infoOf(st, t),
              context,
              title: Row(
                  spacing: 10,
                  children: [st.icon, Text(SeriesType.displayNameOf(st, t))]),
            ),
        icon: const Icon(Icons.info_outline));
  }
}

class SeriesEditor extends StatelessWidget {
  const SeriesEditor({
    super.key,
    required GlobalKey<FormState> form,
    required SeriesDef seriesDef,
  })  : _form = form,
        _seriesDef = seriesDef;

  final GlobalKey<FormState> _form;
  final SeriesDef _seriesDef;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ScrollableCenteredFormWrapper(
      formKey: _form,
      children: [
        Text(_seriesDef.name),
        TextFormField(
          autofocus: true,
          decoration: InputDecoration(labelText: "Name"),
          textInputAction: TextInputAction.next,
          initialValue: _seriesDef.name,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return t.commonsValidatorMsgEmptyValue;
            }
            return null;
          },
          onSaved: (value) => _seriesDef.name = value!,
        ),
      ],
    );
  }
}
