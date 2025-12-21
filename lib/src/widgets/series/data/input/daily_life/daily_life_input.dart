import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../util/media_query_utils.dart';
import '../../../../../util/theme_utils.dart';
import '../../view/daily_life/daily_life_attribute_renderer.dart';
import '../input_result.dart';
import '../simple_dialog_input.dart';

class DailyLifeInput extends StatefulWidget {
  const DailyLifeInput({super.key, this.dailyLifeValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final DailyLifeValue? dailyLifeValue;

  static Future<InputResult<DailyLifeValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {DailyLifeValue? dailyLifeValue}) async {
    return await showDialog<InputResult<DailyLifeValue>>(
      context: context,
      builder: (ctx) => DailyLifeInput(
        seriesDef: seriesDef,
        dailyLifeValue: dailyLifeValue,
      ),
    );
  }

  @override
  State<DailyLifeInput> createState() => _DailyLifeInputState();
}

class _DailyLifeInputState extends State<DailyLifeInput> {
  bool _isValid = false;

  late final String _uuid;
  late DateTime _dateTime;
  String? _attributeUuid;
  late final DailyLifeAttributeResolver _dailyLifeAttributeResolver;

  @override
  initState() {
    var source = widget.dailyLifeValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();
    _attributeUuid = source?.aid;

    if (source != null) {
      _isValid = true;
    }

    _dailyLifeAttributeResolver = DailyLifeAttributeResolver(widget.seriesDef);

    super.initState();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _setAttributeUuid(String value) {
    setState(() {
      _attributeUuid = value;
      _isValid = _attributeUuid != null;
    });
  }

  void _saveHandler() {
    if (!_isValid) {
      return;
    }
    bool insert = widget.dailyLifeValue == null;
    var val = DailyLifeValue(_uuid, _dateTime, _attributeUuid!);
    Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
  }

  void _deleteHandler() {
    if (widget.dailyLifeValue != null && mounted) {
      Navigator.pop(context, InputResult(widget.dailyLifeValue!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    var edit = ConstrainedBox(
      constraints: BoxConstraints(minHeight: 48 * MediaQueryUtils.textScaleFactor),
      child: Center(
        child: PopupMenuButton(
          borderRadius: ThemeUtils.borderRadiusCircular,
          icon: _attributeUuid == null ? const Icon(Icons.list) : null,
          tooltip: LocaleKeys.seriesValue_dailyLife_btn_selectAttribute_tooltip.tr(),
          itemBuilder: (context) => widget.seriesDef
              .dailyLifeAttributesSettingsReadonly()
              .attributes
              .map(
                (e) => PopupMenuItem(
                  /* Flutter Bug? if right >= 10 a huge wider padding is used. Seems not to work always. If only Text-Widgets are uses as child it has no effect. */
                  padding: const EdgeInsets.only(right: 9, left: 9, bottom: 0),
                  onTap: () => _setAttributeUuid(e.aid),
                  child: DailyLifeAttributeRenderer(dailyLifeAttribute: e),
                ),
              )
              .toList(),
          child: _attributeUuid != null
              ? Padding(
                  padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
                  child: DailyLifeAttributeRenderer(dailyLifeAttribute: _dailyLifeAttributeResolver.resolve(_attributeUuid)),
                )
              : null,
        ),
      ),
    );

    return SimpleDialogInput(
      isEdit: widget.dailyLifeValue != null,
      isValid: _isValid,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
      child: edit,
    );
  }
}
