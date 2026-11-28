import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/text/overflow_text.dart';
import 'input_header.dart';

class SimpleDialogInput extends StatelessWidget {
  const SimpleDialogInput({
    super.key,
    required this.saveHandler,
    required this.child,
    required this.dateTime,
    required this.deleteHandler,
    required this.setDateTime,
    required this.seriesDef,
    required this.isEdit,
    required this.isValid,
    this.monthly = false,
  });

  final bool isEdit;
  final bool isValid;
  final SeriesDef seriesDef;
  final DateTime dateTime;
  final Function(DateTime value) setDateTime;
  final bool monthly;
  final VoidCallback saveHandler;
  final VoidCallback deleteHandler;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var iconSize = ThemeUtils.iconSizeScaled;

    void showDelDlg() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        LocaleKeys.seriesValue_query_deleteValue.tr(),
        context,
        title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
      );
      if (res == true) {
        deleteHandler();
      }
    }

    var edit = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ThemeUtils.verticalSpacing,
      children: [
        InputHeader(
          dateTime: dateTime,
          setDateTime: setDateTime,
          monthly: monthly,
        ),
        const Divider(height: 1),
        child,
      ],
    );

    return AlertDialog(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: Row(
          spacing: ThemeUtils.horizontalSpacing,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isEdit ? Icon(Icons.edit_outlined, size: iconSize) : Icon(Icons.add_outlined, size: iconSize),
            OverflowText(seriesDef.name),
            if (isEdit)
              IconButton(
                tooltip: LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
                onPressed: () => showDelDlg(),
                color: themeData.colorScheme.secondary,
                iconSize: iconSize,
                icon: const Icon(Icons.delete_outlined),
              ),
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
        if (isValid)
          TextButton(
            onPressed: saveHandler,
            child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
          ),
        if (!isValid && isEdit)
          TextButton(
            onPressed: () => showDelDlg(),
            child: Text(LocaleKeys.commons_dialog_btn_delete.tr()),
          ),
      ],
    );
  }
}
