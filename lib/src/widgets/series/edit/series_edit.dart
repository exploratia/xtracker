import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../../util/dialogs.dart';
import '../../controls/layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import '../../controls/select/icon_map.dart';
import 'series_editor.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    if (_seriesDef == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: themeData.colorScheme.secondary,
          title: Text(LocaleKeys.seriesEdit_title.tr()),
          leading: IconButton(
            tooltip: LocaleKeys.seriesEdit_action_abort_tooltip.tr(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_outlined),
          ),
        ),
        body: _SeriesTypeSelector(createSeriesDef: _createSeriesDef),
      );
    }

    return SeriesEditor(
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
          Text(LocaleKeys.seriesEdit_label_selectSeriesType.tr()),
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
          ),
          const SizedBox(height: 20),
          Text(LocaleKeys.seriesEdit_label_moreSeriesToCome.tr()),
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
        tooltip: LocaleKeys.seriesEdit_btn_showSeriesTypeInfo.tr(),
        onPressed: () => Dialogs.simpleOkDialog(
              SeriesType.infoOf(st),
              context,
              title: Row(spacing: 10, children: [IconMap.icon(st.iconName), Text(SeriesType.displayNameOf(st))]),
            ),
        icon: const Icon(Icons.info_outline));
  }
}
