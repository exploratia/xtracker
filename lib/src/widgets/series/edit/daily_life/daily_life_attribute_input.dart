import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/select/color_picker.dart';
import '../../../controls/text/overflow_text.dart';

class DailyLifeAttributeInput extends StatefulWidget {
  const DailyLifeAttributeInput({
    super.key,
    this.dailyLifeAttribute,
    this.newAttributeColor,
  });

  final DailyLifeAttribute? dailyLifeAttribute;
  final Color? newAttributeColor;

  static Future<DailyLifeAttribute?> showInputDlg(BuildContext context, {DailyLifeAttribute? dailyLifeAttribute, Color? newAttributeColor}) async {
    return await showDialog<DailyLifeAttribute>(
      context: context,
      builder: (_) => DailyLifeAttributeInput(
        dailyLifeAttribute: dailyLifeAttribute,
        newAttributeColor: newAttributeColor,
      ),
    );
  }

  @override
  State<DailyLifeAttributeInput> createState() => _DailyLifeAttributeInputState();
}

class _DailyLifeAttributeInputState extends State<DailyLifeAttributeInput> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _uuid;
  late Color _color;

  @override
  initState() {
    var source = widget.dailyLifeAttribute;
    _uuid = source?.uuid ?? const Uuid().v4();
    _color = source?.color ?? widget.newAttributeColor ?? ThemeUtils.primary;

    _nameController.addListener(_validate);
    if (source != null) {
      _isValid = true;
      _autoValidate = true;
      _nameController.text = source.name.toString();
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setColor(Color value) {
    setState(() {
      _color = value;
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

  void _saveHandler() {
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;
    var val = DailyLifeAttribute(uuid: _uuid, color: _color, name: _nameController.text);
    Navigator.pop(context, val);
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = ThemeUtils.iconSizeScaled;

    var edit = Form(
      key: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          TextFormField(
            autofocus: true,
            controller: _nameController,
            decoration: InputDecoration(
              labelText: LocaleKeys.seriesEdit_common_label_seriesName.tr(),
              // hintText: "hint text",
            ),
            textInputAction: TextInputAction.next,
            // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
            validator: (value) {
              if (value == null || value.isEmpty) {
                return LocaleKeys.commons_validator_emptyValue.tr();
              }
              return null;
            },
            // onSaved: (value) => _setHigh(int.tryParse(value ?? "-1") ?? -1),
            // onChanged: (value) => _setHigh(int.tryParse(value) ?? -1),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: ThemeUtils.horizontalSpacing,
            children: [
              Text(LocaleKeys.seriesEdit_common_label_seriesColor.tr()),
              ColorPicker(
                color: _color,
                colorSelected: _setColor,
              ),
            ],
          ),
        ],
      ),
    );

    return AlertDialog(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: Row(
          spacing: ThemeUtils.horizontalSpacing,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.dailyLifeAttribute == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            OverflowText(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_dlg_title.tr()),
          ],
        ),
      ),
      content: SingleChildScrollViewWithScrollbar(
        child: edit,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
        ),
        TextButton(
          onPressed: _saveHandler,
          child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
        ),
      ],
    );
  }
}
