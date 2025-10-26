import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/appbar/gradient_app_bar.dart';
import '../../../controls/layout/scrollable_centered_form_wrapper.dart';
import '../../../controls/responsive/device_dependent_constrained_box.dart';
import '../../../controls/text/overflow_text.dart';
import 'input_header.dart';

class FullscreenInput extends StatelessWidget {
  const FullscreenInput(
      {super.key,
      required this.saveHandler,
      required this.formChildren,
      required this.formKey,
      required this.autoValidate,
      required this.dateTime,
      required this.deleteHandler,
      required this.setDateTime,
      required this.seriesDef,
      required this.isEdit});

  final GlobalKey<FormState> formKey;
  final bool isEdit;
  final bool autoValidate;
  final SeriesDef seriesDef;
  final DateTime dateTime;
  final Function(DateTime value) setDateTime;
  final VoidCallback saveHandler;
  final VoidCallback deleteHandler;
  final List<Widget> formChildren;

  @override
  Widget build(BuildContext context) {
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

    var edit = ScrollableCenteredFormWrapper(
      formKey: formKey,
      autovalidateMode: autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      vCentered: true,
      spacing: ThemeUtils.verticalSpacingSmall,
      useSeriesDataInputDlgWidth: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ThemeUtils.verticalSpacing),
          child: InputHeader(dateTime: dateTime, setDateTime: setDateTime),
        ),
        const Divider(height: 1),
        ...formChildren
      ],
    );

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: GradientAppBar.build(
          context,
          title: Row(
            spacing: ThemeUtils.horizontalSpacing,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isEdit ? Icon(Icons.edit_outlined, size: iconSize) : Icon(Icons.add_outlined, size: iconSize),
              OverflowText(seriesDef.name),
              if (isEdit)
                IconButton(
                  tooltip: LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
                  onPressed: () => showDelDlg(),
                  color: ThemeUtils.onPrimary,
                  iconSize: iconSize,
                  icon: const Icon(Icons.delete_outlined),
                ),
            ],
          ),
          leading: IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_action_abort_tooltip.tr(),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_outlined),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: edit,
            ),
            SizedBox(
              height: kBottomNavigationBarHeight,
              child: DeviceDependentWidthConstrainedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: ThemeUtils.horizontalSpacing,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
                    ),
                    TextButton(
                      onPressed: saveHandler,
                      child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
